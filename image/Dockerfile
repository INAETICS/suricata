FROM ubuntu:14.04 


RUN apt-get update

RUN apt-get install -y python-software-properties software-properties-common

RUN add-apt-repository ppa:oisf/suricata-stable -y

RUN apt-get update &&  apt-get install -y \
    	curl \
        cron \
	logrotate \
    	ed \
    	tar \
    	tcpdump \
    	python-pip \
    	python-simplejson \
    	wget \
    	supervisor \
    	tcpdump \
    	net-tools \
    	procps \
	hostname \
	findutils \
        suricata \ 
        && apt-get clean

# Create a user to run non-root applications.
RUN useradd user

# EveBox.
ENV EVEBOX_COMMIT be8389d4ad119a1ce984718297b94daa3b0c814d
RUN mkdir -p /usr/local/src/evebox && \
    cd /usr/local/src/evebox && \
    curl -L -o - http://github.com/jasonish/evebox/archive/${EVEBOX_COMMIT}.tar.gz | tar zxf - --strip-components=1 && \
    cp -a app /srv/evebox
RUN curl -k -L https://github.com/coreos/etcd/releases/download/v2.0.13/etcd-v2.0.13-linux-amd64.tar.gz | gunzip | tar xf - \
    && cp etcd-v2.0.13-linux-amd64/etcdctl /bin/

# Copy in files.
COPY /resources/etc/supervisord.conf /etc/supervisord.conf
COPY /resources/etc/supervisord.d /etc/supervisord.d
COPY /resources/etc/logrotate.d /etc/logrotate.d
COPY /resources/etc/cron.daily /etc/cron.daily
COPY /resources/srv /srv
COPY /resources/start.sh /start.sh
RUN mv /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml-default
COPY /resources/etc/suricata /etc/suricata
COPY /resources/trustlevel.sh /trustlevel.sh
COPY /resources/jq /usr/bin/jq

# Fix permissions.
RUN chmod 644 /etc/logrotate.d/*

# Cleanup.
RUN rm -rf /var/tmp/* && \
    find /var/log -type f -exec rm -f {} \; && \
    rm -rf /tmp/* /tmp/.[A-Za-z]*

ENTRYPOINT ["/start.sh"]
