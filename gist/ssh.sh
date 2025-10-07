#!/usr/bin/env bash

SSH_USER=$(logname 2>/dev/null || echo "$USER")
SSH_USER_GROUP=sshusers
SSH_PORT=2249
ALIVE_INTERVAL_SEC=180
ALIVE_COUNT_MAX=3
SSH_CONFIG_PATH="/etc/ssh/sshd_config"

while [[ $# -gt 0 ]]; do
	case $1 in
	--ssh-port)
		if [[ -n $2 && $2 =~ ^[0-9]+$ ]]; then
			SSH_PORT="$2"
			shift 2
		else
			echo "❌ Error: --ssh-port requires a valid port number."
			exit 1
		fi
		;;
	*)
		echo "❌ Unknown argument: $1"
		echo "ℹ️ Usage: $0 [--ssh-port <port>]"
		exit 1
		;;
	esac
done

echo "███████╗███████╗██╗  ██╗"
echo "██╔════╝██╔════╝██║  ██║"
echo "███████╗███████╗███████║"
echo "╚════██║╚════██║██╔══██║"
echo "███████║███████║██║  ██║"
echo "╚══════╝╚══════╝╚═╝  ╚═╝"
echo "                        "

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
# NOTE: UsePAM yes, increases chance of unexpected behavior from PAM modules.
# Strictly needed it for AWS ec2 instances
echo "✍🏽️ Writing new SSH config..."
sudo tee "$SSH_CONFIG_PATH" <<EOF
# Specifies the file within the user's home directory where public keys are stored
# for authentication. The %h is replaced with the user's home directory. This tells
# the SSH server to look for authorized public keys in ~/.ssh/authorized_keys.
AuthorizedKeysFile %h/.ssh/authorized_keys

# Defines the SFTP subsystem used when a client requests an SFTP session. Using
# "internal-sftp" means the OpenSSH server uses a built-in SFTP implementation,
# improving security and removing dependence on an external binary.
Subsystem sftp internal-sftp

# Forces the use of SSH protocol version 2, which provides better security than
# the now-deprecated protocol version 1.
Protocol 2

# Sets the TCP port on which the SSH daemon listens. Replacing the default port 22
# with a variable ($SSH_PORT) allows running SSH on a non-standard port to reduce
# the visibility to automated scans.
Port $SSH_PORT

# Increases the verbosity of SSH server logs. Useful for debugging authentication issues
# or auditing access, as it logs detailed information about connections and actions.
LogLevel VERBOSE

# Restricts SSH login access to a specific user (defined by $SSH_USER). This prevents
# other system users from attempting to authenticate via SSH, reducing attack surface.
# AllowUsers $SSH_USER

# Enables integration with the system’s Pluggable Authentication Modules (PAM), which
# handle things like login restrictions, session limits, or 2FA, depending on the PAM setup.
UsePAM yes

# Restricts SSH login access to users who are members of the specified group(s).
# In this case, only users who are part of the "sshusers" group are permitted to log in via SSH.
# If a user is not in this group, even if they have valid credentials and keys, access is denied.
AllowGroups $SSH_USER_GROUP

PasswordAuthentication no

PubkeyAuthentication yes

# Begins a conditional block that applies only to the user specified by $SSH_USER.
# All nested directives under this block override global settings when this user connects.
# Match user $SSH_USER

    # Enables authentication using public keys. This allows the user to log in using
    # an SSH key pair rather than a password, which is generally more secure.
    # PubkeyAuthentication yes

    # Disables password authentication entirely for this user, ensuring that only
    # public key authentication is allowed. Helps prevent brute-force password attacks.
    # PasswordAuthentication no

# Prevents the root user from logging in over SSH. This is a best practice to minimize
# risk, as root login provides full system control and is often targeted in attacks.
PermitRootLogin no

# Disallows login attempts with empty passwords. Ensures that no account without
# a proper password (or key) can log in, even if the system user exists.
PermitEmptyPasswords no

# Disables challenge-response authentication mechanisms, such as keyboard-interactive
# logins, unless implemented via PAM. This further enforces key-only authentication.
ChallengeResponseAuthentication no

# Disables X11 forwarding over SSH, which prevents GUI applications from being
# displayed remotely. This improves security by reducing attack vectors.
X11Forwarding no

# Disables port forwarding, preventing the user from establishing network tunnels
# (e.g., forwarding local ports to remote services), which could be abused to bypass firewalls.
AllowTcpForwarding no

# Disables SSH agent forwarding, preventing the remote system from accessing
# the client's SSH agent and potentially misusing stored private keys.
AllowAgentForwarding no

# Defines the interval (in seconds) between keepalive messages sent by the server
# to the client. Helps detect broken or idle connections.
ClientAliveInterval $ALIVE_INTERVAL_SEC

# Specifies how many consecutive keepalive messages can be missed before the server
# disconnects the client. Together with ClientAliveInterval, this acts as an idle timeout mechanism.
ClientAliveCountMax $ALIVE_COUNT_MAX


# Limits the number of authentication attempts per connection to 2.
# After two failed attempts (e.g., wrong password or key), the connection is closed.
# This helps mitigate brute-force attacks by reducing the time window for guessing credentials.
MaxAuthTries 2

# Limits the number of multiplexed SSH sessions (e.g., via $(ControlMaster))
# per network connection to 2. This restricts how many concurrent channels
# (like shell, exec, or port forwarding) a user can open at once.
MaxSessions 2

# Sets the limit on concurrent unauthenticated connections. In this case:
# - The server allows 2 simultaneous unauthenticated connections.
# - Additional connection attempts are randomly dropped to prevent DoS attacks.
# Syntax: MaxStartups [start]:[rate]:[full]
# Setting it to a single number ("2") is shorthand for allowing only 2 unauthenticated connections before dropping others.
MaxStartups 2

# Disables Unix domain socket forwarding (e.g., for services like Docker or gpg-agent).
# Prevents clients from creating local socket tunnels to the server, improving isolation.
AllowStreamLocalForwarding no

# Disallows remote clients from binding forwarded ports to external interfaces (0.0.0.0).
# With this set to "no", SSH port forwarding can only bind to the loopback interface (127.0.0.1),
# preventing users from exposing internal services externally via GatewayPorts.
GatewayPorts no

# Prevents users from creating IP-level tunnels (e.g., with $(ssh -w) for tun/tap devices).
# Disabling this hardens the server against abuse of VPN-like features via SSH.
PermitTunnel no

# Disables TCP keepalive messages at the TCP protocol layer.
# When set to "no", the SSH server relies solely on SSH-level keepalives (e.g., ClientAliveInterval)
# to detect dead or idle connections.
# This reduces false disconnects caused by temporary network issues,
# but makes detection of stale sessions dependent on SSH keepalive settings.
TCPKeepAlive no
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
