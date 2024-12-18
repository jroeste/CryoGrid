classdef DEM_gmted < matlab.mixin.Copyable

    properties
        PARENT
        PARA
        CONST
        STATVAR
        TEMP
    end

    
    methods
        
        function dem = provide_PARA(dem)
            dem.PARA.DEM_file = [];
            dem.PARA.DEM_path = [];
        end
        
        function dem = provide_STATVAR(dem)

        end
        
        function dem = provide_CONST(dem)
            
        end
        
        function dem = finalize_init(dem)
            
        end
        
        function dem = load_data(dem)
                        
            %get corner coordinates of ROI
            minLat = min(dem.PARENT.STATVAR.latitude);
            maxLat = max(dem.PARENT.STATVAR.latitude);
            minLong = min(dem.PARENT.STATVAR.longitude);
            maxLong = max(dem.PARENT.STATVAR.longitude);
            
            %read global DEM - this can be problematic, 17GB file size!!
            %[DEM, R]= geotiffread([dem.PARA.DEM_path dem.PARA.DEM_file]);
%             DEM_latitudes= R.LatitudeLimits;
%             DEM_longitudes= R.LongitudeLimits;
            
%             %make a separate list of longitudes and latitudes pixels from DEM
%             DEM_latitude_list=linspace(max(DEM_latitudes), min(DEM_latitudes), size(DEM,1))';
%             DEM_longitude_list=linspace(min(DEM_longitudes), max(DEM_longitudes), size(DEM,2));
            DEM_latitude_list = ncread([dem.PARA.DEM_path dem.PARA.DEM_file], 'latitude');
            DEM_longitude_list = ncread([dem.PARA.DEM_path dem.PARA.DEM_file], 'longitude');
            
            %Find the indeces of coordinates in the list that corresponds with MODIS extent coordinates
            [mini, maxPosLat]=min(abs(maxLat-DEM_latitude_list)); %finding an index of an value where where the difference between MODIS latitude and DEM latitude is the smallest
            maxPosLat=max(1,maxPosLat-5); %expanding the border by 5 pixels unless out of a list range
            
            [mini, minPosLat]=min(abs(minLat-DEM_latitude_list));
            minPosLat=min(size(DEM_latitude_list,1),minPosLat+5);
            
            [mini, minPosLon]=min(abs(minLong-DEM_longitude_list));
            minPosLon=max(1,minPosLon-5);
            
            [mini, maxPosLon]=min(abs(maxLong-DEM_longitude_list));
            maxPosLon=min(size(DEM_longitude_list,1),maxPosLon+5);
            
            %subset the DEM based on indexes from coordinate lists to MODIS extent
%             DEM=DEM(maxPosLat:minPosLat, minPosLon:maxPosLon);
%             DEM=double(DEM);
            DEM = double(ncread([dem.PARA.DEM_path dem.PARA.DEM_file], 'dem', [maxPosLat minPosLon], [minPosLat-maxPosLat+1  maxPosLon-minPosLon+1], [1 1]));
            %subset DEM coordinate vectors
            DEM_latitude_list = DEM_latitude_list(maxPosLat:minPosLat);
            DEM_longitude_list = DEM_longitude_list(minPosLon:maxPosLon);
            
            %create coordinate matrices that are used for interpolation reference
            [DEM_latitudes, DEM_longitudes]=meshgrid(DEM_latitude_list, DEM_longitude_list);
            DEM_latitudes = DEM_latitudes';
            DEM_longitudes = DEM_longitudes';
            
            %interpolation to a MODIS grid usind cubic interpolation
            dem.PARENT.STATVAR.altitude = max(0, interp2(DEM_latitudes', DEM_longitudes', DEM', dem.PARENT.STATVAR.latitude, dem.PARENT.STATVAR.longitude, 'cubic'));
            
        end
        
    end
end

