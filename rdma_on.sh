#!/usr/bin/env bash
modprobe nvme_fabrics
modprobe ib_cm
modprobe ib_core
# Please note that ib_ucm does not exist in newer versions of the kernel and is not required.
#modprobe ib_ucm || true
modprobe ib_umad
modprobe ib_uverbs
modprobe iw_cm
modprobe rdma_cm
modprobe rdma_ucm
modprobe nvme_rdma
modprobe configfs
modprobe nvme
