# C-SCALE HiSea Use Case
## Workflow solution for coastal hydrodynamic and water quality modelling using Delft3D FM

With this workflow solution a user can easily produce hydrodynamic and water quality hindcasts or forecasts for the coastal ocean for a Delft3D FM model schematisation.

The workflow solution has the following functionality

1. Download the necessary input data for the user's [Delft3D Flexible Mesh](https://www.deltares.nl/en/software/delft3d-flexible-mesh-suite/) model setup. Input data include Copernicus' [Global Ocean Physics Reanalysis](https://resources.marine.copernicus.eu/product-download/GLOBAL_REANALYSIS_PHY_001_030) and [Global ocean biogeochemistry hindcast](https://resources.marine.copernicus.eu/product-download/GLOBAL_REANALYSIS_BIO_001_029), [ERA5](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels?tab=form) and [FES2012](https://www.aviso.altimetry.fr/es/data/products/auxiliary-products/global-tide-fes/description-fes2012.html).
2. Prepare the data for ingestion into the user's Delft 3D Flexible Mesh [hydrodynamic](https://www.deltares.nl/en/software/module/d-flow-flexible-mesh/) and [water quality model](https://www.deltares.nl/en/software/module/d-water-quality/). This entails the preparation of forcings, initial conditions, and boundary condiditons.
3. Produce hydrodynamic and water quality hindcasts or forcasts based on the user's Delft3D Flexible Mesh hydrodynamic and water quality model setups.
4. Post-process the model outputs by interpolating the unstructured grid output from Delft3D Flexible Mesh to a regular grid for user specified spatial resolution, timesteps, model vertical layers and variables.
5. Visualise the simulation outputs in an interactive Jupyter Notebook.

The workflow solution can be deployed on any provider part of the [C-SCALE data and compute federation](https://c-scale.eu/) offering cloud container compute.

The ambition is to expand the workflow solution to include options to deploy a hybrid workflow leveraging both cloud and HPC compute resources offered by the C-SCALE federation as illustrated in the figure below.

![workflow](./img/cloud_hpc_workflow.png)

## Folders

* [fm_model](https://github.com/c-scale-community/use-case-hisea/tree/main/fm_model) - example Delft3D Flexible Mesh model files
* [img](https://github.com/c-scale-community/use-case-hisea/tree/main/img) - folder containing images used in this README.md
* [notebooks](https://github.com/c-scale-community/use-case-hisea/tree/main/notebooks) - Jupyter Notebooks used for development and troubleshooting purposes
* [scripts](https://github.com/c-scale-community/use-case-hisea/tree/main/scripts) - scripts and instructions to build and run the docker containers used to run the workflow

# Getting started

### Prerequisites
1. Github account. Sign up [here](https://github.com/signup)
2. DockerHub account and access to https://hub.docker.com/repository/docker/deltares/delft3dfm (contact software.support@deltares.nl to arrange access)

### Set up your computing environment

It is recommended to run the workflow in a Linux environment with [docker](https://www.docker.com/). This could be a virtual machine in the cloud, or your local computer. To run the workflow locally on a Linux or Apple Mac computer requires [docker desktop](https://www.docker.com/products/docker-desktop/). 

For Windows users, it is recommended to [install the Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/install), upgrade to [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install#upgrade-version-from-wsl-1-to-wsl-2) and [install the docker desktop WSL2 backend](https://docs.docker.com/desktop/windows/wsl/).

### Setting up the folder structure and cloning the repo

1. Open a terminal on your local computer or log on to your virtual machine in the cloud.
2. Navigate to the folder where you want to work, here we use the `$HOME` directory, which typically has the path `home/$USER`, where `$USER` is your username.
3. In `$HOME` create the folders to where you want the data from the workflow to be stored, e.g.: \
		
	Create the directory to which you [download](https://github.com/c-scale-community/use-case-hisea/tree/main/scripts/download) data from CMEMS and CDS, and where you place the FES data by doing:
		
		mkdir -p data/download/

	Create the directory where the output from the [preprocessing](https://github.com/c-scale-community/use-case-hisea/tree/main/scripts/preprocessing) will be written to by doing:
		
		mkdir -p data/preprocout/
	

4. In `$HOME` (or some other preferred directory) clone this repository by doing: 
		
		git clone https://github.com/c-scale-community/use-case-hisea.git
	
	This will create the folder `$HOME/use-case-hisea` containing all the files you need for the workflow. Note that for private repos authentication will be required. The user will be prompted to enter the github username and the [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
	
### Build and pull the docker containers for the workflow
(Note: if you have permission denied error, add sudo before all commands)

0. If Docker is not installed yet, use the following commands for quick installation

	sudo yum check-update
	curl -fsSL https://get.docker.com/ | sh
	sudo systemctl start docker

1. Navigate to `$HOME/use-case-hisea/scripts/download` and do: 
		
		docker build --tag download-input .
		
2. Navigate to `$HOME/use-case-hisea/scripts/preprocessing/era5` and do: 
		
		docker build --tag getera .
		
3. Navigate to `$HOME/use-case-hisea/scripts/preprocessing/tide_physical_chemical` and do: 
	
	docker build --tag preprocessing .
	
4. Pull docker image for Delft3D Flexible Mesh by doing: 
	
	docker login --username ... --password ...
	
	docker image pull deltares/delft3dfm:latest
	
- [ ] todo: build post-processing docker container

### Run the docker containers of the workflow one-by-one

Below are examples of the `docker run` commands for a 5-day simulation from 1-Apr-2022 to 5-Apr-2022 for a small model in Greece (the example [fm_model](https://github.com/c-scale-community/use-case-hisea/tree/main/fm_model) included in this repository).

1. Download ERA5 forcing data

		docker run -v /home/$USER/.cdsapirc:/root/.cdsapirc -v /home/$USER/data/download:/data download-input python download_era5.py --longitude_min 22.5 --longitude_max 24.5 --latitude_min 36.5 --latitude_max 38.5 --date_min '2022-04-01' --date_max '2022-04-05'
	
2. Download CMEMS physics data

		docker run -v /home/$USER/data/download:/data download-input python download_cmems_physics.py --username $CMEMS_USERNAME --password $CMEMS_PWD --longitude_min 22.5 --longitude_max 24.5 --latitude_min 36.5 --latitude_max 38.5 --date_min $DATE_MIN '2022-04-01' --date_max '2022-04-05'
	
3. Download CMEMS biogeochemistry data

		docker run -v /home/$USER/data/download:/data download-input python download_cmems_biogeochemistry.py --username $CMEMS_USERNAME --password $CMEMS_PWD --longitude_min 22.5 --longitude_max 24.5 --latitude_min 36.5 --latitude_max 38.5 --date_min $DATE_MIN '2022-04-01' --date_max '2022-04-05'
	
4. Preprocess ERA5 data 

		docker run -v /home/$USER/data/download/era5:/data/input -v /home/centos/data/preprocout:/data/output getera ERA5_convert2_FM_and_merge_allVars.py --input /data/input --output /data/output

5. Preprocess CMEMS phyics and biogeochemistry data

		docker run -v /home/$USER/data/download/cmems:/data/input -v /home/$USER/repos/use-case-hisea/fm_model:/data/model -v /home/centos/data/preprocout:/data/output preprocessing boundary.py --interp true --simultaneous true --steric true --input /data/input --model /data/model --output /data/output
	
6. Preprocess tide data

		docker run -v /home/$USER/data/download/fes2012:/data/input -v /home/$USER/repos/use-case-hisea/fm_model:/data/model -v /home/centos/data/preprocout:/data/output preprocessing tide.py --fespath /data/input --coords "22.5, 24.5, 36.5, 38.5" --pli south2.pli --pli east2.pli --output /data/output --model /data/model
		
7. Link output from preprocessing to your fm_model directory

	In `/home/$USER/repos/use-case-hisea/fm_model` do
	
		ln -sf /home/$USER/data/preprocout/* .

8. Run Delft3D FM docker container (run the model)

		docker run -v /home/$USER/repos/use-case-hisea/fm_model:/data -t deltares/delft3dfm:latest

# TODO's

- [ ] confirm example DFlowFM model runs with preprocessed files
	- [ ] clean up fm_model folder (many unnecessary files)
- [ ] confirm postprocessing works
	- [ ] improve input arguments
	- [ ] dockerise
- [ ] make visualisations


