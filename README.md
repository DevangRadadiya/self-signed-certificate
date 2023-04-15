# SSL Certificate Generation Script

This script generates an SSL/TLS certificate using OpenSSL. The certificate can be used for securing web servers, mail servers, and other network services.

## Prerequisites
OpenSSL

## Usage
1. Run the script using the command ./generate_certificate.sh
2. Enter the required details when prompted:
    Subject Alternative Name (SAN)
    Country (C) code
    State/Province (ST)
    City/Locality (L)
    Organization (O)
    Organizational Unit (OU)
    Common Name (CN)
    Email Address
    Issuer Name
    Passphrase for the PFX file
3. The script will generate the following files in the current directory:
    CN.key - private key
    CN.csr - certificate signing request
    CN.crt - signed certificate
    CN.pfx - PFX file containing the certificate and private key
    CN_fullchain.pem - file containing the full chain of trust
    issuerName.pem - issuer certificate
    
Note: Replace CN with the value of the Common Name (CN) entered during the script execution.

## How it works
The script generates a private key and a certificate signing request (CSR) using the openssl req command. The CSR is signed using an issuer certificate created using the openssl req and openssl x509 commands. Finally, the script combines the signed certificate and private key into a PFX file using the openssl pkcs12 command.

The script also creates a file containing the full chain of trust by concatenating the signed certificate and the issuer certificate.

## Disclaimer
This script is provided as is, without any warranty or support. The author is not responsible for any damage or loss caused by the use of this script.
