:wget wget http://curl.haxx.se/ca/cacert.pem
set SSL_CERT_FILE=cacert.pem
rake publish --trace