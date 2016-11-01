# docker-ejabberd-ubuntu

An ejabberd image forked and simplified from [rroemhild/docker-ejabberd](https://github.com/rroemhild/docker-ejabberd), but built on Ubuntu LTS and using the standard Debian layout.

## QuickStart

```sh
$ docker run -d \
  --name "ejabberd" \
  -p 5222:5222 \
  -p 5269:5269 \
  -p 5280:5280 \
  -h 'xmpp.example.com' \
  -e "XMPP_DOMAIN=example.com" \
  -e "ERLANG_NODE=ejabberd" \
  -e "EJABBERD_ADMINS=admin@example.com" \
  -e "EJABBERD_USERS=admin@example.com:password1234 user1@xyz.io" \
  -e "TZ=America/Denver" \
  ecliptic/ejabberd-ubuntu
```

## Usage

### Persistence

Currently, this image has one volume: the data directory at `/var/lib/ejabberd`.

### Extending

Build your own ejabberd container image to add your config templates and certificates.

```docker
FROM ecliptic/ejabberd-ubuntu
ADD ./conf/ejabberd.yml.tmpl /etc/ejabberd/ejabberd.yml.tmpl
ADD ./conf/ejabberdctl.cfg /etc/ejabberd/ejabberdctl.cfg
ADD ./conf/ejabberd.pem /etc/ejabberd/ejabberd.pem
```
