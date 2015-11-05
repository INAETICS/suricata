FROM fedora:22

RUN dnf -y update

RUN dnf -y install \
    	cronie \
	logrotate \
    	ed \
    	tar \
    	tcpdump \
    	python-pip \
    	nginx \
    	python-simplejson \
    	wget \
    	supervisor \
    	which \
    	tcpdump \
    	net-tools \
    	procps-ng \
	hostname \
	java-1.8.0-openjdk-headless \
	findutils \
    	dnf-plugins-core && \
    dnf -y copr enable jasonish/suricata-beta-2.1 && \
    dnf -y install suricata

# Create a user to run non-root applications.
RUN useradd user

# EveBox.
ENV EVEBOX_COMMIT be8389d4ad119a1ce984718297b94daa3b0c814d
RUN mkdir -p /usr/local/src/evebox && \
    cd /usr/local/src/evebox && \
    curl -L -o - http://github.com/jasonish/evebox/archive/${EVEBOX_COMMIT}.tar.gz | tar zxf - --strip-components=1 && \
    cp -a app /srv/evebox


# Copy in files.
COPY /etc/supervisord.d /etc/supervisord.d
COPY /etc/logrotate.d /etc/logrotate.d
COPY /etc/cron.daily /etc/cron.daily
COPY /srv /srv
COPY /start.sh /start.sh
RUN mv /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml-default
COPY /etc/suricata /etc/suricata

# Fix permissions.
RUN chmod 644 /etc/logrotate.d/*

# Cleanup.
RUN dnf clean all && \
    rm -rf /var/tmp/* && \
    find /var/log -type f -exec rm -f {} \; && \
    rm -rf /tmp/* /tmp/.[A-Za-z]*

ENTRYPOINT ["/start.sh"]
