#!/bin/bash
chmod a+rwx -R /sys/fs/cgroup/cpu,cpuacct
chmod a+rwx -R /sys/fs/cgroup/devices
local_dirs=$(bdconfig get_property_value \
    --configuration_file /etc/hadoop/conf/yarn-site.xml \
    --name yarn.nodemanager.local-dirs 2>/dev/null)
mod_local_dirs=${local_dirs//\,/ }
chmod a+rwx -R ${mod_local_dirs}
