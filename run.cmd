:wget wget http://curl.haxx.se/ca/cacert.pem
set SSL_CERT_FILE=cacert.pem
bundle exec jekyll serve --force_polling --baseurl= --trace --incremental
