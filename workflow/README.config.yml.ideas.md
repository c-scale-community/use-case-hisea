# dependencies
- [ ] cdsapirc_loc:
- [ ] cmems_ uname:
- [ ] cmems_pwd:

# folder locations 
- [ ] fm_model_loc:
- [ ] data_fldr_loc:

# options for running on hpc 

# run in forecast model, eg daily 5 day forecasts with a 5 day spin-up
- [ ] run_in_forecast_mode: # yes|no, if yes specify forecast window mid point and forecast window
- [ ] forecast_window_mid_pt: today - 10 #ERA5 latency
- [ ] forecast_window: 10 days
- [ ] forecast_frequency: daily

# hindcast for specific period
- [ ] run_in_hindcast_mode: # yes|no, if yes specify tstart and tstop
- [ ] tstart: '2021-01-01'
- [ ] tstop: '2021-03-12'

# data input options
- [ ] physics: # cmems | hycom
- [ ] bgc: # cmems | other 
- [ ] atm: # era5 | ecmwf | gfs 
