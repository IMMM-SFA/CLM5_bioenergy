#!/bin/sh 
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Script to create a single point case at 1x1_Illinoi, using clm5 in constance.
# Yanyan Cheng, 08/16/2018; 
# Modified by M.Huang, 08/21/2018
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


export CCSMUSER=chen693
export BASE_DIR=/pic/projects/landuq/${CCSMUSER}
export CESM_CASE_DIR=/pic/scratch/${CCSMUSER}/CESM_cases

export CESM_SRC_DIR=/pic/projects/landuq/chen693/scratch/release-clm5.0.01/clm5.0  # cloned on July 31st, 2019, release-clm5.0.01 version

export INPUTDATA_DIR=${BASE_DIR}/IM3_CLM5/inputdata
export CESM_INPUTDATA_DIR=${INPUTDATA_DIR}/cesm_inputdata
export ARCHIVE_DIR=/pic/scratch/${CCSMUSER}/cesm_archive
export CIME_OUTPUT_ROOT=/pic/scratch/${CCSMUSER}/csmruns

export CESM_COMPSET=I1PtClm50SpGs
export CLM_USRDAT_NAME=1x1_Illinois
export DOMAINFILE_CYYYYMMDD=180910
export SURFFILE_CYYYYMMDD=c180910
export SIMYR=2000

export CROP_TYPE=Corn
export lignin=default
export CESM_CASE_NAME=clm5_${CLM_USRDAT_NAME}-all${CROP_TYPE}-`date "+%y%m%d"`-${lignin}-spinup-TOTSOMC_30cm
export YEAR_START=2009

#+++ copy the machine files 
cp -f user_machines/config_machines_constance.xml ${CESM_SRC_DIR}/cime/config/cesm/machines/config_machines.xml
cp -f user_machines/config_batch_constance.xml ${CESM_SRC_DIR}/cime/config/cesm/machines/config_batch.xml


