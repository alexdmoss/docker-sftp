#!/bin/bash

set -e

if [[ "$1" == '/usr/sbin/sshd' ]]; then

  # Ensure time is in sync with host
  if [[ -n ${TZ} ]] && [[ -f /usr/share/zoneinfo/${TZ} ]]; then
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
    echo ${TZ} > /etc/timezone
  fi

  # If user doesn't exist on the system
  if ! cut -d: -f1 /etc/passwd | grep -q $USERNAME; then
    echo "Creating user $USERNAME and granting permissions to $FOLDER"
    useradd -u $OWNER_ID -M -d $FOLDER -G sftp -s /bin/false $USERNAME
  else
    echo "User $USERNAME already exists, granting permissions to $FOLDER"
    usermod -u $OWNER_ID -G sftp -a -d $FOLDER -s /bin/false $USERNAME
  fi

  # Change sftp password
  echo "$USERNAME:$PASSWORD" | chpasswd

  # Mount the data folder in the chroot folder
  mkdir -p /chroot${FOLDER}
  sed -i -e 's/#ChrootDirectory/ChrootDirectory/' /etc/ssh/sshd_config
  mount --bind $FOLDER /chroot${FOLDER}

  # Set permissions on data directory
  chown -R $USERNAME:sftp $FOLDER
  chmod -R 770 $FOLDER
  chown -R $USERNAME:sftp chroot${FOLDER}
  chmod -R 770 /chroot${FOLDER}

  # Add scripts into /launch.d to set up additional config (e.g. extra users)
  for f in /launch.d/*; do
    case "$f" in
      *.sh)  echo "$0: running $f"; . "$f" ;;
      *)     echo "$0: ignoring $f" ;;
    esac
  done

  # read supplied user keys and build authorized_keys file to use
  if [[ -d /keys ]]; then
    cat /keys/* >> /keys/authorized_keys
    chown $USERNAME /keys/authorized_keys
    chmod 600 /keys/authorized_keys
  fi

fi

exec "$@"
