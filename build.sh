#!/bin/bash
# Copyright (c) Rolf Jagerman, Laurens Versluis and Martijn de Vos, 2014.
# This script first checks if certain folders and files exist. It first builds kivy and then the whole app (after kivy is set) because of some error with binaries.
# The main and build functions should be reviewed first.

# Load variables
source buildconfig.conf
source functions.sh

while getopts ":p:a:" opt; do
	case $opt in
		p)
			PY4APATH=$OPTARG
			;;
		a)
			APPNAME=$OPTARG
			;;
	esac
done

if [ "X$PY4APATH" == "X" ]; then
	echo -e "${yellow}༼ ▀̿̿Ĺ̯̿̿▀̿ ̿ ༽_•︻̷̿┻̿═━一༼ຈل͜ຈ༽ give the path of python-for-android using the -p flag or the donger dies${NC}"
	exit 1
fi

if [ "X$APPNAME" == "X" ]; then
	echo -e "${yellow}༼ ▀̿̿Ĺ̯̿̿▀̿ ̿ ༽_•︻̷̿┻̿═━一༼ຈل͜ຈ༽ give the appname using the -a flag or the donger dies${NC}"
	exit 1
fi

function checkDirectoryExist() {
	# If the specified app folder does not exist, we throw an error.
	if [ ! -e "${CURRENTFOLDERPATH}/${APPNAME}/" ]; then
		# Throw an error since folders are missing
		echo -e "${red}You need to have a folder ${CURRENTFOLDERPATH}, aborting.${NC}"
		exit 1
	fi
}

function generateFolders() {
	# If the app folder in AT3 does not exist, create it.
	if [ ! -e "${CURRENTFOLDERPATH}/app" ]; then
		echo -e "${yellow}${CURRENTFOLDERPATH}/app does not exist! Attempting to create it${NC}"
		mkdir -p "${CURRENTFOLDERPATH}/app"
	fi
}

function checkDistFolderExist() {
	# Check if destination exist
	if [ -e "${PY4APATH}/dist/${DIRNAME}" ]; then
		echo -e "${red}The distribution ${PY4APATH}/dist/${DIRNAME} already exist${NC}"
		echo -e "${red}Press a key to remove it, or Control + C to abort.${NC}"
		read
		rm -rf "${PY4APATH}/dist/${DIRNAME}"
	fi
}

function setSplash() {
	# Sets the splash screen if it exists	
	if [ -f "${CURRENTFOLDERPATH}/${APPNAME}/${APPSPLASH}" ]; then
		APPSPLASHFLAG="--presplash ${CURRENTFOLDERPATH}/${APPNAME}/${APPSPLASH}"
	fi
}

function setIcon() {
	# Sets the icon if it exists
	if [ -f "${CURRENTFOLDERPATH}/${APPNAME}/${APPSPLASH}" ]; then
		APPICONFLAG="--icon ${CURRENTFOLDERPATH}/${APPNAME}/${APPICON}"
	fi
}


function build() {
	# Build a distribute folder with all the packages now that kivy has been set
	pushd $PY4APATH
	./distribute.sh -m "`cat ${CURRENTFOLDERPATH}/${APPNAME}/python-for-android.deps`" -d $DIRNAME
	popd

	# Build the .apk
	cd "${PY4APATH}/dist/${DIRNAME}/"
	./build.py --package com.AT3.${APPNAME} --name "AT3 ${APPNAME}" --version 1.0 --dir "${CURRENTFOLDERPATH}/${APPNAME}" debug --permission INTERNET $APPICONFLAG $APPSPLASHFLAG

	# Copy the .apk files to our own app folder
	find "${PY4APATH}/dist/${DIRNAME}/bin" -type f -name '*.apk' -exec cp {} "${CURRENTFOLDERPATH}/app" \;

	# Delete the distribute and build now that the app has been made in the AT3 folder
	#rm -rf "${PY4APATH}/dist/${DIRNAME}"

	echo -e "${green}All done!${NC}"
}

# This functions first runs checks on wheter certain files and folders exist.
# If they do and all passes, the build function is run.
function main() {
	checkDirectoryExist &&
	checkDistFolderExist &&
	setSplash &&
	setIcon &&
	generateFolders &&
	build
}

main
