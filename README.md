# catcerts
Simple concatenation of certificates for full chain pem generation

I use this with `ipa-getcert`.

Some examples for Ubuntu:

```
sudo ipa-getcert request -K HTTP/$(hostname) \
  -k /etc/ssl/private/$(hostname).key \
  -f /etc/ssl/certs/$(hostname).crt \
  -D $(hostname) \
  -C "/usr/local/bin/catcerts.sh /etc/ssl/certs/$(hostname).crt /etc/ipa/ca.crt /etc/ssl/certs/$(hostname).pem"
```

```
service="host.site.domain.ext"
sudo ipa-getcert request -N ${service} -K HTTP/${service} \
  -k /etc/ssl/private/${service}.key \
  -f /etc/ssl/certs/${service}.crt \
  -D ${service} \
  -C "/usr/local/bin/catcerts.sh /etc/ssl/certs/${service}.crt /etc/ipa/ca.crt /etc/ssl/certs/${service}.pem"
```

Some examples for CentOS 8 stream:

```
sudo ipa-getcert request -K HTTP/$(hostname) \
  -k /etc/pki/tls/private/$(hostname).key \
  -f /etc/pki/tls/certs/$(hostname).crt \
  -D $(hostname) \
  -C "/usr/local/bin/catcerts.sh /etc/pki/tls/certs/$(hostname).crt /etc/ipa/ca.crt /etc/pki/tls/certs/$(hostname).pem"
```

```
service="host.site.domain.ext"
sudo ipa-getcert request -N ${service} -K HTTP/${service} \
  -k /etc/pki/tls/private/${service}.key \
  -f /etc/pki/tls/certs/${service}.crt \
  -D ${service} \
  -C "/usr/local/bin/catcerts.sh /etc/pki/tls/certs/${service}.crt /etc/ipa/ca.crt /etc/pki/tls/certs/${service}.pem"
```

## Installation

Copy `catcerts.sh` to `/usr/local/bin/`, or create it there and make it executable:

`sudo chmod +x /usr/local/bin/catcerts.sh`