#+++ delete the old casedir/rundir
rm -rf ${CESM_CASE_DIR}/${CESM_CASE_NAME}
rm -rf ${CIME_OUTPUT_ROOT}/${CESM_CASE_NAME}

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create soft links for CESM inputdata
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++ Link forcing data file
mkdir -p ${CESM_INPUTDATA_DIR}/atm/datm7/${CLM_USRDAT_NAME}/CLM1PT_data
# rm -f ${CESM_INPUTDATA_DIR}/atm/datm7/${CLM_USRDAT_NAME}/CLM1PT_data/*.nc
ls -l ${INPUTDATA_DIR}/user_inputdata/${CLM_USRDAT_NAME}/clmforc/*.nc | awk '{ print $9}' | awk -F'.' '{print $3}' | \
awk -v INPUTDATA_DIR=${INPUTDATA_DIR} -v CLM_USRDAT_NAME=${CLM_USRDAT_NAME} \
'{ system( "ln -s " INPUTDATA_DIR "/user_inputdata/" CLM_USRDAT_NAME "/clmforc/clmforc." CLM_USRDAT_NAME "." $1 ".nc " INPUTDATA_DIR"/cesm_inputdata/atm/datm7/" CLM_USRDAT_NAME "/CLM1PT_data/" $1 ".nc") }'

#+++ Link domain data file
rm -f ${CESM_INPUTDATA_DIR}/share/domains/domain.lnd.${CLM_USRDAT_NAME}_simyr${SIMYR}.nc
ls ${INPUTDATA_DIR}/user_inputdata/${CLM_USRDAT_NAME}/domain.lnd.${CLM_USRDAT_NAME}_${CLM_USRDAT_NAME}.${DOMAINFILE_CYYYYMMDD}.nc
ln -s ${INPUTDATA_DIR}/user_inputdata/${CLM_USRDAT_NAME}/domain.lnd.${CLM_USRDAT_NAME}_${CLM_USRDAT_NAME}.${DOMAINFILE_CYYYYMMDD}.nc ${CESM_INPUTDATA_DIR}/share/domains/domain.lnd.${CLM_USRDAT_NAME}_simyr${SIMYR}.nc

#+++ Link surface data file
mkdir -p ${CESM_INPUTDATA_DIR}/lnd/clm2/surfdata_map
rm -f ${CESM_INPUTDATA_DIR}/lnd/clm2/surfdata_map/surfdata_${CLM_USRDAT_NAME}_simyr${SIMYR}.nc
ls ${INPUTDATA_DIR}/user_inputdata/${CLM_USRDAT_NAME}/surfdata_${CLM_USRDAT_NAME}_78pfts_CMIP6_simyr1850_${SURFFILE_CYYYYMMDD}_all${CROP_TYPE}_180910.nc
ln -s ${INPUTDATA_DIR}/user_inputdata/${CLM_USRDAT_NAME}/surfdata_${CLM_USRDAT_NAME}_78pfts_CMIP6_simyr1850_${SURFFILE_CYYYYMMDD}_all${CROP_TYPE}_180910.nc ${CESM_INPUTDATA_DIR}/lnd/clm2/surfdata_map/surfdata_${CLM_USRDAT_NAME}_simyr${SIMYR}.nc


# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Now do the CLM stuff
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cd ${CESM_SRC_DIR}/cime/scripts
./create_newcase --case ${CESM_CASE_DIR}/${CESM_CASE_NAME} --res CLM_USRDAT --compset ${CESM_COMPSET} --mach constance --run-unsupported

# Configuring case :
cd ${CESM_CASE_DIR}/${CESM_CASE_NAME}

#+++ Modifying : env_batch.xml, if debugging
./xmlchange  --file env_batch.xml --id JOB_QUEUE --val "slurm,short" --force
./xmlchange  --file env_batch.xml --id JOB_WALLCLOCK_TIME --val "3:00:00"

#+++ Modifying : env_build.xml
./xmlchange  --file env_build.xml --id CIME_OUTPUT_ROOT --val ${CIME_OUTPUT_ROOT}

# Modifying : env_run.xml
./xmlchange --file env_run.xml --id CLM_BLDNML_OPTS --val "-bgc bgc -crop"
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_END --val 2014
./xmlchange --file env_run.xml --id DATM_MODE --val CLM1PT
./xmlchange --file env_run.xml --id ATM_DOMAIN_FILE --val domain.lnd.${CLM_USRDAT_NAME}_simyr${SIMYR}.nc
./xmlchange --file env_run.xml --id LND_DOMAIN_FILE --val domain.lnd.${CLM_USRDAT_NAME}_simyr${SIMYR}.nc
./xmlchange --file env_run.xml --id STOP_N --val 6
./xmlchange --file env_run.xml --id REST_N --val 1
./xmlchange --file env_run.xml --id RUN_STARTDATE --val ${YEAR_START}-01-01
./xmlchange --file env_run.xml --id STOP_OPTION --val nyears
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_START --val ${YEAR_START}
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_ALIGN --val ${YEAR_START}
./xmlchange --file env_run.xml --id DIN_LOC_ROOT --val ${CESM_INPUTDATA_DIR}
./xmlchange --file env_run.xml --id DIN_LOC_ROOT_CLMFORC --val "\$DIN_LOC_ROOT/atm/datm7"
./xmlchange --file env_run.xml --id CLM_USRDAT_NAME --val ${CLM_USRDAT_NAME}
./xmlchange --file env_run.xml --id CLM_FORCE_COLDSTART --val on
./xmlchange --file env_run.xml --id DOUT_S_ROOT --val ${ARCHIVE_DIR}/${CESM_CASE_NAME}
./xmlchange --file env_run.xml --id DOUT_S_SAVE_INTERIM_RESTART_FILES --val TRUE

cp env_batch.xml env_batch_nouse.xml
sed 's/00:59:00/72:00:00/g' env_batch_nouse.xml > env_batch.xml

./case.setup

#+++ Modify user_nl_clm, output results in 30 min interval
export fsurdat=${CESM_INPUTDATA_DIR}/lnd/clm2/surfdata_map/surfdata_${CLM_USRDAT_NAME}_simyr${SIMYR}.nc

#+++ Setting finidat from spinup
export LAST_CESM_CASE_NAME=clm5_1x1_Illinois-allCorn-181008-dylanduse-spinup2000yrs-irri-fertOn
export YEAR_RESTART=2986
export finidat=${ARCHIVE_DIR}/${LAST_CESM_CASE_NAME}/rest/${YEAR_RESTART}-01-01-00000/${LAST_CESM_CASE_NAME}.clm2.r.${YEAR_RESTART}-01-01-00000.nc
ls $finidat

export param_dic=/pic/projects/landuq/chen693/IM3_CLM5/inputdata/cesm_inputdata/lnd/clm2/paramdata
export paramfile=${param_dic}/clm5_params.c171117_Rotation.nc
ls $paramfile


##### restart
cat >> user_nl_clm << EOF
fsurdat  = '$fsurdat'
finidat  = '$finidat'
flanduse_timeseries ='/pic/projects/landuq/chen693/IM3_CLM5/inputdata/user_inputdata/1x1_Illinois/landuse.timeseries_1x1_Illinois_hist_78pfts_CMIP6_simyr2009-2014_c181008_irrigC10S0.nc'
do_transient_pfts = .true.
do_transient_crops = .true.
check_finidat_year_consistency = .false.
use_fertilizer = .true.
irrigate = .true.
hist_mfilt = 365
hist_nhtfrq = -24
use_luna = .false.
use_flexiblecn = .true.
EOF


#+++ Modify user_nl_datm
cat >> user_nl_datm << EOF
  taxmode = 'cycle', 'cycle'
EOF

export user_Mods_DIR=/people/chen693/IM3_CLM5/scripts/shell/user_Mods
cp ${user_Mods_DIR}/biogeochem/CNFUNMod.F90  ${CESM_CASE_DIR}/${CESM_CASE_NAME}/SourceMods/src.clm/CNFUNMod.F90
cp ${user_Mods_DIR}/biogeochem/CNCStateUpdate1Mod.F90  ${CESM_CASE_DIR}/${CESM_CASE_NAME}/SourceMods/src.clm/CNCStateUpdate1Mod.F90
cp ${user_Mods_DIR}/biogeophys/SurfaceAlbedoType.F90 ${CESM_CASE_DIR}/${CESM_CASE_NAME}/SourceMods/src.clm/SurfaceAlbedoType.F90
cp ${user_Mods_DIR}/biogeochem/CNPhenologyMod-cut.F90  ${CESM_CASE_DIR}/${CESM_CASE_NAME}/SourceMods/src.clm/CNPhenologyMod.F90
cp ${user_Mods_DIR}/biogeochem/CNVegStructUpdateMod.F90 ${CESM_CASE_DIR}/${CESM_CASE_NAME}/SourceMods/src.clm/CNVegStructUpdateMod.F90
cp ${user_Mods_DIR}/biogeophys/IrrigationMod.F90 ${CESM_CASE_DIR}/${CESM_CASE_NAME}/SourceMods/src.clm/IrrigationMod.F90


#+++ Configuring case :
cd ${CESM_CASE_DIR}/${CESM_CASE_NAME}
./case.build


#+++ Modify datm streams
cp -f  ${CESM_CASE_DIR}/${CESM_CASE_NAME}/CaseDocs/datm.streams.txt.CLM1PT.CLM_USRDAT ${CESM_CASE_DIR}/${CESM_CASE_NAME}/user_datm.streams.txt.CLM1PT.CLM_USRDAT
chmod +rw ${CESM_CASE_DIR}/${CESM_CASE_NAME}/user_datm.streams.txt.CLM1PT.CLM_USRDAT
perl -w -i -p -e 's@RH       rh@QBOT     shum@' ${CESM_CASE_DIR}/${CESM_CASE_NAME}/user_datm.streams.txt.CLM1PT.CLM_USRDAT
sed -i '/ZBOT/d' ${CESM_CASE_DIR}/${CESM_CASE_NAME}/user_datm.streams.txt.CLM1PT.CLM_USRDAT

#+++ Running case :
./case.submit --mail-user yanyan.cheng@pnnl.gov --mail-type all






