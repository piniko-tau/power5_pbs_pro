#!/bin/bash -l

printf "\nPer queue core usage :\n"
for q in `qstat -q|awk '{if ($6 > 0)  print $0}'|grep -v Queue|awk '{print $1}'`
do
Q=$q
if [[ "$q" = "tamir-short" ]];then Q=tamir-sh;fi
printf "\n`qstat -n -1|grep -w R |grep $Q |awk '{s+=$7}END{print $3" usage : "s}'`/`count_queue_cores.sh $q|awk '{print $6}'`\n" 
done
echo ""
