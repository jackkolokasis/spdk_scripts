# SPDK RAM Disk Scripts

## Overview
This repository contains two scripts designed to set up and connect to an SPDK RAM disk target:

1. **`ramdisk_spdk.sh`** - Creates and runs an SPDK RAM disk target.
2. **`connect.sh`** - Connects to the running SPDK RAM disk target.

These scripts help automate the process of setting up an SPDK-based RAM disk and establishing a connection to it.

---

## Prerequisites
Before using these scripts, ensure the following dependencies are met:

- A system with SPDK installed and configured
- `nvme-cli` for connecting to the NVMe target
- Proper kernel modules loaded (e.g., `uio`, `vfio-pci` for SPDK)
- Root privileges (or proper user permissions) for running SPDK

---

## Usage Instructions

### 1. Setting Up the Target (`ramdisk_spdk.sh`)
This script initializes and runs an SPDK RAM disk target. 

#### Running the script:
```sh
sudo ./ramdisk_spdk.sh
```

#### What this script does:
- Starts the SPDK application (`spdk_tgt`)
- Creates a RAM disk-backed NVMe target using SPDK
- Exposes the target over NVMe-oF

After successful execution, the RAM disk target should be running and accessible.

---

### 2. Connecting to the Target (`connect.sh`)
Once the RAM disk target is up and running, use `connect.sh` to establish a connection.

#### Running the script:
```sh
sudo ./connect.sh
```

#### What this script does:
- Discovers available NVMe-oF targets
- Connects to the specified NVMe target
- Verifies the connection

After execution, the RAM disk should be accessible as an NVMe device (e.g., `/dev/nvmeXnY`).

---

## Troubleshooting
- If the target does not start, ensure that SPDK is correctly installed and configured.
- If the connection fails, verify that the target is running and that the correct NVMe transport (e.g., `tcp`) is being used.
- Check system logs (`dmesg` or `journalctl -xe`) for errors related to NVMe-oF.
- Ensure proper network setup if using NVMe over TCP.

---

## Additional Information
For more details on SPDK, refer to the official documentation:
- [SPDK Documentation](https://spdk.io/doc/)
- [SPDK GitHub Repository](https://github.com/spdk/spdk)

If modifications are needed, edit the scripts to match your system's configuration (e.g., IP addresses, transport type, and storage size).

---
