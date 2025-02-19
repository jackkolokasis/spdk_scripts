#!/usr/bin/env bash

# NVMe-oF parameters
NQN="nqn.2016-06.io.spdk:cnode1"
TARGET_IP="192.168.5.121"
PORT="4420"

# Function to connect to the NVMe-oF target
connect_nvme() {
    echo "Connecting to NVMe-oF target..."
    sudo nvme connect -t rdma -n "$NQN" -a "$TARGET_IP" -s "$PORT"
    if [ $? -eq 0 ]; then
        echo "Successfully connected to NVMe target."
    else
        echo "Failed to connect to NVMe target." >&2
        exit 1
    fi
}

# Function to disconnect from the NVMe-oF target
disconnect_nvme() {
    echo "Disconnecting from NVMe-oF target..."
    sudo nvme disconnect -n "$NQN"
    if [ $? -eq 0 ]; then
        echo "Successfully disconnected from NVMe target."
    else
        echo "Failed to disconnect from NVMe target." >&2
        exit 1
    fi
}

# Parse command-line options
while getopts ":cd" opt; do
    case ${opt} in
        c)
            connect_nvme
            exit 0
            ;;
        d)
            disconnect_nvme
            exit 0
            ;;
        *)
            echo "Usage: $0 -c (connect) | -d (disconnect)"
            exit 1
            ;;
    esac
done

# If no arguments are provided, display usage
echo "Usage: $0 -c (connect) | -d (disconnect)"
exit 1
