#!/bin/bash

BIN_PATH="$HOME/recyclebin"
RES_PATH="$HOME/.restore.info"
SCRIPT_PATH="$HOME/project/recycle.sh"
RESTORE_PATH="$HOME/project/restore.sh"
TEMP_FILE="$HOME/project/tmp"
REG_PAT="^[Yy]+"
opt_v_flag=false
opt_i_flag=false
opt_r_flag=false
file_moved_flag=false

function init_check(){
        if [ ! -e $BIN_PATH ] ; then
                mkdir $BIN_PATH
        fi
	if [ ! -e $RES_PATH ] ; then
		touch $RES_PATH
	fi
	if [ ! -e $TEMP_FILE ] ; then #Create temp file to store restore.info
		touch $TEMP_FILE
	fi
}

function set_flags(){
	while getopts :ivr opt
	do
		case $opt in
			i) opt_i_flag=true;;
			v) opt_v_flag=true;;
			r) opt_r_flag=true;;
			*) echo invalid option - $OPTARG
			   exit 1;;
		esac
	done
}

function recur_recycle(){
	local abs_dir=$(realpath -e $1)
	local dir_arr=()

	for file in $(ls -aR $abs_dir)
	do	
		if [ -f "$abs_dir/$file" ] ; then
			local f_path=$(realpath -e $abs_dir/$file)
			if $opt_i_flag ; then
                       		interactive_mode $f_path
	                else
                        	write_to_restore $f_path
                        	move_to_bin $f_path
                        	file_moved_flag=true
        	        fi
		elif [ -d "$abs_dir/$file" ] ; then
			continue
		else	
			abs_dir=${file::-1} #Line that is not a dir or file, used as absolute path to file, remove colon from last pos.
			dir_arr+=($abs_dir)
		fi

		verbose_mode $file_moved_flag
		file_moved_flag=false
	done
	
	local len=${#dir_arr[@]}

	for ((i=(len-1); i>=0; i--))
       	do
		if [ $(find ${dir_arr[$i]} -type f | wc -l) -le 0 ] ; then
			rmdir ${dir_arr[$i]}
		else
			echo "${dir_arr[$i]} is not empty, directory not deleted"
		fi		
	done
}

function check_file(){
	if [ ! -e $1 ] ; then
		echo "File:$1 does not exist. "
		return 1
        fi

	if [ $(realpath $1) = $SCRIPT_PATH ] ; then
		echo "Attempting to delete recycle script - operation aborted"
		exit 1
	elif [ $(realpath $1) = $RESTORE_PATH ] ; then
		echo "Attempting to delete restore script - operation aborted"
		exit 1
	elif [ -d $1 ] ; then #Check if file is directory, if recursive opt is on, use function to remove files"
		if $opt_r_flag ; then
			recur_recycle $1
		else
			echo "Directory name:$1 provided instead of a filename. "
		fi
		return 1
	fi

	return 0
}

function write_to_restore(){
	file_name=$(basename $1)
	inode=$(stat -c '%i' $1)
	name_w_inode=$file_name"_"$inode

	if [ $? -ne 0 ] ; then
		echo "Abort: error with file"
		exit 1
	fi
	echo "$name_w_inode:$1" >> $RES_PATH #write to .restore.info, format: NAME_INODE:PATH
}

function move_to_bin(){
	DIR=$(dirname $1)
	NEW_ABS=$DIR"/"$name_w_inode

	if mv $1 $NEW_ABS 2> /dev/null ; then #rename current file
		if ! mv $NEW_ABS $BIN_PATH 2> /dev/null ; then
			echo "Can't recycle bin."
			exit 1	
		fi
	else
		echo "Can't rename file."
		exit 1
	fi
}

function verbose_mode(){
        if $opt_v_flag ; then
		if $1 ; then
                        echo "*****************************************************************"
                        echo "$ABS_PATH recycled, now in bin: $BIN_PATH"
                        echo "Record .restore.info updated"
                        echo "*****************************************************************"
                else
                        echo "*****************************************************************"
                        echo "$ABS_PATH not recycled"
                        echo "*****************************************************************"
                fi
        fi
}

function interactive_mode(){
	read -p "Do you want to recycle $1: " resp

	if [[ $resp =~ $REG_PAT ]] ; then #Check if user entered a word starting with Y or y.
        	write_to_restore $1
		move_to_bin $1
		file_moved_flag=true
	fi
}

####Main####
init_check

if [ $# -lt 1 ] ; then
	echo "No file provided"
	exit 1
fi

set_flags $*
shift $[OPTIND-1]

for i in $*
do
	if check_file $i ; then
		ABS_PATH=$(realpath -e $i)
		if [ ! $? ] ; then
			echo "Error when find real path"
			exit 1
		fi		

		if $opt_i_flag ; then
			interactive_mode $ABS_PATH
		else
			write_to_restore $ABS_PATH
			move_to_bin $ABS_PATH
			file_moved_flag=true
		fi
	fi
	verbose_mode $file_moved_flag

	file_moved_flag=false
done

/bin/bash $HOME/project/test.sh
