#!/bin/bash

RES_PATH="$HOME/.restore.info"
BIN_PATH="$HOME/recyclebin"
TEMP_FILE="$HOME/project/tmp"
REG_PAT="^[Yy]+"

function restore_file(){
	local dir_path=$(dirname $1)
	local file_name=$(basename $1)
	local name_in_bin="$BIN_PATH/$2"
	local name_to_res="$BIN_PATH/$file_name"
	echo "Arg1: $1"
	echo "name in bin: $name_in_bin"
	echo "file name in res: $file_name"
	echo "file name to restore: $name_to_res"

	if mv $name_in_bin $name_to_res ; then #rename file to original
		#if mv "$BIN_PATH/$file_name" $dir_path ; then
			#grep -wv "$2" $RES_PATH > $TEMP_FILE
        	       	#cat $TEMP_FILE > $RES_PATH
		#else
			#echo "Error, file not restored"
			#exit 1
		#fi
		echo "CONT"
	else
		echo "Error, cant rename file"
		exit 1
	fi

	#echo $file_name
	#echo $dir_path
}

function search_dir(){
	local dir_path=$(dirname $1)
	local file_name=$(basename $1)
	
	#echo $dir_path
	#echo $file_name
	for file in $(ls $dir_path)
	do
		if [ $file = $file_name ] ; then
			return 0
		fi
	done

	return 1
}

function check_restore(){
	if grep -wq "$1:" $RES_PATH ; then #Look for filename_inode
		file_path=$(grep -w "$1:" $RES_PATH | cut -d: -f2) #Absolute file path
		echo $file_path
		name_w_node="$1"
		#echo $name_w_node
		if search_dir $file_path; then
               		read -p "Do you want to overwrite? " rep

                	if [[ $rep =~ $REG_PAT ]] ; then #Check if user entered a word starting with Y or y.
                        	#echo "File restored"
				restore_file $file_path $name_w_node
                	else
                        	echo "File not restored"
                	fi
		else
			restore_file $file_path $name_w_node
		fi
	else
		echo "file not in bin"
		exit 1
	fi
}

####Main####
if [ $# -lt 1 ] ; then
	echo "No filename provided"
	exit 1
fi

check_restore $1
