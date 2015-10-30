#!/bin/bash

nodebug=""
nodebug=" >/dev/null"

folder=`echo $1 | tr -cd "[:alpha:][:digit:]_-" | sed -rn 's/(.{1,50}).*/\1/p'`
hosts="t1 t2"
master_host="master"
destination="pig-backups"

#if folder not exist
if [ ! -d $destination ]
then

    #creating backup folder
    cmd="echo $exitcode $nodebug"; eval $cmd
    cmd="echo \"we are going to create $destination to store backup files\" $nodebug"; eval $cmd
    mkdir $destination
    # mkdir -p $destination      # this is more flexible but need more attention to value
    exitcode=$?
    if [ $exitcode -ne 0 ]
    then
        echo "folder $destination creation failure"
        echo "process terminated"
        exit 1
    else
        cmd="echo folder creation success \(exitcode $exitcode\) $nodebug"; eval $cmd
        cmd="ls -dl $destination $nodebug"; eval $cmd
    fi

    #setting rwx......(700) permission to temp folder

    echo
    echo "we are going to set 700 permission to  $destination"
    chmod 700 $destination
    exitcode=$?
    if [ $exitcode -ne 0 ]
    then
        echo "unable to set 700 permission to  $destination"
        echo "process terminated"
        exit 1
    else
        cmd="echo folder permission is set $nodebug"; eval $cmd
        cmd="ls -dl $destination $nodebug"; eval $cmd
    fi
else
    cmd="echo directory exist.....OK $nodebug"; eval $cmd
    cmd="ls -dl $destination $nodebug"; eval $cmd
fi



cmd="echo \"folder to copy = $folder\" $nodebug"; eval $cmd
for each_host in $hosts
do
        cmd="echo \"backup folder $folder from $each_host\" $nodebug"; eval $cmd
        cmd="echo $nodebug"; eval $cmd

        run_at_host="ssh pig@$each_host \"tar -cf - $folder | ssh pig@$master_host dd of=$destination/$each_host.backup.tar\" 2>$destination/$each_host.report.txt"
        #test command, need to backslash more sign to show whole string
        #cmd="echo $run_at_host $nodebug"; eval $cmd
        eval $run_at_host
        exitcode=$?
        if [ $exitcode -ne 0 ]
        then
                echo "copy $folders from $each_host complete with error, see $destination/$each_host.report.txt"
                echo "lets try on next host"
        else
                cmd="echo copy $folders from $each_host complete with success $nodebug"; eval $cmd
                cmd="ls -dl $destination $nodebug"; eval $cmd
        fi

done
