#!/bin/bash

function printTest(){
	echo "File in .restore.fin: "
	cat ~/.restore.info
	echo " "
	
	echo "File in recyclebin: "
	ls ~/recyclebin
	echo " "

	echo "File in temp: "
	ls -R ./temp
}

####Main####
printTest
