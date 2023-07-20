#!/bin/bash

RES_PATH="$HOME/.restore.info"
BIN_PATH="$HOME/recyclebin"
TEMP_FILE="$HOME/project/tmp"
REG_PAT="^[Yy]+"

function restore_file(){
	local dir_path=$(dirname $1)
	local file_name=$(basename $1)
	echo "Dir: $dir_path"
	echo "In bin: $BIN_PATH/$2"
	echo "New bin: $BIN_PATH/$file_name"

	if mv "$BIN_PATH/$2" "$BIN_PATH/$file_name" ; then
		if mv "$BIN_PATH/$file_name" $dir_path ; then
			grep -wv "$2" $RES_PATH > $TEMP_FILE
        	        cat $TEMP_FILE > $RES_PATH
		else
			"Error, file not restored"
			exit 1
		fi
	else
		"Error, file not restored"
		exit 1
	fi

	#echo $file_name
	#echo $dir_path
}

function search_dir(){
	local dir_path=$(dirname $1)
	local file_name=$(basename $1)

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
		#echo "file found"
		name_w_node="$1"
		file=$(grep -w "$name_w_node:" $RES_PATH | cut -d: -f2) #Absolute file path
		#echo $name_w_node
		if search_dir $file; then
               		read -p "Do you want to overwrite? " rep

                	if [[ $rep =~ $REG_PAT ]] ; then #Check if user entered a word starting with Y or y.
                        	#echo "File restored"
				restore_file $file $name_w_node
                	else
                        	echo "File not restored"
                	fi
		else
			restore_file $file $name_w_node
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
