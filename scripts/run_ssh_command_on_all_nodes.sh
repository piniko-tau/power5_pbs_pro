for i in  `pbsnodes -a|grep ^compute` ;do ssh -q $i "$@";done
#|parallel -j 5
