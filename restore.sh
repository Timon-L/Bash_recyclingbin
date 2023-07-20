#!/bin/bash

RES_PATH="$HOME/.restore.info"
BIN_PATH="$HOME/recyclebin"
TEMP_FILE="$HOME/project/tmp"
REG_PAT="^[Yy]+"

function restore_file(){
	local dir_path=$(dirname $1)
	local file_name=$(basename $1)

	mv "$BIN_PATH/$file_name" $dir_path

	#echo $file_name
	#echo $dir_path

	if [ $? ] ; then
		grep -wv "$2" $RES_PATH > $TEMP_FILE
		cat $TEMP_FILE > $RES_PATH
	else
		echo "Erro, file not restored"
		exit 1
	fi

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
		file=$(grep -w "$1:" $RES_PATH | cut -d: -f2) #Absolute file path
		name_w_node="$1:"
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
