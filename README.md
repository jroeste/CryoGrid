# CryoGrid community model

This is the community version of *CryoGrid*, a numerical model to investigate land surface processes in the terrestrial cryosphere. This version of *CryoGrid* is implemented in MATLAB.

*Note: This is the latest development of the CryoGrid model family. It comprises the functionalities of previous versions including [CryoGrid3](https://github.com/CryoGrid/CryoGrid3), which is no longer encouraged to be used.*

## Documentation

A manuscript "The CryoGrid community model - a multi-physics toolbox for climate-driven simulations in the terrestrial cryosphere" has been submitted to the journal  Geoscientific Model Development which contains a description of the model and instructions to run it (Supplements 1, 3).

## Getting started

Both [CryoGridCommunity_source](https://github.com/CryoGrid/CryoGridCommunity_source) and [CryoGridCommunity_run](https://github.com/CryoGrid/CryoGridCommunity_run) are required. See [CryoGridCommunity_run](https://github.com/CryoGrid/CryoGridCommunity_run) for details.

## This fork
In this work we are interested in incorporating the longwave radiation of blocky fields into the CryoGrid model. We expect the temperatures to be higher, getting a deeper active layer. 

TODO: 
* Add figure of blocky terrain
* Add d_energy formula
* Explanation of "factor"
* Explanation of the assumptions. Geometric/blocky structure can be assumed to take a value between 0 and 1. 1 means a black body radiates long-waves, 0 means no long-wave radiation
* Make presentation
  
