clear;
clc;

addpath('./topotoolbox')
addpath('./topotoolbox/tools_and_more/')
addpath('./topotoolbox/topoapp/')


[filename,pathname] = uigetfile('*.shp', 'Select catchment shapefile');
shapefile = fullfile(pathname, filename);

[filename,pathname] = uigetfile('*.tif', 'Select DEM');
dem = fullfile(pathname, filename);

output_location = uigetdir;


% SETTINGS

FID_column = 'ID';

stream_pixel_threshold = 300; % pixels

n_slope_area_bins = 100;

aggregrate_ksn_length = 1000; % metres (must be greater than S.cellsize*3)

proj_data = 'PROJCS["WGS_1984_UTM_Zone_37N",GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",39],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["Meter",1]]';


Shp = shaperead(shapefile);


% Output matrices

c_IDs = nan(numel(Shp), 1); % catchment ids
c_KSN = nan(numel(Shp), 1); % catchment ksn
thetas = nan(numel(Shp), 1); % catchment concavity

for i = 1:numel(Shp)
    
	poly = Shp(i);
    
    if poly.AREA < 5000
        continue
    end
    
    c_ID = poly.(FID_column);

    
    DEM = GRIDobj(dem);

    [r,c] = coord2sub(DEM,poly.X,poly.Y);
    
    %Remove NaNs
    n = find(isnan(r));
    r(n) = [];
    c(n) = [];

    % convert points outside catchment poly to NaN
    mask = poly2mask(c,r,DEM.size(1),DEM.size(2));

    DEM.Z(find(mask==0)) = NaN;

    cDEM = crop(DEM, mask);

    FD = FLOWobj(cDEM, 'preprocess','carve');
    cDEM = imposemin(FD,cDEM,0.0001);
=
    % Flow Accumulation
    A = flowacc(FD);

    % Streams
    S1 = STREAMobj(FD,A>stream_pixel_threshold);
    S = klargestconncomps(S1,1);
    S = trunk(S);
    X = 42.0;                  %# A3 paper size
    Y = 29.7;                  %# A3 paper size
    xMargin = 0;               %# left/right margins from page borders
    yMargin = 2;               %# bottom/top margins from page borders
    xSize = X - 2*xMargin;     %# figure size on paper (widht & hieght)
    ySize = Y - 2*yMargin;     %# figure size on paper (widht & hieght)


    
    % Gradients
    G   = gradient8(cDEM);
    
    % Upstream area
    a = A.Z(S.IXgrid).*(A.cellsize).^2;
    
    % Binned slope area calc
    STATS = slopearea_ksn(S,cDEM,A, 'areabins', aggregrate_ksn_length, 'plot', false);

    c_IDs(i) = c_ID;
    c_KSN(i) = STATS.ks;
    thetas(i) = STATS.theta;
    
    % Localised KSN
    
    KSN = G./(A.*(A.cellsize^2)).^-.45;
    [x,y,ksn] = STREAMobj2XY(S,KSN);

    f = figure('Menubar','none');
    set(f,'visible','off');
    set(f, 'PaperSize',[X X]);
    set(f, 'PaperPosition',[0 xMargin xSize xSize])
    set(f, 'PaperUnits','centimeters');
    
    MS = STREAMobj2mapstruct(S,'seglength',aggregrate_ksn_length,'attributes',...
    {'ksn' KSN @mean 'uparea' (A.*(A.cellsize^2)) @mean 'gradient' G @mean});
    symbolspec = makesymbolspec('line',...
        {'ksn' [min([MS.ksn]) max([MS.ksn])] 'color' jet(6)});
    colorbar;
    imageschs(cDEM,cDEM,'colormap',gray,'colorbar',false);
    mapshow(MS,'SymbolSpec',symbolspec);
    caxis([min([MS.ksn]) max([MS.ksn])]);
    contourcbar;
    print('-noui',[output_location ,'/', num2str(c_ID),'_ksn_plot'], '-dpdf')
    shapewrite(MS, [output_location ,'/', num2str(c_ID),'_ksn.shp']);
    
    % Write projection file
    
    fid = fopen([output_location ,'/', num2str(c_ID),'_ksn.prj'],'w');
    fprintf(fid,proj_data);
    fclose(fid);
    
    f = figure('Menubar','none');
    set(f,'visible','off');
    set(f, 'PaperSize',[X Y]);
    set(f, 'PaperPosition',[0 yMargin xSize ySize])
    set(f, 'PaperUnits','centimeters');

    sb1 = subplot(2,3,1);
    max_val = max(cDEM.Z(:));
    vdata = cDEM;
    vdata.Z(isnan(vdata.Z)) = max_val + max_val/10;
    imagesc(vdata);
    colormap bone;
    colorbar
    hold on;
    plot(S);
    title(['Catchment ', num2str(c_ID)]);
    
    subplot(2,3,4);
    SA = slopearea(S1,cDEM,A);
    sa_values = {['\bf \theta', '\rm ',  num2str(SA.theta)], ...
        ['\bf ks ', '\rm ',  num2str(SA.ks)]
    };
    DataX = interp1( [0 1], xlim(), 0.01 );
    DataY = interp1( [0 1], ylim(), 0.01 );
    
    text(DataX,DataY,sa_values,'EdgeColor', 'black', 'FontSize', 14);
    
    title('Slope v Area');

    subplot(2,3,2);
    axis equal tight
    SO = streamorder(S1, 'plot');
    title('Stream order (Strahler)');
    
    subplot(2,3,3)
    axis normal
    plotdz(S,cDEM);
    title('Stream profile elevation');
    
    S1 = klargestconncomps(S1);
    T = trunk(S1);

    subplot(2,3,5);

    C = chiplot(S1,cDEM, A, 'trunkstream', T);
    title('Chi Plot');

    sb1 = subplot(2,3,6);

    chi_values = {['\bf mn', '\rm ',  num2str(C.mn)], ...
        ['\bf beta ', '\rm ',  num2str(C.beta)], ...
        ['\bf betase  ', '\rm ',  num2str(C.betase)], ...
        ['\bf a0  ', '\rm ',  num2str(C.a0)], ...
        ['\bf ks  ', '\rm ',  num2str(C.ks)], ...
        ['\bf R^{2}  ', '\rm ',  num2str(C.R2)]
    };

    h = text(0,0.5, chi_values,'EdgeColor', 'black', 'FontSize', 14); axis off;

    title('Chi Values');

    print('-noui',[output_location, '/', num2str(c_ID), '_plots'], '-dpdf')
    
    ksn = ksn(1:end-1);
    local_slope = gradient(S, cDEM);
    distance = S.distance;
    x = S.x;
    y = S.y;
    upstream_area = a;
    elevation = cDEM.Z(S.IXgrid);

    
    results = table(distance, x, y, elevation, local_slope, upstream_area, ksn);
    writetable(results,[output_location, '/', num2str(c_ID) '.csv']);
    
end

fid = fopen([output_location, '/catchment_averages_data.csv'],'w');
fprintf(fid,'%s\r\n','catchment,ksn,theta');
fclose(fid);

average_data = [c_IDs, c_KSN, thetas];
average_data = average_data(~any(isnan(average_data),2),:);

dlmwrite([output_location, '/catchment_averages_data.csv'], average_data, '-append' ...
    , 'delimiter', ',');
