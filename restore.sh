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

	if mv $name_in_bin $name_to_res ; then #rename file to original
		if mv "$BIN_PATH/$file_name" $dir_path ; then
			grep -wv "^$2" $RES_PATH > $TEMP_FILE
        	       	cat $TEMP_FILE > $RES_PATH
		else
			echo "Error, file:$name_in_bin not restored"
		fi
	else
		echo "Error, cant rename file:$name_in_bin"
	fi
}

function search_dir(){
	local dir_path=$(dirname $1)
	local file_name=$(basename $1)
	
	if [ ! -d $dir_path ] ; then
		return 2
	fi

	for file in $(ls -a $dir_path)
	do
		if [ $file = $file_name ] ; then
			return 0
		fi
	done

	return 1
}

function restore_dir(){
	local dir_path=$(dirname $1)
	local path_to_res=""

	if [ ! -d $dir_path ] ; then
		local dir_list=$(echo $dir_path | tr "/" " ")
		
		for dir in $dir_list
                do	
			path_to_res+="/${dir}"
			if [ ! -d $path_to_res ] ; then
				if [ -f $path_to_res ] ; then
					echo "File exist with the same directory name"
					read -p "Replace file with directory? " rep
					
					if [[ $rep =~ $REG_PAT ]] ; then
						rm $path_to_res
						mkdir $path_to_res
					else
						continue
					fi
				else
					mkdir $path_to_res
				fi
			fi	
		done	
	fi
}

function check_restore(){
	if grep -wq "^$1:" $RES_PATH ; then #Look for filename_inode
		file_path=$(grep -w "^$1:" $RES_PATH | cut -d: -f2) #Absolute file path
		name_w_node="$1"
			
		restore_dir $file_path

		if search_dir $file_path; then #if a file with same name exist in directory, prompt user for overwrite."
               		read -p "Do you want to overwrite? " rep

                	if [[ $rep =~ $REG_PAT ]] ; then #Check if user entered a word starting with Y or y.
				restore_file $file_path $name_w_node
                	else
                        	echo "File not restored"
                	fi
		elif [ $? -eq 2 ] ; then
			echo "Directory does not exist"
			return 1
		else
			restore_file $file_path $name_w_node
		fi
	else
		echo "file:$1 not in bin"
	fi
}

####Main####
if [ $# -lt 1 ] ; then
	echo "No filename provided"
	exit 1
fi

if [ ! -e $TEMP_FILE ] ; then
	touch $TEMP_FILE
fi

for i in $*
do
        check_restore $i
done

/bin/bash $HOME/project/test.sh
