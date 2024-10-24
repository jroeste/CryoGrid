# CryoGrid community model

This is the community version of *CryoGrid*, a numerical model to investigate land surface processes in the terrestrial cryosphere. This version of *CryoGrid* is implemented in MATLAB.

*Note: This is the latest development of the CryoGrid model family. It comprises the functionalities of previous versions including [CryoGrid3](https://github.com/CryoGrid/CryoGrid3), which is no longer encouraged to be used.*

### This fork
In this work we are interested in incorporating the longwave radiation of blocky fields into the CryoGrid model. We expect the temperatures to be higher, getting a deeper active layer.

#### Remaining TODOs
> * Check which thermal conductivity function should initially be used (conductivity_mixing_squares / thermalConductivity_CLM4_5)

#### Code changes 
There are changes in file `HEAT_CONDUCTION.m` and `GROUND_freeW_bucketW_convection_seb.m` compared to the parent fork. Approach 2 is the code implemented now. It is possible to change to approach 1. 

#### Example
The parameter file included in this repo is `CG_latentheat_lwr.xlsx`. The forcing file is from Juvasshøe (Norway) and the parameterization is based on Renette et al. (2023).

#### Theory

Long-wave radiation is a physical phenomenon describing how all matter with a temperature above absolute zero K emits electromagnetic waves with certain wavelengths depending on the temperature of the object. 
This thermal radiation is defined as Stefan-Boltzmann law with
$R = \varepsilon \sigma_\mathit{SB} T^4$. 
Here, $\sigma$ is a proportionality constant named the Stefan-Boltzmann constant with value $\sigma_\mathit{SB} = 5.6 \times 10^{-8} W/m^2K^4$. The variable $\varepsilon$, which is normally between [0,1], is the emissivity of the matter and $T$ is the temperature in Kelvin. 

##### Approach 1
In this approach, we calculate directly the long-wave radiation in each cell using the original Stefan-Boltzmann law. 
First, we calculate the saturation for each grid cell, i.e. the fraction of void space that is filled with water or ice. If the saturation in a grid cell is below a given threshold and the grain size is large enough, the change in energy $dE_i$ for a given time $i$ between the cells above and beneath can be calculated by the following:

   $$ dE_i = \epsilon_\mathit{eff} \sigma_\mathit{SB} ((T_\mathit{i,1:end-1}+ 273.15)^4 - (T_\mathit{i,2:end}+ 273.15)^4) $$

where $\epsilon_\mathit{eff}$ is an efficiency parameter ranging between 0 and 1,  $\sigma_\mathit{SB}$ is the Stefan Boltzmann's constant and $T_i$ is the temperature vector for the ground cells.
This energy exchange term is added in the Cryogrid community model(Westermann et al., 2023) as a part of the heat conduction framework.

##### Approach 2
In this approach, we follow the approach of  Fillion et al. (2011)  with the theoretical development of Tien (1988), where we calculate the net radiation directly from the current temperature $T_i$ in each cell. If we assume small enough variations in the ground temperatures, the diffusion approximation is valid so that the heat conduction can be linearized by a Taylor series expansion  (Tien, 1988). In addition, this effect is dependent on the porosity in the grid cells, which varies spatially in the ground due to changes in the water storage over time.

The thermal conductivity vector will then be given by 

$$ dE_i = 4 C(\varepsilon) \rho_i \sigma_\mathit{SB} \delta_{G}({T}_i+273.15)^3 $$

where $\rho$ is the porosity in each grid cell, $\sigma_{SB}$ is the Stefan Boltzmann's constant and $\delta_{G}$ is a measure for the size of the blocks, e.g. the diameter in meter. $C(\varepsilon)$ is a parameter describing the emissivity of the particles that we will not go into details on in this work.
This thermal conductivity contribution is added in the Cryogrid model framework in the part where the conductivity mixing is calculated and a (possibly spatially varying) grain size parameter is set up for the stratigraphy.



### References
Fillion, M.-H., J. Côté, and J.-M. Konrad (2011). “Thermal radiation and conduction properties of materials ranging
from sand to rock-fill”. In: Canadian Geotechnical Journal 48.4, pp. 532–542. ISSN: 0008-3674. DOI: 10.1139/
t10-093.

Kunii, D. and J. M. Smith (1960). “Heat transfer characteristics of porous rocks”. In: AIChE Journal 6.1, pp. 71–78.
ISSN: 1547-5905. DOI: 10.1002/aic.690060115.

Renette, C. et al. (2023). “Simulating the effect of subsurface drainage on the thermal regime and ground ice in
blocky terrain in Norway”. In: Earth Surface Dynamics 11.1, pp. 33–50. ISSN: 2196-6311. DOI: 10.5194/esurf-
11-33-2023.

Scherler, M. et al. (2014). “A two-sided approach to estimate heat transfer processes within the active layer of the
Murtèl–Corvatsch rock glacier”. In: Earth Surface Dynamics 2.1, pp. 141–154. ISSN: 2196-6311. DOI: 10.5194/
esurf-2-141-2014.

Tien, C. L. (1988). “Thermal Radiation in Packed and Fluidized Beds”. In: Journal of Heat Transfer 110.4, pp. 1230–
1242. ISSN: 0022-1481, 1528-8943. DOI: 10.1115/1.3250623.

Westermann, S. et al. (2023). “The CryoGrid community model (version 1.0) – a multi-physics toolbox for climate-
driven simulations in the terrestrial cryosphere”. In: Geoscientific Model Development 16.9, pp. 2607–2647. ISSN:
1991-959X. DOI: 10.5194/gmd-16-2607-2023.


## Documentation

A manuscript "The CryoGrid community model - a multi-physics toolbox for climate-driven simulations in the terrestrial cryosphere" has been submitted to the journal  Geoscientific Model Development which contains a description of the model and instructions to run it (Supplements 1, 3).

## Getting started

Both [CryoGridCommunity_source](https://github.com/CryoGrid/CryoGridCommunity_source) and [CryoGridCommunity_run](https://github.com/CryoGrid/CryoGridCommunity_run) are required. See [CryoGridCommunity_run](https://github.com/CryoGrid/CryoGridCommunity_run) for details.
