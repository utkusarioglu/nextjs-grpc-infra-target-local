#!/bin/bash

ca_path=".certs/ca"
key_path="$ca_path/ca.key"
cert_path="$ca_path/ca.crt"

mkdir -p "$ca_path"

openssl req -x509 -nodes -days 1 \
  -newkey ec:<(openssl ecparam -name prime256v1) \
  -subj "/C=UT/ST=UT/L=UT/O=utkusarioglu" \
  -keyout "$key_path" \
  -out "$cert_path"

openssl ec -in "$key_path" -text -noout
openssl x509 -in "$cert_path" -text -noout
