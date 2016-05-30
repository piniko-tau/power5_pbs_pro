#!/bin/bash
echo ""

echo $1
echo ""

qmgr -c "p q $1"|grep queue_type|sed 's/.*= //g'
echo ""

qmgr -c "p q $1"|grep -q acl && printf "acl_users : "||echo "acl_users : Open"

qmgr -c "p q $1"|grep acl_users|awk '{print $6}'|paste -s -d','||echo "none"
echo ""

qmgr -c "p q $1"|grep -v '#\|queue_type\|enabled\|started\|acl_user'|cut -d' ' -f4-|sed 's/resources_//g'
echo ""

printf "nodes: "
grep $1 nodes_filtered|awk '{print $1}'|sed 's/compute-0-//g'|paste -s -d','

printf "\ncpu count : "
grep $1 nodes_filtered|awk '{print $2}'|sed 's/np=//g'|paste -s -d+|bc
echo ""

