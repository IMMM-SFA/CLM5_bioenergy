# CLM5_bioenergy
user namelist settings, code changes and driving scripts to set up CLM5 on Constance for bioenergy crop simulations

## Repository structure
---scripts | ---user_mods



## Tutorial to configure CLM5 cases on CONSTANCE
We provide detailed notes on running the CLM5 compsets on PNNL's CONSTANCE cluster.



### Download script and data repository
    setenv BASE_DIR <dir-of-choice>
    cd $BASE_DIR
    git clone git@github.com:IMMM-SFA/CLM5_bioenergy.git
  

### Download CLM code, please check http://www.cesm.ucar.edu/models/cesm2.0/land for CLM5 documentation
    cd $BASE_DIR
    git clone -b release-clm5.0 git@github.com:huangmy/ctsm.git clm5.0
    setenv CLM_SRC_DIR $BASE_DIR/clm5.0
    cd $CLM_SRC_DIR
    ./manage_externals/checkout_externals


### Configure a user_defined single point CLM5 simulation
    cd $BASE_DIR/scripts/
    bash create_1x1_Illinois_Rotation_clm5_constance.sh




## Who do I talk to?
    yanyan.cheng at pnnl.gov
    maoyi.huang at pnnl.gov



## Reference
Yanyan Cheng, Maoyi Huang, Min Chen, Kaiyu Guan, Carl Bernacchi, Bin Peng, Zeli Tan, Parameterizing perennial bioenergy crops in Version 5 of the Community Land Model based on site-level observations in the Central Midwestern United States, Journal of Advances for Modeling the Earth System, (Accepted)


## Acknowledgment
U.S. Department of Energy (DOE), Office of Science, as part of research in Multi-Sector Dynamics, Earth and Environmental System Modeling Program
