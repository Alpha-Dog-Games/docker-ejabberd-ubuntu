FROM ubuntu:16.04
MAINTAINER Brandon Konkle <brandon@konkle.us>

# Set default path and locale for the environment
ENV LC_ALL=C.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    PATH=/usr/sbin:/usr/bin:/sbin:/bin \
    EJABBERD_HTTPS=true \
    EJABBERD_TLS=true \
    EJABBERD_S2S_SSL=true \
    EJABBERD_DEBUG_MODE=false \
    EJABBERD_LOGLEVEL=4 \
    EJABBERD_MOD_ADMIN_EXTRA=true \
    EJABBERD_HTTP_API=false \
    EJABBERD_HTTP_WS=false \
    XMPP_DOMAIN=localhost

# Install packages and perform cleanup
RUN set -x \
    && apt-get update \
    && apt-get install -y ejabberd --no-install-recommends \
    && dpkg-reconfigure locales && \
        locale-gen en_US.UTF-8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    && echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/run/ejabberd \
    && chmod 0755 /var/run/ejabberd \
    && chown ejabberd:ejabberd /var/run/ejabberd

# Add dockerize so that the run script can templatize config and capture logs
ADD https://github.com/jwilder/dockerize/releases/download/v0.2.0/dockerize-linux-amd64-v0.2.0.tar.gz dockerize.tar.gz
RUN tar -C /usr/local/bin -xzvf dockerize.tar.gz && rm dockerize.tar.gz

# Wrapper for running within a container
ADD ./scripts/run.sh /sbin/run

# Add config templates and certs
ADD ./conf /etc/ejabberd

# Continue as ejabberd user
USER ejabberd

VOLUME ["/var/lib/ejabberd/"]
EXPOSE 5222 5269 5280

CMD ["start"]
ENTRYPOINT ["run"]
