# CryoGrid community model

This is the community version of *CryoGrid*, a numerical model to investigate land surface processes in the terrestrial cryosphere. This version of *CryoGrid* is implemented in MATLAB.

*Note: This is the latest development of the CryoGrid model family. It comprises the functionalities of previous versions including [CryoGrid3](https://github.com/CryoGrid/CryoGrid3), which is no longer encouraged to be used.*

## Documentation

A manuscript "The CryoGrid community model - a multi-physics toolbox for climate-driven simulations in the terrestrial cryosphere" has been submitted to the journal  Geoscientific Model Development which contains a description of the model and instructions to run it (Supplements 1, 3).

## Getting started

Both [CryoGridCommunity_source](https://github.com/CryoGrid/CryoGridCommunity_source) and [CryoGridCommunity_run](https://github.com/CryoGrid/CryoGridCommunity_run) are required. See [CryoGridCommunity_run](https://github.com/CryoGrid/CryoGridCommunity_run) for details.

## This fork
In this work we are interested in incorporating the longwave radiation of blocky fields into the CryoGrid model. We expect the temperatures to be higher, getting a deeper active layer.

### Remaining TODOs
> * Check which thermal conductivity function should initially be used (conductivity_mixing_squares / thermalConductivity_CLM4_5)

### Code changes
There are changes in file `HEAT_CONDUCTION.m` and `GROUND_freeW_bucketW_convection_seb.m` compared to the parent fork.

### Theory

Long-wave radiation is a physical phenomenon describing how all matter with a temperature above absolute zero K emits electromagnetic waves with certain wavelengths depending on the temperature of the object. 
This thermal radiation is defined as Stefan-Boltzmann law with
$R = \varepsilon \sigma_\mathit{SB} T^4$. 
Here, $\sigma$ is a proportionality constant named the Stefan-Boltzmann constant with value $\sigma_\mathit{SB} = 5.6 \times 10^{-8} W/m^2K^4$. $\varepsilon$, which is normally between [0,1], is the emissivity of the matter and $T$ is the temperature in Kelvin. 

#### Approach 1
In this approach, we calculate directly the long-wave radiation in each cell using the original Stefan-Boltzmann law. 
First, we calculate the saturation for each grid cell, i.e. the fraction of void space that is filled with water or ice. If the saturation in a grid cell is below a given threshold and the grain size is large enough, the change in energy $dE_i$ for a given time $i$ between the cells above and beneath can be calculated by the following:
\begin{equation}
    dE_i = \epsilon_\mathit{eff} \sigma_\mathit{SB} ((T_\mathit{i,1:end-1}+ 273.15)^4 - (T_\mathit{i,2:end}+ 273.15)^4)
\end{equation}
where $\epsilon_\mathit{eff}$ is an efficiency parameter ranging between 0 and 1,  $\sigma_\mathit{SB}$ is the Stefan Boltzmann's constant and $T_i$ is the temperature vector for the ground cells.
This energy exchange term is added in the Cryogrid community model \parencite{westermann_cryogrid_2023} as a part of the heat conduction framework.

#### Approach 2
In this approach, we follow the approach of \textcite{fillion_thermal_2011} with the theoretical development of \textcite{tien_thermal_1988}, where we calculate the net radiation directly from the current temperature $T_i$ in each cell. If we assume small enough variations in the ground temperatures, the diffusion approximation is valid so that the heat conduction can be linearized by a Taylor series expansion \parencite{tien_thermal_1988}.
In addition, this effect is dependent on the porosity in the grid cells, which varies spatially in the ground due to changes in the water storage over time.

The thermal conductivity vector will then be given by 
\begin{equation}
\vec{dE_i} = 4 C(\varepsilon) \vec{\rho}_i \sigma_\mathit{SB} \delta_{G}(\vec{T}_i+273.15)^3 
\end{equation}
where $\vec{\rho}$ is the porosity in each grid cell, $\sigma_{SB}$ is the Stefan Boltzmann's constant and $\delta_{G}$ is a measure for the size of the blocks, e.g. the diameter in meter. $C(\varepsilon)$ is a parameter describing the emissivity of the particles that we will not go into details on in this work.

This thermal conductivity contribution is added in the Cryogrid model framework in the part where the conductivity mixing is calculated and a (possibly spatially varying) grain size parameter is set up for the stratigraphy.


