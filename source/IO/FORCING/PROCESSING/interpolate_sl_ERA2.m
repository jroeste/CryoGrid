%========================================================================
% CryoGrid FORCING processing class interpolate_sl_ERA2
% uses interpolation of Sin relying on S_TOA 
%
% Authors:
% S. Westermann, December 2022
%
%========================================================================

classdef interpolate_sl_ERA2 < process_BASE
    

    methods
        function proc = provide_PARA(proc)

        end
        
        
        function proc = provide_CONST(proc)
            proc.CONST.Tmfw = [];
        end
        
        
        function proc = provide_STATVAR(proc)
            
        end
        
        
        function proc = finalize_init(proc, tile)

        end
        
        
        function forcing = process(proc, forcing, tile)
            
            disp('interpolating surface level data')
            era = forcing.TEMP.era;
            if length(double(era.lat))>1 && length(double(era.lon))>1
                single_cell=0;
            else
                single_cell=1;
            end
            if single_cell
                ind_lon=1;
                ind_lat=1;
            else
                dist_lat = abs(forcing.SPATIAL.STATVAR.latitude - era.lat);
                dist_lon=abs(forcing.SPATIAL.STATVAR.longitude-era.lon);
                [dist_lat, ind_lat] = sort(dist_lat);
                [dist_lon, ind_lon] = sort(dist_lon);
                
                dist_lat=dist_lat(1:2);
                ind_lat = ind_lat(1:2);
                weights_lat = 1 - dist_lat./sum(dist_lat);
                dist_lon=dist_lon(1:2);
                ind_lon = ind_lon(1:2);
                weights_lon = 1 - dist_lon./sum(dist_lon);
            end
            weights_lat2=double(weights_lat);
            weights_lon2=double(weights_lon);
            
            era_T_sl  = double(era.T2(ind_lon, ind_lat, :)) .* era.T_sf;
            era_wind_sl = sqrt(double(era.u10(ind_lon, ind_lat, :)).^2 + double(era.v10(ind_lon, ind_lat, :)) .^2) .* era.wind_sf;
            era_Lin_sl = double(era.LW(ind_lon, ind_lat, :)).*era.rad_sf;
            era_Sin_sl = double(era.SW(ind_lon, ind_lat, :)).*era.rad_sf;
            era_S_TOA_sl = double(era.S_TOA(ind_lon, ind_lat, :)).*era.rad_sf;          
            era_kd = double(era_Sin_sl) ./ double(era_S_TOA_sl);
            era_kd(era_Sin_sl<3) = NaN;
            era_precip_sl = double(era.P(ind_lon, ind_lat, :)).*era.P_sf;
            era_p_sl = double(era.ps(ind_lon, ind_lat, :)) .* era.ps_sf;
            era_Td_sl = double(era.Td2(ind_lon, ind_lat, :)).* era.T_sf;
            
            if ~single_cell
                era_T_sl = reshape(era_T_sl, 4,1, size(era_T_sl,3));
                era_wind_sl = reshape(era_wind_sl, 4,1, size(era_wind_sl,3));
                era_Lin_sl = reshape(era_Lin_sl, 4,1, size(era_Lin_sl,3));
                era_Sin_sl = reshape(era_Sin_sl, 4,1, size(era_Sin_sl,3));
                era_S_TOA_sl = reshape(era_S_TOA_sl, 4,1, size(era_S_TOA_sl,3));
                era_kd = reshape(era_kd, 4,1, size(era_kd,3));
                era_precip_sl = reshape(era_precip_sl, 4,1, size(era_precip_sl,3));
                era_p_sl = reshape(era_p_sl, 4,1, size(era_p_sl,3));
                era_Td_sl = (reshape(era_Td_sl, 4,1, size(era_Td_sl,3))) ;
            end
            
            era_q_sl = 0.622 .* (double(era_T_sl>=0) .* satPresWater(proc, era_Td_sl+273.15) + double(era_T_sl<0) .* satPresIce(proc, era_Td_sl+273.15)) ./ era_p_sl;
            
            if ~single_cell
                weights_lat = repmat(weights_lat', 2, 1, 1,size(era_T_sl,3));
                weights_lat=reshape(weights_lat, 4, 1 , size(era_T_sl,3));
                weights_lon = repmat(weights_lon, 1, 2, 1, size(era_T_sl,3));
                weights_lon=reshape(weights_lon, 4, 1 , size(era_T_sl,3));
                
                era_wind_sl = era_wind_sl .* weights_lat;
                era_wind_sl = (era_wind_sl(1:2,:,:) +era_wind_sl(3:4,:,:));
                era_q_sl = era_q_sl .* double(weights_lat);
                era_q_sl = (era_q_sl(1:2,:,:) + era_q_sl(3:4,:,:));
                era_Lin_sl = era_Lin_sl .* weights_lat;
                era_Lin_sl = (era_Lin_sl(1:2,:,:) + era_Lin_sl(3:4,:,:));
                era_T_sl = double(era_T_sl) .* weights_lat;
                era_T_sl = (era_T_sl(1:2,:,:) + era_T_sl(3:4,:,:));
                era_Sin_sl = era_Sin_sl .* weights_lat;
                era_Sin_sl = (era_Sin_sl(1:2,:,:) + era_Sin_sl(3:4,:,:));
                era_S_TOA_sl = era_S_TOA_sl .* weights_lat;
                era_S_TOA_sl = (era_S_TOA_sl(1:2,:,:) + era_S_TOA_sl(3:4,:,:));
                
                %interpolate kd
                kd_1 = era_kd(1,:,:); kd_3 = era_kd(3,:,:);
                kd_1_NaN = isnan(kd_1);  kd_3_NaN = isnan(kd_3); 
                kd_1(kd_1_NaN) = 0;  kd_3(kd_3_NaN) = 0;
                weights_lat_kd_1 = double(kd_3_NaN & ~kd_1_NaN) .* 1 + double(~kd_3_NaN & kd_1_NaN) .* 0 + double(~kd_3_NaN & ~kd_1_NaN) .* weights_lat2(1);
                weights_lat_kd_1(kd_3_NaN & kd_1_NaN) = NaN;
                weights_lat_kd_3 = double(~kd_3_NaN & kd_1_NaN) .* 1 + double(kd_3_NaN & ~kd_1_NaN) .* 0 + double(~kd_3_NaN & ~kd_1_NaN) .* weights_lat2(2);
                weights_lat_kd_3(kd_3_NaN & kd_1_NaN) = NaN;
                kd_1 = weights_lat_kd_1 .* kd_1 + weights_lat_kd_3 .* kd_3;
                
                kd_2 = era_kd(2,:,:); kd_4 = era_kd(4,:,:);
                kd_2_NaN = isnan(kd_2);  kd_4_NaN = isnan(kd_4); 
                kd_2(kd_2_NaN) = 0;  kd_4(kd_4_NaN) = 0;
                weights_lat_kd_2 = double(kd_4_NaN & ~kd_2_NaN) .* 1 + double(~kd_4_NaN & kd_2_NaN) .* 0 + double(~kd_4_NaN & ~kd_2_NaN) .* weights_lat2(1);
                weights_lat_kd_2(kd_4_NaN & kd_2_NaN) = NaN;
                weights_lat_kd_4 = double(~kd_4_NaN & kd_2_NaN) .* 1 + double(kd_4_NaN & ~kd_2_NaN) .* 0 + double(~kd_4_NaN & ~kd_2_NaN) .* weights_lat2(2);
                weights_lat_kd_4(kd_4_NaN & kd_2_NaN) = NaN;                
                kd_2 = weights_lat_kd_2 .* kd_2 + weights_lat_kd_4 .* kd_4;
                
                kd_1_NaN = isnan(kd_1); kd_2_NaN = isnan(kd_2);
                kd_1(kd_1_NaN) = 0; kd_2(kd_2_NaN) = 0;
                weights_lon_kd_1 = double(kd_2_NaN & ~kd_1_NaN) .* 1 + double(~kd_2_NaN & kd_1_NaN) .* 0 + double(~kd_2_NaN & ~kd_1_NaN) .* weights_lon2(1);
                weights_lon_kd_1(kd_2_NaN & kd_1_NaN) = NaN; 
                weights_lon_kd_2 = double(~kd_2_NaN & kd_1_NaN) .* 1 + double(kd_2_NaN & ~kd_1_NaN) .* 0 + double(~kd_2_NaN & ~kd_1_NaN) .* weights_lon2(2);
                weights_lon_kd_2(kd_2_NaN & kd_1_NaN) = NaN;
                era_kd = weights_lon_kd_1 .* kd_1 + weights_lon_kd_2 .* kd_2;
                era_kd(isnan(era_kd)) = 0.5;
                era_kd = squeeze(era_kd);
                %end interpolate kd
                
                era_precip_sl = era_precip_sl .* weights_lat;
                era_precip_sl = (era_precip_sl(1:2,:,:) + era_precip_sl(3:4,:,:));
                era_p_sl = era_p_sl .* weights_lat;
                era_p_sl = (era_p_sl(1:2,:,:) + era_p_sl(3:4,:,:));
                
                weights_lon = (weights_lon(1:2,:,:) + weights_lon(3:4,:,:))./2;
                era_T_sl = squeeze(sum(era_T_sl .* weights_lon,1));
                era_wind_sl = squeeze(sum(era_wind_sl .* weights_lon,1));
                era_q_sl = squeeze(sum(era_q_sl .* double(weights_lon),1));
                era_Lin_sl = squeeze(sum(era_Lin_sl .* weights_lon,1));
                era_Sin_sl = squeeze(sum(era_Sin_sl .* weights_lon,1));
                era_S_TOA_sl = squeeze(sum(era_S_TOA_sl .* weights_lon,1));       
                era_precip_sl = squeeze(sum(era_precip_sl .* weights_lon,1));
                era_p_sl = squeeze(sum(era_p_sl .* weights_lon,1));
            else
                era_T_sl = squeeze(era_T_sl);
                era_wind_sl = squeeze(era_wind_sl);
                era_q_sl = squeeze(era_q_sl);
                era_Lin_sl = squeeze(era_Lin_sl);
                era_Sin_sl = squeeze(era_Sin_sl);
                era_S_TOA_sl = squeeze(era_S_TOA_sl);
                era_kd = squeeze(era_kd);
                era_kd(isnan(era_kd)) = 0.5;
                era_precip_sl = squeeze(era_precip_sl);
                era_p_sl = squeeze(era_p_sl);
            end
            
            [~, sunElevation] = solargeom(proc, era.t, forcing.SPATIAL.STATVAR.latitude, forcing.SPATIAL.STATVAR.longitude);
            sunElevation = 90-rad2deg(sunElevation);
            mu0=max(sind(sunElevation),0); % Trunacte negative values.
            S_TOA = 1370.*mu0';
            
            forcing.DATA.Tair = double(era_T_sl);
            forcing.DATA.q = double(era_q_sl);
            forcing.DATA.wind = double(era_wind_sl);
            forcing.DATA.Sin =  double(era_kd .* S_TOA);
            forcing.DATA.Lin = double(era_Lin_sl);
            forcing.DATA.S_TOA = double(era_S_TOA_sl);            
            forcing.DATA.p = double(era_p_sl);
            forcing.DATA.precip = double(era_precip_sl) .*24;  %mm/hour to mm/day
            forcing.DATA.timeForcing = era.t';
            
            forcing.TEMP.era = [];
            
        end
        
        

        
                %-------------param file generation-----
%         function post_proc = param_file_info(post_proc)
%             post_proc = provide_PARA(post_proc);
% 
%             post_proc.PARA.STATVAR = [];
%             post_proc.PARA.class_category = 'FORCING POST_PROCESSING';
%             post_proc.PARA.options = [];
%             
%             post_proc.PARA.eliminate_fraction = [];
%             post_proc.PARA.survive_fraction = [];
%                         
%             post_proc.PARA.default_value.window_size = {7};
%             post_proc.PARA.comment.window_size = {'window size in days within which precipitation is reallocated'};
%             
%             post_proc.PARA.default_value.eliminate_fraction = {0.5};
%             post_proc.PARA.comment.eliminate_fraction = {'fraction of smallest precipitation events (= timestamps with precipitation) that is reallocated to larger events'};
%             
%             post_proc.PARA.default_value.survive_fraction = {0.5};  
%             post_proc.PARA.comment.survive_fraction = {'fraction of largest precipitation events (= timestamps with precipitation) that the small events are reallocated to'};
%             
%         end
        
    end
    
end

