for i in  `pbsnodes -a|grep ^compute` ;do echo ssh -q $i "puppet agent -t";done|parallel -j 5
