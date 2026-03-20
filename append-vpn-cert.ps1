# Run this script after downloading the VPN client config
# Usage: .\append-vpn-cert.ps1 -OvpnFile "C:\path\to\downloaded-client-config.ovpn"

param(
    [Parameter(Mandatory=$true)]
    [string]$OvpnFile
)

$certFile = "C:\teraform\EKS Project\terraform\easy-rsa\easyrsa3\pki\issued\client1.domain.tld.crt"
$keyFile  = "C:\teraform\EKS Project\terraform\easy-rsa\easyrsa3\pki\private\client1.domain.tld.key"

# Extract only PEM block from cert (strip human-readable dump)
$certRaw = Get-Content $certFile -Raw
$certPem = [regex]::Match($certRaw, '-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----', [System.Text.RegularExpressions.RegexOptions]::Singleline).Value

$keyRaw = Get-Content $keyFile -Raw
$keyPem = [regex]::Match($keyRaw, '-----BEGIN PRIVATE KEY-----.*?-----END PRIVATE KEY-----', [System.Text.RegularExpressions.RegexOptions]::Singleline).Value

$append = @"

<cert>
$certPem
</cert>

<key>
$keyPem
</key>
"@

# Rewrite clean ovpn file without old cert/key blocks
$existing = Get-Content $OvpnFile -Raw
$clean = [regex]::Replace($existing, '<cert>.*?</cert>', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$clean = [regex]::Replace($clean, '<key>.*?</key>', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$clean = $clean.TrimEnd() + $append
Set-Content -Path $OvpnFile -Value $clean -NoNewline
Write-Host "Done! VPN config is ready: $OvpnFile"
