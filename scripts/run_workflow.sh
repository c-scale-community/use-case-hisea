#!/bin/bash

## prerequisites
#
# 1. build the docker containers to download the data following instructions on 
#	<https://github.com/c-scale-community/use-case-hisea/tree/main/scripts/download>
#
# 2. build the docker container to run preprocessing following instructions on
#	<https://github.com/c-scale-community/use-case-hisea/tree/main/scripts/preprocessing>
#
## usage to also log how long it takes to run the workflow
# $ ./run_workflow.sh

##
## user defined input parameters
##

CDSAPIRC_LOC=/home/centos/.cdsapirc
CMEMS_UNAME=bbackeberg
CMEMS_PWD=iaTmwJ7D
DATA_DOWNLOAD_LOC=/home/centos/data/download # note: only provide the base directory, don't add `cmems` or `era5` etc 
PREPROC_OUTPUT_LOC=/home/centos/data/preprocout
FM_MODEL_LOC=/home/centos/repos/use-case-hisea/fm_model
PLIFILE1=south2.pli
PLIFILE2=east2.pli
LON_MIN=22.5
LON_MAX=24.5
LAT_MIN=36.5
LAT_MAX=38.5
DATE_MIN='2022-04-01'
DATE_MAX='2022-04-05'

##
## running the workflow (in a perfect world nothing in the below needs to be changed)
##

# download era5
docker run \
	-v $CDSAPIRC_LOC:/root/.cdsapirc \
	-v $DATA_DOWNLOAD_LOC:/data \
	download-input python download_era5.py \
		--longitude_min $LON_MIN \
		--longitude_max $LON_MAX \
		--latitude_min $LAT_MIN \
		--latitude_max $LAT_MAX \
		--date_min $DATE_MIN \
		--date_max $DATE_MAX

# download cmems physics
docker run \
	-v $DATA_DOWNLOAD_LOC:/data \
	download-input python download_cmems_physics.py \
		--username $CMEMS_UNAME \
		--password $CMEMS_PWD \
		--longitude_min $LON_MIN \
		--longitude_max $LON_MAX \
		--latitude_min $LAT_MIN \
		--latitude_max $LAT_MAX \
		--date_min $DATE_MIN \
		--date_max $DATE_MAX

# download cmems biogeochemistry
docker run \
	-v $DATA_DOWNLOAD_LOC:/data \
	download-input python download_cmems_biogeochemistry.py \
		--username $CMEMS_UNAME \
		--password $CMEMS_PWD \
		--longitude_min $LON_MIN \
		--longitude_max $LON_MAX \
		--latitude_min $LAT_MIN \
		--latitude_max $LAT_MAX \
		--date_min $DATE_MIN \
		--date_max $DATE_MAX

# preprocess CMEMS phyics and biogeochemistry data
docker run \
	-v $DATA_DOWNLOAD_LOC/cmems:/data/input \
	-v $FM_MODEL_LOC:/data/model \
	-v $PREPROC_OUTPUT_LOC:/data/output \
	preprocessing boundary.py \
		--interp true \
		--simultaneous true \
		--steric true \
		--input /data/input \
		--model /data/model \
		--output /data/output

# preprocess tide data
docker run \
	-v $DATA_DOWNLOAD_LOC/fes2012:/data/input \
	-v $FM_MODEL_LOC:/data/model \
	-v $PREPROC_OUTPUT_LOC:/data/output \
	preprocessing tide.py \
		--fespath /data/input \
		--coords "$LON_MIN, $LON_MAX, $LAT_MIN, $LAT_MAX" \
		--pli $PLIFILE1 \
		--pli $PLIFILE2 \
		--output /data/output \
		--model /data/model

# preprocess ERA5 data
docker run \
	-v $DATA_DOWNLOAD_LOC/era5:/data/input \
	-v $PREPROC_OUTPUT_LOC:/data/output \
	getera ERA5_convert2_FM_and_merge_allVars.py \
		--input /data/input \
		--output /data/output
