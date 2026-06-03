#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
# Disable all cluster-related services and GFS2 filesystem on next boot
# Run as root on EACH node of the 2-node RHEL8 cluster

echo "=== Disabling cluster services on next boot ==="

# Disable pacemaker and corosync (core cluster stack)
echo "Disabling pacemaker..."
systemctl disable pacemaker
echo "Disabling corosync..."
systemctl disable corosync

# Disable pcsd (pacemaker/corosync configuration daemon)
echo "Disabling pcsd..."
systemctl disable pcsd

# Disable dlm (Distributed Lock Manager - required by GFS2)
echo "Disabling dlm..."
systemctl disable dlm

# Disable clvmd / lvmlockd if present (clustered LVM)
for svc in clvmd lvmlockd lvm2-lvmlockd; do
    if systemctl list-unit-files "${svc}.service" &>/dev/null; then
        echo "Disabling ${svc}..."
        systemctl disable "${svc}" 2>/dev/null || true
    fi
done

echo ""
echo "=== Disabling GFS2 filesystem mounts ==="

# Comment out any GFS2 entries in /etc/fstab
if grep -q 'gfs2' /etc/fstab; then
    echo "Commenting out GFS2 entries in /etc/fstab..."
    cp /etc/fstab /etc/fstab.bak.$(date +%Y%m%d%H%M%S)
    sed -i '/gfs2/s/^/#/' /etc/fstab
    echo "Backup saved as /etc/fstab.bak.*"
else
    echo "No GFS2 entries found in /etc/fstab (may be managed by cluster resources)"
fi

echo ""
echo "=== Verification ==="
echo "Service status (enabled/disabled):"
for svc in pacemaker corosync pcsd dlm; do
    status=$(systemctl is-enabled "${svc}" 2>/dev/null || echo "not found")
    printf "  %-20s %s\n" "${svc}" "${status}"
done

echo ""
echo "Current /etc/fstab GFS2 lines:"
grep -i 'gfs2' /etc/fstab || echo "  (none or all commented out)"

echo ""
echo "Done. Run this script on BOTH nodes."
