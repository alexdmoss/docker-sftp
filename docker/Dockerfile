FROM alpine:3.6
MAINTAINER Alex Moss <alex@moss.work>

# shadow is required for usermod, tzdata for time syncing, bash for entrypoint script
RUN apk add --no-cache openssh bash shadow tzdata

# Ensure generated keys are used
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_ecdsa_key
# Add generated server SSH keys
COPY secrets/ssh/ssh_host_rsa_key secrets/ssh/ssh_host_dsa_key secrets/ssh/ssh_host_ecdsa_key /etc/ssh/

# Add user client keys for adding to authorized_keys
VOLUME /keys
COPY secrets/public-keys /keys/

# Create entrypoint script
COPY docker/launch.sh /
RUN chmod +x /launch.sh && \
    mkdir -p /launch.d

# SSH Server configuration file
COPY config/sshd_config /etc/ssh/sshd_config
RUN addgroup sftp

# Default environment variables
ENV TZ="Europe/London" \
    LANG="en_GB.UTF-8"

EXPOSE 22

ENTRYPOINT [ "/launch.sh" ]

# run SSH in no daemon and expose errors to stdout
CMD [ "/usr/sbin/sshd", "-D", "-e" ]
