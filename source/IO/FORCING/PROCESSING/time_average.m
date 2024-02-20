%========================================================================
% CryoGrid FORCING processing class time_average
%
% coverts high time-res forcng data to low-res data used by ESA_CCI model 
%
% Authors:
% S. Westermann, December 2022
%
%========================================================================

%RENAME THIS CLASS AT SOME POINT!!

classdef time_average < matlab.mixin.Copyable 
    
    properties
        
    end
    
    methods
        function proc = provide_PARA(proc)
            
            proc.PARA.averaging_period = [];  %in days
            proc.PARA.all_snow_T = [];
            proc.PARA.all_rain_T = [];
            
            %these can be written by ensemble class
            proc.PARA.ensemble_size = 1;
            proc.PARA.absolute_change_Tair = 0;
            proc.PARA.snow_fraction = 1;
            proc.PARA.rain_fraction = 1;
            proc.PARA.relative_change_Sin = 1;     
            proc.PARA.relative_change_degree_day_factor = 1;
            
            
            proc.PARA.emissivity_snow = 0.99; % Snow emissivity (assumed known).
            
            proc.PARA.taus=0.0025; % Threshold snowfall for resetting to maximum [m w.e.].
            proc.PARA.taua=0.008; % Time constant for snow albedo change in non-melting conditions [/day].
            proc.PARA.tauf=0.24; % Time constant for snow albedo change in melting conditions [/day].
            
            proc.PARA.albsmax=0.85; % Maximum snow albedo.
            proc.PARA.albsmin=0.5; % Minimum snow albedo.
            
            proc.PARA.degree_day_factor=0.2/1e2; % Restricted degree day factor (m*degC/day , value from Burbaker et al. 1996)
        end
        
        
        function proc = provide_CONST(proc)
            proc.CONST.L_f = []; 
            proc.CONST.sigma = [];
            proc.CONST.day_sec = [];
            proc.CONST.Tmfw = [];
        end
        
        
        function proc = provide_STATVAR(proc)
            
        end
        
        
        function proc = finalize_init(proc, tile)
            proc.STATVAR.Lupwelling = proc.PARA.emissivity_snow.*proc.CONST.sigma.*proc.CONST.Tmfw.^4; % upwelling longwave radiation for melting snow, T=273.15K
            proc.STATVAR.albedo = repmat(proc.PARA.albsmax, 1, proc.PARA.ensemble_size); %initialize 1st albedo values 
            
            if size(proc.PARA.absolute_change_Tair,2)==1 
                proc.PARA.absolute_change_Tair = repmat(proc.PARA.absolute_change_Tair,1, proc.PARA.ensemble_size);
            end   
            if size(proc.PARA.snow_fraction,2)==1 
                proc.PARA.snow_fraction = repmat(proc.PARA.snow_fraction,1, proc.PARA.ensemble_size);
            end
            if size(proc.PARA.rain_fraction,2)==1
                proc.PARA.rain_fraction = repmat(proc.PARA.rain_fraction,1, proc.PARA.ensemble_size);
            end
            if size(proc.PARA.relative_change_Sin,2)==1
                proc.PARA.relative_change_Sin = repmat(proc.PARA.relative_change_Sin,1, proc.PARA.ensemble_size);
            end
            if size(proc.PARA.relative_change_degree_day_factor,2)==1
                proc.PARA.relative_change_degree_day_factor = repmat(proc.PARA.relative_change_degree_day_factor,1, proc.PARA.ensemble_size);
            end
        end
        
        
        function forcing = process(proc, forcing, tile)
            
            data_full = forcing.DATA;
            forcing.DATA = [];
            forcing.DATA.snowfall = [];
            forcing.DATA.rainfall = [];
            forcing.DATA.melt = [];
            forcing.DATA.surfT = [];
            forcing.DATA.timeForcing = [];
            
            for i = data_full.timeForcing(1,1):proc.PARA.averaging_period:data_full.timeForcing(end,1)-proc.PARA.averaging_period
                range = find(data_full.timeForcing>=i & data_full.timeForcing < min(data_full.timeForcing(end,1), i + proc.PARA.averaging_period));
                forcing.DATA.timeForcing = [forcing.DATA.timeForcing; mean(data_full.timeForcing(range,1))];
                forcing.DATA.surfT = [forcing.DATA.surfT; mean(data_full.Tair(range,1)) + proc.PARA.absolute_change_Tair];
                sf = 0;
                rf = 0;
                for j=1:size(range,1)
                    precip = data_full.snowfall(range(j),1) + data_full.rainfall(range(j),1);
                    factor = max(0, min(1, (data_full.Tair(range(j),1) + proc.PARA.absolute_change_Tair - proc.PARA.all_snow_T) ./ max(1e-12, (proc.PARA.all_rain_T - proc.PARA.all_snow_T))));
                    sf = sf + precip.*(1 - factor);
                    rf = rf + precip.*factor;
                end
                forcing.DATA.snowfall = [forcing.DATA.snowfall; sf./size(range,1) .* proc.PARA.snow_fraction];
                forcing.DATA.rainfall = [forcing.DATA.rainfall; rf./size(range,1) .* proc.PARA.rain_fraction];
                
                melt_depth = 0;
                for j = 0:proc.PARA.averaging_period-1 %loop over individual days
                    range = find(data_full.timeForcing>=i+j & data_full.timeForcing < min(data_full.timeForcing(end,1), i+j+1));
                    
                    % Ablation term
                    Lin = 0;
                    Sin = 0;
                    sf = 0;
                    for k=1:size(range,1)
                        sky_emissivity = data_full.Lin(range(k),1) ./ (data_full.Tair(range(k),1)+273.15).^4 ./ proc.CONST.sigma;
                        Lin = Lin + sky_emissivity .* proc.CONST.sigma .* (data_full.Tair(range(k),1) + 273.15 + proc.PARA.absolute_change_Tair).^4;
                        Sin = Sin + data_full.Sin(range(k),1) .*  proc.PARA.relative_change_Sin;
                        precip = data_full.snowfall(range(k),1) + data_full.rainfall(range(k),1);
                        factor = max(0, min(1, (data_full.Tair(range(k),1) - proc.PARA.all_snow_T) ./ max(1e-12, (proc.PARA.all_rain_T - proc.PARA.all_snow_T))));
                        sf = sf + precip.*(1 - factor);
                    end
                    
                    LW_net = proc.PARA.emissivity_snow .* Lin ./ size(range,1) - proc.STATVAR.Lupwelling; % Net  longwave
                    SW_net = (1-proc.STATVAR.albedo) .* Sin ./ size(range,1); % Net shortwave
                    SH_net = proc.PARA.relative_change_degree_day_factor .* proc.PARA.degree_day_factor .* mean(data_full.Tair(range,1)); % Warming through turbulent heat fluxes, parametrized using a restricted degree day approach.
                    
                    daily_melt_depth = (LW_net + SW_net + SH_net) .* proc.CONST.day_sec ./ proc.CONST.L_f .* 1000;
                    melt_depth = melt_depth + daily_melt_depth; % Melt depth over the time step.

                    % Update snow albedo for next step.
                    % Latest ECMWF "continuous reset" snow albedo scheme (Dutra et al. 2010)
                    new_snow = sf./size(range,1) .* proc.PARA.snow_fraction; % mean(data_full.snowfall(range,1)); %in mm/day

                    net_acc = new_snow - max(0,daily_melt_depth); % Net accumulation for one day time-step.
                    constr = net_acc>0;
                    proc.STATVAR.albedo(1, constr) = proc.STATVAR.albedo(1, constr) + min(1,net_acc(1, constr)./(proc.PARA.taus .* 1000)) .* (proc.PARA.albsmax - proc.STATVAR.albedo(1, constr));
                    constr = net_acc==0; %"Steady" case (linear decay)
                    proc.STATVAR.albedo(1, constr) = proc.STATVAR.albedo(1, constr) - proc.PARA.taua;
                    constr = net_acc<0;
                    proc.STATVAR.albedo(1, constr) = (proc.STATVAR.albedo(1, constr) - proc.PARA.albsmin) .* exp(-proc.PARA.tauf) + proc.PARA.albsmin;
                    proc.STATVAR.albedo(proc.STATVAR.albedo < proc.PARA.albsmin) = proc.PARA.albsmin;

                end
                melt_depth(melt_depth <0) = 0;
                forcing.DATA.melt = [forcing.DATA.melt; melt_depth ./ proc.PARA.averaging_period];  %in mm/day
                
            end
            
            if size(forcing.PARA.heatFlux_lb,2) == 1
                tile.PARA.geothermal = repmat(forcing.PARA.heatFlux_lb, 1, proc.PARA.ensemble_size);
            end
            
            %overwrite target variables in TEMP in FORCING
            forcing.TEMP = [];
            forcing.TEMP.snowfall=0;
            forcing.TEMP.melt = 0;
            forcing.TEMP.surfT = 0;
        end
        
        
%                 %-------------param file generation-----
%         function proc = param_file_info(proc)
%             proc = provide_PARA(proc);
% 
%             proc.PARA.STATVAR = [];
%             proc.PARA.class_category = 'FORCING POST_PROCESSING';
%             proc.PARA.options = [];
%             
%             proc.PARA.eliminate_fraction = [];
%             proc.PARA.survive_fraction = [];
%                         
%             proc.PARA.default_value.window_size = {7};
%             proc.PARA.comment.window_size = {'window size in days within which precipitation is reallocated'};
%             
%             proc.PARA.default_value.eliminate_fraction = {0.5};
%             proc.PARA.comment.eliminate_fraction = {'fraction of smallest precipitation events (= timestamps with precipitation) that is reallocated to larger events'};
%             
%             proc.PARA.default_value.survive_fraction = {0.5};  
%             proc.PARA.comment.survive_fraction = {'fraction of largest precipitation events (= timestamps with precipitation) that the small events are reallocated to'};
%             
%         end
        
    end
    
end