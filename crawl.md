# About

This file describes the steps taken to crawl the data.gov site in order to create a static version for deployment to [Federalist](https://federalistapp.18f.gov/sites).

In order to convert the current Wordpress data.gov site into a static version, it is neccesary to:

1. Count site pages
1. Crawl old site
1. Clean crawled pages
1. Deploy static site
1. Confirm page count

## Count pages

In an attempt to quantify data.gov in terms of pages that need to be crawled and that should be avaialable in a working static copy of the site, an initial crawl to get a count of the available pages is helpful. Below are my attempts at this, but `wget` is a big thing and I'd be happy if someone finds a better way. Go hog wild digging through the [wget man page](https://www.gnu.org/software/wget/manual/wget.html).

**📢 Note: `wget` will likely get rate-limited unless either a `--wait` is used or your IP is whitelisted to blast away at the poor site. This is true for all following `wget` calls.**

A bash one liner to do that looks something like:

`wget -e robots=off -U mozilla --spider -o datagovlog -rpE -np --domains www.data.gov,data.gov -l inf www.data.gov`

and line by line is:

- `wget`
- `--execute robots=off` executes command ignore robots.txt
- `--user-agent mozilla` sets user agent to mozilla
- `--spider` spider mode, checks existence of page. downloads to temp only
- `--output-file=<log file>` creates an output log file
- `--recursive` recursively searches though html files for new links
- `--html-extension` saves with html extension
- `--domains <domain>` limits to given domain
- `--no-parent` does not search upstream of parent
- `--level=inf` recursive search depth
- `<url>`

To summarize the log file by counting `20X` response codes:

```bash
grep -B 2 '20*' datagovlog | grep "http" | cut -d " " -f 4 | sort -u | wc -l
```

and for counting `40X` responses: 

```bash
grep -B 2 '40*' datagovlog | grep "http" | cut -d " " -f 4 | sort -u | wc -l
```

In the case that you'd like to return a list of URLs, remove the last statement (`| wc -l`) on each of these.
For specific response codes, replace `20*` with a specific code: `200` or `404`.

## Crawl

The crawl is done using `wget` and largely as descibed by the link in Bret's original sketch of the story: [Linux Jouranl - Downloading an Entire Website with wget](https://www.linuxjournal.com/content/downloading-entire-web-site-wget).

The final command as a one-liner to crawl www.data.gov is:

```bash
wget -e robots=off -U mozilla --recursive --page-requisites --html-extension --domains www.data.gov,data.gov --no-parent --level=inf www.data.gov
```

## Clean

Oh man, there ends up being a lot of cleaning up to do.
While `--convert-links` does a great job for the most part, there remain many issues.
The main type of issue has been when a file is saved with a strange extension, for example: `some_page_index.css?ver=2.2.2`.
The problem is that then Federalist interprets this example file as being of the type `.2` instead of `.css` and doesn't set the MIME type correctly.

To fix this, the files need to be remained with their appropriate extension as well as references to them updated to the new file names.

## Deploy

The deployment in this case is relatively straight forward.
We are using Federalist to host for the meantime.
The [Federalist documentation](https://federalist.18f.gov/documentation/) can be used to set this up, but the current site should also be available as [gsa/datagov-website](https://federalistapp.18f.gov/sites/1072/builds) (list of builds, preview sites available by following the links).

## Confirm page count

Once a static version of the site is deployed onto Federalist, confirming that it is a complete copy is neccessary. 
Thankfully, the steps in Count Pages can be repeated, with the `<url>` being the new Federalist URL and probably the `<log file>` pointing to a new file as well.

Ideally, once crawlled and then summarized, the counts should be comparable.
