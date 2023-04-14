#!/bin/bash

echo "Enter the domain name (without https://www. and extensions like .com, .org):"
read domain_name

# Remove the * character from the beginning of the domain name, if any
if [[ $domain_name == *\** ]]; then
  domain_name=${domain_name#*\*}
  folder_name="_${domain_name}"
else
  folder_name="${domain_name}"
fi

echo "Enter the country code (2-letter code):"
read country_code

echo "Enter the state/province:"
read state

echo "Enter the locality/city:"
read city

echo "Enter the organization:"
read org

echo "Enter the organizational unit:"
read org_unit

echo "Enter the common name (fully qualified domain name):"
read common_name

echo "Enter the email address:"
read email

echo "Enter the SAN (comma separated values, for example: dns:example.com,ip:10.0.0.1):"
read san

echo "Enter the certificate expiry in days:"
read expire_days

echo "Enter the passphrase:"
read -s passphrase

# Create the issuer certificate
openssl genrsa -out issuerdevang.key 2048
openssl req -new -x509 -key issuerdevang.key -out issuerdevang.crt -days 36500 -subj "/C=UK/ST=London/L=London/O=devang.com/OU=IT/CN=devang.com/emailAddress=admin@devang.com"

# Create the SSL certificate
openssl genrsa -out $folder_name/$domain_name.key 2048
openssl req -new -key $folder_name/$domain_name.key -out $folder_name/$domain_name.csr -subj "/C=$country_code/ST=$state/L=$city/O=$org/OU=$org_unit/CN=$common_name/emailAddress=$email"
openssl x509 -req -in $folder_name/$domain_name.csr -CA issuerdevang.crt -CAkey issuerdevang.key -CAcreateserial -out $folder_name/$domain_name.crt -days $expire_days -sha256 -extfile <(echo subjectAltName=$san)

# Export the PFX and full chain
openssl pkcs12 -export -out $folder_name/$domain_name.pfx -inkey $folder_name/$domain_name.key -in $folder_name/$domain_name.crt -certfile issuerdevang.crt -passout pass:$passphrase
cat $folder_name/$domain_name.crt issuerdevang.crt > $folder_name/full_chain.crt

echo "Certificate for $common_name generated successfully!"
