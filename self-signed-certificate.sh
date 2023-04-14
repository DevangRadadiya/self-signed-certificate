#!/bin/bash

# Get input from the user
echo "Enter the Subject Alternative Name (SAN) (e.g. example.com):"
read SAN

echo "Enter the Country (C) code (e.g. US):"
read C

echo "Enter the State/Province (ST) (e.g. California):"
read ST

echo "Enter the City/Locality (L) (e.g. San Francisco):"
read L

echo "Enter the Organization (O) (e.g. Example, Inc.):"
read O

echo "Enter the Organizational Unit (OU) (e.g. IT Department):"
read OU

echo "Enter the Common Name (CN) (e.g. example.com):"
read CN

echo "Enter the Email Address (e.g. info@example.com):"
read emailAddress

echo "Enter the issuer name (e.g. devang.com):"
read issuerName

echo "Enter the passphrase for the PFX file:"
read -s passphrase

# Check if the CN starts with a wildcard character
if [[ $CN == *\** ]]; then
    # Replace the wildcard character with an underscore in the file name
    CN_file="${CN/\*/_}"
else
    CN_file=$CN
fi

# Generate the private key and CSR
openssl req -newkey rsa:2048 -nodes -keyout ${CN_file}.key -out ${CN_file}.csr -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN}/emailAddress=${emailAddress}/subjectAltName=${SAN}"

# Create the issuer certificate
openssl req -x509 -newkey rsa:2048 -nodes -keyout ${issuerName}.key -out ${issuerName}.pem -days 36500 -subj "/C=${C}/ST=${ST}/L=${L}/O=${issuerName}/OU=${OU}/CN=${issuerName}/emailAddress=${emailAddress}"

# Sign the CSR with the issuer certificate
openssl x509 -req -in ${CN_file}.csr -CA ${issuerName}.pem -CAkey ${issuerName}.key -CAcreateserial -out ${CN_file}.crt -days 36500 -extensions req_ext -extfile <(printf "[req_ext]\nsubjectAltName=DNS:${SAN}")

# Combine the certificate and private key into a PFX file
openssl pkcs12 -export -out ${CN_file}.pfx -inkey ${CN_file}.key -in ${CN_file}.crt -certfile ${issuerName}.pem -passout pass:${passphrase}

# Export the full chain
cat ${CN_file}.crt ${issuerName}.pem > ${CN_file}_fullchain.pem

echo "SSL certificate has been generated successfully!"
