#!/usr/bin/env bats

function wait_for () {
  let retries=5
  while ! nc -z -w 5 nginx 80; do
    if [ "$retries" -le 0 ]; then
      return 1
    fi

    retries=$(( $retries - 1 ))
    sleep 1
  done
}

@test "app container is up" {
  run wait_for nginx 80
}

@test "wordpress is up" {
  run curl --silent --fail http://nginx:80/
  [ $status -eq 0 ]
}
