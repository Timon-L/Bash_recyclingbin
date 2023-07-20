#!/bin/bash

BIN_PATH="$HOME/recyclebin"
RES_PATH="$HOME/.restore.info"
SCRIPT_PATH="$HOME/project/recycle.sh"

function init_check(){
        if [ ! -e $BIN_PATH ] ; then
                mkdir $BIN_PATH
                echo "New bin @$BIN_PATH"
        fi
	if [ ! -e $RES_PATH ] ; then
		touch $RES_PATH
	fi
}

function check_file(){
	if [ ! -e $1 ] ; then
		echo "File does not exist. "
        	exit 1
        fi

	if [ $(realpath -e $i) = $SCRIPT_PATH ] ; then
		echo "Attempting to delete recycle - operation aborted"
		exit 1
	elif [ -d $i ] ; then
		echo "Directory name provided instead of a filename. "
		exit 1
	fi

	return 0
}

function write_to_restore(){
	file_name=$(basename $ABS_PATH)
	inode=$(stat -c '%i' $ABS_PATH)
	name_w_inode=$file_name"_"$inode
	if [ ! $? ] ; then
		echo "Abort: error with file"
	fi
	echo "$name_w_inode:$ABS_PATH" >> $RES_PATH #write to .restore.info, format: NAME_INODE:PATH
}

function move_to_bin(){
	DIR=$(dirname $ABS_PATH)
	NEW_ABS=$DIR"/"$name_w_inode
	#echo $ABS_PATH
	#echo $NEW_ABS
	mv $ABS_PATH $NEW_ABS #rename current file
	mv $NEW_ABS $BIN_PATH
}

####Main####
init_check

if [ $# -lt 1 ] ; then
	echo "No file provided"
	exit 1
fi

for i in $*
do
	if check_file $i ; then
		#echo "File is valid"
		ABS_PATH=$(realpath -e $i)
		#echo $ABS_PATH
		if [ $? ] ; then
			write_to_restore
			move_to_bin
		else
			echo "Error"
			exit 1
		fi
	fi
done
