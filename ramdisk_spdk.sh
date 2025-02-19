#!/usr/bin/env bash

check_status() {
    local return_code="$1"  # First argument: Actual return code
    local message="$2"       # Second argument: Custom message

    if [ "$return_code" -eq 0 ]; then
        echo -e "$message \e[32m[SUCCESS]\e[0m"
        return 0
    else
      echo -e "$message \e[31m[FAIL]\e[0m (Error Code: $return_code)"
      return 1
    fi
}

# Allocate 100 GB of 2 MB hugepages on NUMA node 0 and 100 GB on NUMA node 1, ensuring
# each socket gets its own local hugepage pool for optimal performance on a dual-socket system.
./dpdk/usertools/dpdk-hugepages.py -p 2M --setup 100G
check_status $? "Hugepages setup"

# ./dpdk/usertools/dpdk-hugepages.py -p 2M --setup 100G --node 1
# check_status $? "Hugepages setup numa node 1"

HUGEMEM=204800 HUGE_EVEN_ALLOC=yes ./scripts/setup.sh
check_status $? "Setup"

# Launch the SPDK NVMe-oF target in the background with root privileges.
# -g uses a single file for hugepage memory segments.
# -m binds SPDK's poll-mode reactors to CPU cores 0 through 11 for better performance.
sudo build/bin/nvmf_tgt -g -m 0xFFFF &
check_status $? "Launch the SPDK NVMe-oF target in the background"
# Wait for nvmf_tgt to start up
sleep 4

# Desired device size in GiB
SIZE_GIB=50
# Block size in bytes
BLOCK_SIZE=4096
# Convert GiB to bytes: (200 GiB = 200 * 2^30 bytes)
SIZE_MBYTES=$(( SIZE_GIB * 1024 ))

./scripts/rpc.py bdev_malloc_create -b Malloc0 "$SIZE_MBYTES" "$BLOCK_SIZE"
check_status $? "Malloc ramdisk"

# Create RDMA transport
./scripts/rpc.py nvmf_create_transport -t RDMA
check_status $? "Create transport"

# Create a new NVMe-oF subsystem with the specified NQN, allowing connections from any host (-a),
# and set its serial number (-s) to "SPDK00000000000001" and model/controller name (-d) to "SPDK_Controller1".
./scripts/rpc.py nvmf_create_subsystem nqn.2016-06.io.spdk:cnode1 -a -s SPDK00000000000001 -d SPDK_Controller1
check_status $? "Create a new NVMe-oF subsystem"

# Add the block device "Malloc0" as a namespace to the NVMe-oF subsystem "nqn.2016-06.io.spdk:cnode1",
# making "Malloc0" accessible to any host connecting to this subsystem.
./scripts/rpc.py nvmf_subsystem_add_ns nqn.2016-06.io.spdk:cnode1 Malloc0
check_status $? "Add the block device as a namespace to the NVMe-oF subsystem"

# Allow any host to connect to the subsystem
./scripts/rpc.py nvmf_subsystem_allow_any_host -e nqn.2016-06.io.spdk:cnode1
check_status $? "Allow any host to connect"

# Add a new listener (portal) to the NVMe-oF subsystem "nqn.2016-06.io.spdk:cnode1" using the RDMA transport (-t rdma),
# listening on IP address 192.168.5.126 (-a) and port 4420 (-s).
./scripts/rpc.py nvmf_subsystem_add_listener nqn.2016-06.io.spdk:cnode1 -t rdma -a 192.168.5.121 -s 4420
check_status $? "Add a new listener (portal) to the NVMe-oF subsystem"
