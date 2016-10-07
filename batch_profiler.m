clear;
clc;

addpath('./topotoolbox')
addpath('./topotoolbox/tools_and_more/')
addpath('./topotoolbox/topoapp/')

[filename,pathname] = uigetfile('*.shp', 'Select catchment shapefile');
shapefile = fullfile(pathname, filename)

[filename,pathname] = uigetfile('*.tif', 'Select DEM');
dem = fullfile(pathname, filename)

output_location = uigetdir;

S = shaperead(shapefile);
for i = 1:numel(S)
	poly = S(i);
    
    polyarea(poly.X, poly.Y)

    c_ID = poly.ID; % IMPORTANT!!!
    
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

    FD = FLOWobj(cDEM);

    % Flow Accumulation
    A = flowacc(FD);

    % Streams
    S1 = STREAMobj(FD,A>300);

    X = 42.0;                  %# A3 paper size
    Y = 29.7;                  %# A3 paper size
    xMargin = 0;               %# left/right margins from page borders
    yMargin = 2;               %# bottom/top margins from page borders
    xSize = X - 2*xMargin;     %# figure size on paper (widht & hieght)
    ySize = Y - 2*yMargin;     %# figure size on paper (widht & hieght)

    f = figure('Menubar','none');
    set(f,'visible','off');
    set(f, 'PaperSize',[X Y]);
    set(f, 'PaperPosition',[0 yMargin xSize ySize])
    set(f, 'PaperUnits','centimeters');

    % 2 x 3 subplots

    sb1 = subplot(2,3,1);
    max_val = max(cDEM.Z(:));
    vdata = cDEM;
    vdata.Z(isnan(vdata.Z)) = max_val + max_val/10;
    imagesc(vdata);
    colormap bone;
    colorbar
    hold on;
    plot(S1);
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
    axis equal
    SO = streamorder(S1, 'plot');
    title('Stream order (Strahler)');
    
    subplot(2,3,3)
    axis normal
    plotdz(S1,cDEM);
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

    print('-noui',[output_location '/catchment_',num2str(c_ID)], '-dpdf')
end