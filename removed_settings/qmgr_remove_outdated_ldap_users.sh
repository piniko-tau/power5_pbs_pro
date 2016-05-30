#!/bin/bash
for i in `qmgr -c 'p s'|grep acl_users|awk '{print $6}'`


do ldapsearch -x -LLL uid=$i|grep -q 'gateLoginShell: /bin/false' && grep $i ./qmgr_19_5|sed 's/+/-/g'>>outdated_users_list`date +%m.%d.%y`


done

qmgr < ./outdated_users_list`date +%m.%d.%y`

