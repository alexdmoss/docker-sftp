FROM alpine:3.6
MAINTAINER Alex Moss <alex@moss.work>

# shadow is required for usermod
# tzdata for time syncing
# bash for entrypoint script
RUN apk add --no-cache openssh bash shadow tzdata

# Ensure generated keys are used
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_ecdsa_key
# Add generated server SSH keys
ADD ssh/ssh_host_rsa_key /etc/ssh/
ADD ssh/ssh_host_dsa_key /etc/ssh/
ADD ssh/ssh_host_ecdsa_key /etc/ssh/

# Add user client keys for adding to authorized_keys
VOLUME /keys
ADD public-keys/* /keys/

# Create entrypoint script
ADD launch.sh /
RUN chmod +x /launch.sh
RUN mkdir -p /launch.d

# SSH Server configuration file
ADD sshd_config /etc/ssh/sshd_config
RUN addgroup sftp

# Default environment variables
ENV TZ="Europe/London" \
    LANG="en_GB.UTF-8"

EXPOSE 22
ENTRYPOINT [ "/launch.sh" ]

# RUN SSH in no daemon and expose errors to stdout
CMD [ "/usr/sbin/sshd", "-D", "-e" ]
