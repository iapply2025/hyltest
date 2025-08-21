#!/usr/bin/env bash
set -euo pipefail

ADMIN_USER="${ADMIN_USER:-rocky}"
APP_PRIV_IP="${APP_PRIV_IP:?must set}"
SSH_PRIV_KEY_B64="${SSH_PRIV_KEY_B64:?must set}"

sudo dnf -y install python3 ansible-core git jq

cd /opt/stack/repo/ansible
ansible-galaxy collection install ansible.posix -p ./collections >/dev/null 2>&1 || true
export ANSIBLE_COLLECTIONS_PATHS=./collections

# SSH setup
USER_HOME="/home/$ADMIN_USER"
if [ ! -d "$USER_HOME" ]; then
  USER_HOME=/root
  ADMIN_USER=root
fi
install -d -m 700 "$USER_HOME/.ssh"
printf "%s" "$SSH_PRIV_KEY_B64" | base64 -d > "$USER_HOME/.ssh/id_rsa"
chmod 600 "$USER_HOME/.ssh/id_rsa"
chown -R "$ADMIN_USER:$ADMIN_USER" "$USER_HOME/.ssh" || true

# pre-accept host key
ssh-keyscan -T 15 -H "$APP_PRIV_IP" >> "$USER_HOME/.ssh/known_hosts" 2>/dev/null || true
chown "$ADMIN_USER:$ADMIN_USER" "$USER_HOME/.ssh/known_hosts" || true

cat > inventory.ini <<EOF
[app]
app ansible_host=$APP_PRIV_IP ansible_user=$ADMIN_USER ansible_ssh_private_key_file=$USER_HOME/.ssh/id_rsa ansible_python_interpreter=/usr/bin/python3
EOF
cat inventory.ini

ANSIBLE_HOST_KEY_CHECKING=False \
ansible-playbook -i inventory.ini playbook.yml -vv
