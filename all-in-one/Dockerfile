FROM ubuntu:latest

ARG APP_USER
ARG APP_PASS

# Install services
RUN apt-get update && apt-get install -y \
    openssh-server \
    vsftpd \
    tftpd-hpa \
    nginx \
    supervisor && \
    apt-get clean

# Add a user for testing
RUN useradd -m "${APP_USER}" && \
    echo "${APP_USER}:${APP_PASS}" | chpasswd && \
    chsh -s /bin/bash ${APP_USER}

# Create SSH, FTP and TFTP directories and change ownership
RUN mkdir -p mkdir -p /var/run/sshd /var/run/vsftpd/empty /srv/tftp && \
    chown -R tftp:tftp /srv/tftp

# Symlink service directories to the file share directory
RUN ln -s /srv/share /var/www/files && \
    ln -s /srv/share /srv/ftp && \
    ln -s /srv/share /srv/tftp

# Copy across service configs
COPY config/sshd.conf /etc/ssh/sshd_config
COPY config/vsftpd.conf /etc/vsftpd.conf
COPY config/tftpd.conf /etc/default/tftpd-hpa
COPY config/nginx.conf /etc/nginx/conf.d/fileserver.conf
COPY config/supervisor.conf /etc/supervisor/conf.d/supervisord.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 21 22 69/udp 80 30000-30100

VOLUME ["/srv/share", "/etc/ssh_keys"]

CMD ["/entrypoint.sh"]
#CMD ["tail", "-f", "/dev/null"]
