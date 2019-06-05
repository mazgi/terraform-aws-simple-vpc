#!/bin/bash -eu

readonly now=$(date +%Y%m%d-%H%M%S)
readonly numjobs=$(($(nproc) + 1))
readonly base_dir='/mnt'
readonly result_dir=fio.$now.result

echo mkdir -p $result_dir

for path in $(ls -1 $base_dir/)
do
  for readwrite in "read" "write" "randread" "randwrite"
  do
    for blocksize in 4k 32m
    do
      name=$(printf "job.%s.%s.%s-%s" $now $path $readwrite $blocksize)
      filename=$base_dir/$path/fio.$name.img
      echo fio --output=$result_dir/$name.out.txt --name=$name --filename=$filename --direct=1 --readwrite=$readwrite --blocksize=$blocksize --size=1G --runtime=30 --numjobs=$numjobs --group_reporting
    done
  done
done
