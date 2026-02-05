# Resolve user and key path dynamically
$user    = $env:USERNAME
$keyPath = Join-Path $env:USERPROFILE ".ssh\id_rsa"

Write-Output "Fixing permissions on: $keyPath"
Write-Output "Current user: $user"

# Remove inherited permissions
icacls "$keyPath" /inheritance:r

# Grant read-only to current user
icacls "$keyPath" /grant:r "$user:R"

# Remove all other typical principals
icacls "$keyPath" /remove "Everyone" "Users" "Authenticated Users" "Administrators" "SYSTEM"

# Verify resulting ACL
icacls "$keyPath"
