# About

This file describes the steps taken to crawl the data.gov site in order to create a static version for deployment to [Federalist](https://federalistapp.18f.gov/sites).

In order to convert the current Wordpress data.gov site into a static version, it is necessary to:

1. Count site pages
1. Crawl old site
1. Clean crawled pages
1. Deploy static site
1. Confirm page count

## 1. Count pages

In an attempt to quantify data.gov in terms of pages that need to be crawled and that should be available in a working static copy of the site, an initial crawl to get a count of the available pages is helpful. Below are my attempts at this, but `wget` is a big thing and I'd be happy if someone finds a better way. Go hog wild digging through the [wget man page](https://www.gnu.org/software/wget/manual/wget.html).

**📢 Note: `wget` will likely get rate-limited unless either a `--wait` is used or your IP is whitelisted to blast away at the poor site. This is true for all following `wget` calls.**

A bash one liner to do that looks something like:

`wget -e robots=off -U mozilla --spider -o datagovlog -rpE -np --domains www.data.gov,data.gov -l inf www.data.gov`

and line by line is (or just check the [Explain Shell](https://explainshell.com/explain?cmd=wget+-e+robots%3Doff+-U+mozilla+--spider+-o+datagovlog+-rpE+-np+--domains+www.data.gov%2Cdata.gov+-l+inf+www.data.gov)):

- `wget`
- `--execute robots=off` executes command ignore robots.txt
- `--user-agent mozilla` sets user agent to mozilla
- `--spider` spider mode, checks existence of page. downloads to temp only
- `--output-file=<log file>` creates an output log file
- `--recursive` recursively searches though html files for new links
- `--adjust-extension` saves with appropriate extension
- `--domains <domain>` limits to given domain
- `--no-parent` does not search upstream of parent
- `--level=inf` recursive search depth
- `<url>`

For reference, on my machine, connection and no `--wait`, the crawl takes about 15 minutes.
With `--wait=1`, it's over an hour to complete.

### Summarizing the results

To summarize the log file by counting `20X` response codes:

```bash
grep -B 2 '20*' datagovlog | grep "http" | cut -d " " -f 4 | sort -u | wc -l
```

and for counting `404` responses:

```bash
grep -B 2 '404' datagovlog | grep "http" | cut -d " " -f 4 | sort -u | wc -l
```

In the case that you'd like to return a list of URLs, remove the last statement (`| wc -l`) on each of these.
For specific response codes, replace `20*` with a specific code: `200` or `404`.

For context, here are the results of a recent run (on October 21, 2021):

| Code | Count |
|------|-------|
| 20*  | 2,067 |
| 200  | 1,431 |
| 404  | 375   |
| 500  | 2     |

I'm not sure how useful these numbers are, but in theory once the site is deployed to Federalist the numbers should line up if everything was captured correctly.

## 2. Crawl

The crawl is done using `wget` and largely as described by the link in Bret's original sketch of the story: [Linux Jouranl - Downloading an Entire Website with wget](https://www.linuxjournal.com/content/downloading-entire-web-site-wget).

The final command as a one-liner to crawl www.data.gov is:

```bash
wget -e robots=off -U mozilla --recursive --page-requisites --html-extension --domains www.data.gov,data.gov --no-parent --level=inf --convert-links --restrict-file-names=windows www.data.gov
```

It is also possible that `--mirror` mode might be the better option.

The final output of a successful run:

```bash
(many lines like this above)
...

--2021-10-22 09:37:25--  https://www.data.gov/developers/page/38/
Reusing existing connection to www.data.gov:443.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [text/html]
Saving to: ‘www.data.gov/developers/page/38/index.html’

www.data.gov/developers/page     [ <=>                                           ]  34.31K  --.-KB/s    in 0.001s

2021-10-22 09:37:25 (29.5 MB/s) - ‘www.data.gov/developers/page/38/index.html’ saved [35136]

FINISHED --2021-10-22 09:37:25--
Total wall clock time: 9m 11s
Downloaded: 2283 files, 69M in 14s (5.06 MB/s)
Converting links in www.data.gov/climate/humanhealth/highlights@currentpage=2.html... 68-15
Converting links in www.data.gov/climate/ecosystem-vulnerability-launch/index.html... 58-9
...
(many lines like this)
...
Converting links in www.data.gov/app/themes/roots-nextdatagov/assets/LeafletMap2/Leaflet.defaultextent/dist/leaflet.defaultextent.css@ver=5.5.6.css... 2-0
Converted links in 993 files in 13 seconds.
```

## 3. Clean

Oh man, there ends up being a lot of cleaning up to do.

While `--convert-links` does a great job, there remain many issues.
The most common seem to be 'versioning' in files names, references to those bad filenames, and un-locally-converted links.

### Versioned file names

The main type of issue has been when a file is saved with a strange extension, for example: `some_page_index.css?ver=2.2.2`.
The problem is that then Federalist interprets this example file as being of the type `.2` instead of `.css` and doesn't set the MIME type correctly.

To fix this, the files need to be renamed with their appropriate extension as well as references to them updated to the new file names.
One way of achieving this is (with your `pwd` as the root of the crawl):

**📢 Test what this will do first by cutting `mv $fname ${fname%@*};` out to do a dry run.**

```bash
find . -iname "*@ver=*" | while read fname; do echo "$fname --> ${fname%@*}"; mv $fname ${fname%@*}; done
```

Also, to note, this will work only for files that match the `@ver=` syntax.
There will likely also be files that match `?ver=`, `%3Fver=`, and perhaps other patterns.
All of these will need to be addressed by searching for matching patterns and changing the above command to rename them.

### References to versioned file names

Due to the issues above with versioned file names, the links to those files now point to the now renamed files.
To fix this, those links must be updated.
I'm sure there is some great way of doing this, however I relied upon the VSCode Search & Replace interface and a bunch of regex.
This interface is nice because VSCode runs the regex as you work on it, showing matching results and replacements in realtime.

Examples:

- `(href=")(.*?)(\?ver=.*?)(")` replacing with `$1$2$4`. This returns about 8k results
- `(src=')(.*?)(\?ver=.*?)(')` replacing with `$1$2$4`. This returns about 11k results

To search for any additional patterns or links that may have been missed `ver=` should return any.

### Un-locally-converted links

While `--convert-links` converts links from the original domain to be locally referenced, many links still contain `www.data.gov` and `data.gov`.
I'm not quite sure why most are caught but some are not, though it appears to be more common in nested pages.
In any case, similarly to above, VSCode's Search and Replace interface is handy to target these.

To initially search for these: just use `www.data.gov`.
Ideally, replacing a long URL like this with a local reference will result in links that work correctly for their given page.

For example:

```html
<a href="/ocean/page/ocean-technical">Get Involved</a>
```

instead of:

```html
<a href="https://www.data.gov/ocean/page/ocean-technical">Get Involved</a>
```

The real trick, however, is to write a regex that works well for nested links and does not result in links on a page like `http://localhost:8000/energy/energy-apps/` going to `http://localhost:8000/energy/energy-apps/energy/page/energy-maps` instead of the correct `localhost:8000/energy/page/energy-maps`. I never got one working quite correctly, but good luck!

## 4. Deploy

The deployment in this case is relatively straight forward.
We are using Federalist to host statically for the meantime.
The [Federalist documentation](https://federalist.18f.gov/documentation/) can be used to set this up, but the current site should also be available as [gsa/datagov-website](https://federalistapp.18f.gov/sites/1072/builds) (list of builds, preview site links are also available).

## 5. Confirm page count

Once a static version of the site is deployed onto Federalist, confirming that it is a complete copy is necessary.
Thankfully, the steps in Count Pages can be repeated, with the `<url>` being the new Federalist URL and probably the `<log file>` pointing to a new file as well.

Ideally, once crawled and then summarized, the counts should be comparable.
