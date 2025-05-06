#!/usr/bin/env bash

SSH_USER=$(logname 2>/dev/null || echo "$USER")
SSH_PORT=2249
ALIVE_INTERVAL_SEC=180
ALIVE_COUNT_MAX=3
SSH_CONFIG_PATH="/etc/ssh/sshd_config"

echo "███████╗███████╗██╗  ██╗";
echo "██╔════╝██╔════╝██║  ██║";
echo "███████╗███████╗███████║";
echo "╚════██║╚════██║██╔══██║";
echo "███████║███████║██║  ██║";
echo "╚══════╝╚══════╝╚═╝  ╚═╝";
echo "                        ";

# Ensure the user exists
if ! id "$SSH_USER" &>/dev/null; then
    echo "❌ Error: User '$SSH_USER' does not exist."
    echo "➡️ Create it first: sudo useradd -m $SSH_USER && sudo passwd $SSH_USER"
    exit 1
fi

# Backup current SSH config
echo "📦 Backing up existing SSH config..."
TIMESTAMP=$(date +"%d-%B-%Y_%H-%M-%S")
BACKUP_PATH="${SSH_CONFIG_PATH}.bak_${TIMESTAMP}"
sudo cp "$SSH_CONFIG_PATH" "$BACKUP_PATH"
echo "✅ Backup created: $BACKUP_PATH"

# Clear existing config safely
echo "🧹 Clearing out existing SSH config..."
sudo truncate -s 0 "$SSH_CONFIG_PATH"

# Write new SSH config
echo "✍🏽️ Writing new SSH config..."
sudo tee "$SSH_CONFIG_PATH" <<EOF
AuthorizedKeysFile %h/.ssh/authorized_keys
Subsystem sftp internal-sftp
Protocol 2
Port $SSH_PORT
LogLevel VERBOSE
AllowUsers $SSH_USER
UsePAM yes

Match user $SSH_USER
    PubkeyAuthentication yes
    PasswordAuthentication no
PermitRootLogin no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
ClientAliveInterval $ALIVE_INTERVAL_SEC
ClientAliveCountMax $ALIVE_COUNT_MAX
EOF

# Validate SSH configuration before restarting
echo "🔍 Validating new SSH config..."
if ! sudo sshd -t; then
    echo "❌ Error: SSH configuration test failed. Restoring previous config..."
    sudo cp "$BACKUP_PATH" "$SSH_CONFIG_PATH"
    sudo systemctl restart sshd || sudo systemctl restart ssh
    exit 1
fi

# Detect the correct SSH service
if systemctl list-unit-files | grep -q "sshd.service"; then
    SSH_SERVICE="sshd"
elif systemctl list-unit-files | grep -q "ssh.service"; then
    SSH_SERVICE="ssh"
else
    echo "❌ Error: Neither 'sshd' nor 'ssh' service is available."
    exit 1
fi

# Ensure firewall allows SSH
# if command -v ufw &>/dev/null; then
#     sudo ufw allow "$SSH_PORT"/tcp
#     echo "✅ Opened SSH port $SSH_PORT in UFW"
# elif command -v firewall-cmd &>/dev/null; then
#     sudo firewall-cmd --permanent --add-port="$SSH_PORT"/tcp
#     sudo firewall-cmd --reload
#     echo "✅ Opened SSH port $SSH_PORT in Firewalld"
# else
#     echo "⚠️ No firewall tool detected (ufw/firewalld). Ensure SSH port $SSH_PORT is open manually!"
# fi

# Restart SSH safely
echo "⌛ Restarting SSH service..."
sudo systemctl restart "$SSH_SERVICE"

echo "✅ SSH setup completed successfully on PORT=$SSH_PORT for USER=$SSH_USER 🎉"
echo "🛑 Please make sure PORT=$SSH_PORT is open in your firewall before logging out of this session. 🛑"
echo "🟨 Also make sure to restart ssh if you decide to change PORT=$SSH_PORT using: sudo systemctl restart $SSH_SERVICE 🟨"
