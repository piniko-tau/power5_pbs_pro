#!/bin/bash
for i in `grep $1 /root/power5_pbspro_configs_git/nodes/nodesp2|awk '{print $1}'`
do 
qmgr -c "set node $i resources_available.Qlist += $1 "
done

echo "now execute : qmgr -c \"set queue queue_name default_chunk.Qlist = queue_name\"" 
