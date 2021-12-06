%========================================================================
% CryoGrid FORCING class FORCING_seb
% simple model forcing for GROUND classes computing the surface energy balance 
% (keyword �seb�). The data must be stored in a Matlab �.mat� file which contains 
% a struct FORCING with field �data�, which contain the time series of the actual 
% forcing data, e.g. FORCING.data.Tair contains the time series of air temperatures. 
% Have a look at the existing forcing files in the folder �forcing� and prepare 
% new forcing files in the same way. The mandatory forcing variables are air temperature 
% (Tair, in degree Celsius), incoming long-wave radiation (Lin, in W/m2), 
% incoming short-.wave radiation (Sin, in W/m2), absolute humidity (q, in 
% kg water vapor / kg air), wind speed (wind, in m/sec), rainfall (rainfall, in mm/day), 
% snowfall (snowfall, in mm/day) and timestamp (t_span, 
% in Matlab time / increment 1 corresponds to one day). 
% IMPORTANT POINT: the time series must be equally spaced in time, and this must be 
% really exact. When reading the timestamps from an existing data set (e.g. an Excel file),
% rounding errors can result in small differences in the forcing timestep, often less 
% than a second off. In this case, it is better to manually compile a new, equally spaced 
% timestep in Matlab.
% S. Westermann, T. Ingeman-Nielsen, J. Scheer, October 2020
%========================================================================

classdef FORCING_do_nothing < matlab.mixin.Copyable
    
    properties
        forcing_index
        DATA            % forcing data time series
        TEMP            % forcing data interpolated to a timestep
        PARA            % parameters
        STATUS         
        CONST
    end
    
    
    methods
        
        
        function forcing = provide_PARA(forcing)         

        end
        
        
        
        function forcing = provide_CONST(forcing)
            
        end
        
        function forcing = provide_STATVAR(forcing)
            forcing.PARA.start_time = []; % start time of the simulations (must be within the range of data in forcing file)
            forcing.PARA.end_time = [];   % end time of the simulations (must be within the range of data in forcing file)
        end
        
        
        
        function forcing = finalize_init(forcing, tile)
            
            forcing.PARA.start_time = datenum(forcing.PARA.start_time(1,1), forcing.PARA.start_time(2,1), forcing.PARA.start_time(3,1));
            forcing.PARA.end_time = datenum(forcing.PARA.end_time(1,1), forcing.PARA.end_time(2,1),forcing.PARA.end_time(3,1));

         end
        
        function forcing = interpolate_forcing(forcing, tile)
            t = tile.t;
            
            forcing.TEMP.snowfall=0;%forcing.DATA.snowfall(posit,1)+(forcing.DATA.snowfall(posit+1,1)-forcing.DATA.snowfall(posit,1)).*(t-forcing.DATA.timeForcing(posit,1))./(forcing.DATA.timeForcing(2,1)-forcing.DATA.timeForcing(1,1));
            
            forcing.TEMP.rainfall=0; %forcing.DATA.rainfall(posit,1)+(forcing.DATA.rainfall(posit+1,1)-forcing.DATA.rainfall(posit,1)).*(t-forcing.DATA.timeForcing(posit,1))./(forcing.DATA.timeForcing(2,1)-forcing.DATA.timeForcing(1,1));
            
            forcing.TEMP.Lin= 0; %forcing.DATA.Lin(posit,1)+(forcing.DATA.Lin(posit+1,1)-forcing.DATA.Lin(posit,1)).*(t-forcing.DATA.timeForcing(posit,1))./(forcing.DATA.timeForcing(2,1)-forcing.DATA.timeForcing(1,1));
            
            forcing.TEMP.Sin=0 ; %forcing.DATA.Sin(posit,1)+(forcing.DATA.Sin(posit+1,1)-forcing.DATA.Sin(posit,1)).*(t-forcing.DATA.timeForcing(posit,1))./(forcing.DATA.timeForcing(2,1)-forcing.DATA.timeForcing(1,1));
            
            forcing.TEMP.Tair=0; %forcing.DATA.Tair(posit,1)+(forcing.DATA.Tair(posit+1,1)-forcing.DATA.Tair(posit,1)).*(t-forcing.DATA.timeForcing(posit,1))./(forcing.DATA.timeForcing(2,1)-forcing.DATA.timeForcing(1,1));
            
            forcing.TEMP.wind=0; %forcing.DATA.wind(posit,1)+(forcing.DATA.wind(posit+1,1)-forcing.DATA.wind(posit,1)).*(t-forcing.DATA.timeForcing(posit,1))./(forcing.DATA.timeForcing(2,1)-forcing.DATA.timeForcing(1,1));
            
            forcing.TEMP.q=0; %forcing.DATA.q(posit,1)+(forcing.DATA.q(posit+1,1)-forcing.DATA.q(posit,1)).*(t-forcing.DATA.timeForcing(posit,1))./(forcing.DATA.timeForcing(2,1)-forcing.DATA.timeForcing(1,1));
            
            forcing.TEMP.p=1e5;%forcing.DATA.p(posit,1)+(forcing.DATA.p(posit+1,1)-forcing.DATA.p(posit,1)).*(t-forcing.DATA.timeForcing(posit,1))./(forcing.DATA.timeForcing(2,1)-forcing.DATA.timeForcing(1,1));

            forcing.TEMP.t = t;
        end

                
    end
end