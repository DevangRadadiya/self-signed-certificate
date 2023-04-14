#!/bin/bash

# User input
read -p "Enter domain name (e.g. example.com): " domain_name
read -p "Enter subject's Country (C): " country
read -p "Enter subject's State (ST): " state
read -p "Enter subject's Locality (L): " locality
read -p "Enter subject's Organization (O): " organization
read -p "Enter subject's Organizational Unit (OU): " organizational_unit
read -p "Enter subject's Common Name (CN): " common_name
read -p "Enter subject's Email Address: " email_address
read -p "Enter certificate expire days: " expire_days
read -sp "Enter passphrase: " passphrase

# Create issuer certificate
openssl req -new -x509 -nodes -keyout issuer.key -out issuer.crt \
    -subj "/C=$country/ST=$state/L=$locality/O=devang.com/OU=IT Department/CN=devang.com" \
    -days 36500

# Create certificate
if [[ "$domain_name" == *"*"* ]]; then
    folder_name="${domain_name/\*/_}"
    certificate_name="${domain_name/\*/}"
else
    folder_name="$domain_name"
    certificate_name="$domain_name"
fi

if [ ! -d "$folder_name" ]; then
    mkdir "$folder_name"
fi

openssl req -new -nodes -newkey rsa:2048 -keyout "$folder_name/$certificate_name.key" -out "$folder_name/$certificate_name.csr" \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizational_unit/CN=$common_name/emailAddress=$email_address"

openssl x509 -req -in "$folder_name/$certificate_name.csr" -CA issuer.crt -CAkey issuer.key -CAcreateserial -out "$folder_name/$certificate_name.crt" \
    -days "$expire_days"

# Check if certificate is expired and ask for renewal
if openssl x509 -checkend 0 -noout -in "$folder_name/$certificate_name.crt"; then
    echo "Certificate is not expired"
else
    echo "Certificate has expired or will expire soon"
    read -p "Do you want to renew the certificate? (Y/N): " renew_certificate
    if [ "$renew_certificate" == "Y" ]; then
        read -p "Enter new certificate expire days: " new_expire_days
        openssl x509 -req -in "$folder_name/$certificate_name.csr" -CA issuer.crt -CAkey issuer.key -CAcreateserial -out "$folder_name/$certificate_name.crt" \
            -days "$new_expire_days"
        echo "Certificate renewed"
    else
        echo "Certificate not renewed"
    fi
fi

# Export full chain and PFX
openssl pkcs12 -export -in "$folder_name/$certificate_name.crt" -inkey "$folder_name/$certificate_name.key" -certfile issuer.crt -out "$folder_name/$certificate_name.pfx" -passout "pass:$passphrase"

openssl pkcs12 -in "$folder_name/$certificate_name.pfx" -nokeys -out "$folder_name/$certificate_name-fullchain.crt" -passin "pass:$passphrase"

echo "Full chain and PFX exported successfully"
