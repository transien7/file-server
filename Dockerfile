FROM ubuntu:22.04

WORKDIR /srv/share

RUN apt-get update && apt-get install -y \
    openssh-server \
    vsftpd \
    tftpd-hpa \
    nginx

RUN ln -s /srv/share /var/www/html/files && \
    ln -s /srv/share /srv/ftp && \
    ln -s /srv/share /srv/tftp

COPY config/sshd.conf /etc/ssh/sshd_config
COPY config/vsftpd.conf /etc/vsftpd.conf
COPY config/tftpd.conf /etc/default/tftpd-hpa
COPY config/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 21 22 69/udp 80 443

VOLUME ["/srv/share"]

CMD ["tail", "-f", "/dev/null"]
