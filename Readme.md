[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/jlohmoeller/letsencrypt-dns) 
![Docker Automated build](https://img.shields.io/docker/cloud/automated/jlohmoeller/letsencrypt-dns)
![Docker Pulls](https://img.shields.io/docker/pulls/jlohmoeller/letsencrypt-dns)](https://hub.docker.com/r/jlohmoeller/letsencrypt-dns)

# Docker Letsencrypt with nsupdate

Tiny little helper that integrates certbot with nsupdate to perform the dns-01 challenge. 
Requires access to the authoritative nameservers using `nsupdate`.

Advantages:
- no need for a proxy or special configuration of websites
- dns-01 allows wildcard subdomains

Certificates are exported to a separate volume and automatically renewed. 
A combined version of each certificate, i.e., the private key and the certificate chain is exported to the `/certs/combined` dir which can be directly used e.g. with haproxy.

## How to deploy

Add dynamic dns key on your master nameserver and allow to update TXT records for `_acme-challenge.<domain to be validated>`.
For the popular bind nameserver, the steps are described below:

### Configuring bind keys
Create a new key with 
```
dnssec-keygen -r /dev/urandom -a HMAC-MD5 -b 512 -n HOST certbot
```
This generates two files:
```
-rw-------. 1 root bind  116 Sep 28 18:02 Kcertbot.+157+62878.key
-rw-------. 1 root bind  229 Sep 28 18:02 Kcertbot.+157+62878.private
```
Open the generated .key file and copy the key part (`2N5mGAt7+oMWHQ6JZ2KmDB6wliIcKCBUdOklFivouwOG8g0jzJgzwJ4hnjVXC04tVWXmz2m45lvbqa57NrJDnA==` in the above example).

Now, add an entry to `named.conf` or `named.conf.local`:
```
key certbot {
  algorithm hmac-md5;
  secret "2N5mGAt7+oMWHQ6JZ2KmDB6wliIcKCBUdOklFivouwOG8g0jzJgzwJ4hnjVXC04tVWXmz2m45lvbqa57NrJDnA=="
}
```

Then, for each of your DNS zones, add or alter the `update-policy` parameter:
```
zone "example.com" {
  type master;
  #[...]
  update-policy {
    grant certbot zonesub TXT;
    #[...]
  };
};
```

### Setting up the container
Create the file `settings.env` with the following content:
```
NSUPDATE_SERVER=yourmasternameserver.com
NSUPDATE_TOKEN=certbot:courgeneratednsupdatekey
```

Use the provided [docker-compose.yaml](docker-compose.yaml) file to start the service. Once it is up and running,
use `docker exec -it letsencrypt cert yourdomain.com` to request a certificate for `yourdomain.com`. 
When requesting your first certificate, you will be asked to agree to the Letsencrypt ToS and for your email. This generates the following files:
```
$ docker exec -it letsencrypt cert yourdomain.com
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator manual, Installer None
Obtaining a new certificate
Performing the following challenges:
dns-01 challenge for yourdomain.com
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/yourdomain.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/yourdomain.com/privkey.pem
   Your cert will expire on 2019-12-27. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

$ ls -l certs/
total 32
drwxr-xr-x. 2 root root 4096 Sep 28 18:42 combined
-rw-r--r--. 1 root root 3534 Sep 28 18:42 yourdomain.com-chain.pem
-rw-r--r--. 1 root root 1704 Sep 28 18:42 yourdomain.com-key.pem
-rw-r--r--. 1 root root 1887 Sep 28 18:42 yourdomain.com.pem
$ ls -l certs/combined/
total 12
-rw-r--r--. 1 root root 5238 Sep 28 18:42 yourdomain.com.pem
```
