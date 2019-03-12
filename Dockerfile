FROM debian

ENV	SEAFILE_VERSION 6.3.12

EXPOSE 8082 8000

VOLUME /seafile
WORKDIR	/seafile

# Required packages for pro edition
RUN apt-get update && apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        openjdk-8-jre sqlite3 wget \
        poppler-utils libpython2.7 python-pip python-setuptools python-imaging \
        python-mysqldb python-memcache python-ldap python-urllib3 \
        libreoffice libreoffice-script-provider-python \
        fonts-vlgothic ttf-wqy-microhei ttf-wqy-zenhei xfonts-wqy && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip install boto

# RUN yum install -y epel-release && yum update -y && \
#     yum install -y \
#         java-1.8.0-openjdk-headless poppler-utils python-libs python2-pip \
#         python-setuptools python-imaging MySQL-python \
#         python-memcached python-ldap python-urllib3 \
#         sqlite wget libreoffice python-openoffice \
#         vlgothic-fonts wqy-microhei-fonts wqy-zenhei-fonts && \
#     yum clean all && \
#     pip install boto


# Download seafile binary
RUN	wget "https://download.seafile.com/d/6e5297246c/files/?p=/pro/seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz&dl=1" -O "/seafile-pro-server_${SEAFILE_VERSION}_x86-64.tar.gz"

# Install Seafile service.
ADD	service/seafile/run.sh /etc/service/seafile/run
ADD	service/seafile/stop.sh /etc/service/seafile/stop

# Install Seahub service.
ADD	service/seahub/run.sh /etc/service/seahub/run
ADD	service/seahub/stop.sh /etc/service/seahub/stop

# Add custom configuration
COPY config/seafevents.conf /seafevents.conf

ADD	bin/setup.sh /usr/local/sbin/setup
ADD	bin/upgrade.sh /usr/local/sbin/upgrade

# Set permissions
RUN	chmod +x /usr/local/sbin/setup && \
    chmod +x /usr/local/sbin/upgrade && \
    chmod +x /etc/service/seafile/* && \
    chmod +x /etc/service/seahub/* && \
    mkdir -p /etc/pki/tls/certs && \
    cp /etc/ssl/certs/ca-certificates.crt /etc/pki/tls/certs/ca-bundle.crt && \
    ln -s /etc/pki/tls/certs/ca-bundle.crt /etc/pki/tls/cert.pem

CMD	/sbin/my_init
