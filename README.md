# disposable-vpn-via-ssh

This script creates a short-lived VM in your GCP account and creates a VPN-like connection to it via SSH. You can specify where to spawn the VM if you need a connection to a specific country.

When done, the script will delete the VM for you.

From zero to VPN in less than 20 seconds.

## Requirements
- [sshuttle](https://github.com/sshuttle/sshuttle)

## How to run

```bash
GCP_PROJECT=[my-project] ./up.sh [country-code]
```

e.g., to connect to a server in The Netherlands:

```bash
GCP_PROJECT=[my-project] ./up.sh nl
```
