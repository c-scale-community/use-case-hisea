# postprocessing

This folder contains the files needed to build and run the docker container to postprocess the output from the Delft3D FM model run to a regular grid for further analysis.

The below script is called in docker container.

* `nc2regularGrid_listComprehension.py` \
  This script converts the Delft3D FM map output to a regular spaced grid. It expects 3 paramaters:
  - `mapfile`: An unpartitioned Delft3D FM NetCDF map output file
  - `xpoints`: number of points you wish to include into your regular grid
  - `ypoints`: number of points you wish to include into your regular grid

# Example Docker build

    docker build --tag postprocess .

# Example Docker run

    docker run -v /path/to/delf3dfm/output:/data/input -v /path/to/where/you/want/to/save/the/regular/gridded/data:/data/output hisea tttz_waq_0000_map.nc 500 400
