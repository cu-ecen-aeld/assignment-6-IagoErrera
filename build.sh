#!/bin/bash
# Script to build image for qemu.
# Author: Siddhant Jajoo.

rm -rf build

git submodule init
git submodule sync
git submodule update

# local.conf won't exist until this step on first execution
source poky/oe-init-build-env

CONFLINE="MACHINE = \"qemuarm64\""

cat conf/local.conf | grep "${CONFLINE}" > /dev/null
local_conf_info=$?

if [ $local_conf_info -ne 0 ];then
	echo "Append ${CONFLINE} in the local.conf file"
	echo ${CONFLINE} >> conf/local.conf
	echo "BB_NUMBER_THREADS = \"2\"" >> conf/local.conf
	echo "PARALLEL_MAKE = \"-j 2\"" >> conf/local.conf	
	echo "TUNE_FEATURES = \"aarch64 cortexa57\"" >> conf/local.conf
	echo "DEFAULTTUNE = \"cortexa57\"" >> conf/local.conf
	#echo "DL_DIR = \"/yocto/downloads\"" >> conf/local.conf
	#echo "SSTATE_DIR =  \"/yocto/sstate-cache\"" >> conf/local.conf
	#echo "TMPDIR =  \"/yocto/asssignment-6-tmp\"" >> conf/local.conf
else
	echo "${CONFLINE} already exists in the local.conf file"
fi


bitbake-layers show-layers | grep "meta-aesd" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-aesd layer"
	bitbake-layers add-layer ../meta-aesd
else
	echo "meta-aesd layer already exists"
fi

set -e

rm -rf /yocto/downloads
rm -rf /yocto/sstate-cache
rm -rf tmp

bitbake core-image-aesd -c cleansstate
bitbake core-image-aesd -c cleanall

bitbake core-image-aesd
