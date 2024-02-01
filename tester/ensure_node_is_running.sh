while [[ "$(curl -s -w ''%{http_code}'' $1)" != "200" ]]; do sleep 1; done
