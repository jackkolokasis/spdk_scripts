#!/bin/bash

#### ~YOU NEED ROOT PRIVILEGES TO RUN THIS SCRIPT~ ####
#
#
#### ~MOVE THIS SCRIPT INSIDE THE SPDK TOP FOLDER~ ####

python3 scripts/rpc.py bdev_nvme_detach_controller nvme0
python3 scripts/rpc.py bdev_malloc_delete Malloc0

# Find and kill nvmf_tgt processes
nvmf_pids=$(pgrep -f "build/bin/nvmf_tgt -m")

if [ -n "$nvmf_pids" ]; then
    echo "Found nvmf_tgt processes with PIDs: $nvmf_pids"
    echo "Killing nvmf_tgt processes..."
    kill -9 $nvmf_pids
    echo "nvmf_tgt processes killed."
else
    echo "No nvmf_tgt processes found."
fi

nvmf_pids=$(pgrep -f "build/bin/nvmf_tgt -g -m")

if [ -n "$nvmf_pids" ]; then
    echo "Found nvmf_tgt processes with PIDs: $nvmf_pids"
    echo "Killing nvmf_tgt processes..."
    kill -9 $nvmf_pids
    echo "nvmf_tgt processes killed."
else
    echo "No nvmf_tgt processes found."
fi

# Find and kill nvmf_tgt processes
nvmf_pids=$(pgrep -f "build/bin/spdk_tgt")

if [ -n "$nvmf_pids" ]; then
    echo "Found spdk_tgt processes with PIDs: $nvmf_pids"
    echo "Killing spdk_tgt processes..."
    kill -9 $nvmf_pids
    echo "spdk_tgt processes killed."
else
    echo "No spdk_tgt processes found."
fi
sudo ./scripts/setup.sh cleanup
#./dpdk/usertools/dpdk-hugepages.py --clear
CLEAR_HUGE=yes ./scripts/setup.sh
sudo ./scripts/setup.sh reset
