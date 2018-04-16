function stream_profiler(poly, DEM, stream_objects, identifier, output_location, ...
    knickpoints, proj_data, export_options)
    
    disp(export_options);
    k = sum(export_options);
    kn = 1:1:(k+1);
    ix = 1;
    % Export options
    % export_options(1) = knickpoint text
    % export_options(2) = Ksn data
    % export_options(3) = Ksn shapefile
    % export_options(4) = Plots
    
    % SETTINGS

    stream_pixel_threshold = 300; % pixels

    n_slope_area_bins = 100;

    aggregrate_ksn_length = 1000; % metres (must be greater than S.cellsize*3)
        
    % Output matrices

    if isnumeric(identifier)
       identifier = num2str(identifier);
    elseif iscell(identifier)
       identifier = lower(identifier{1});
    else
       identifier = lower(identifier);
    end
    
    [r,c] = coord2sub(DEM,poly.X,poly.Y);

    %Remove NaNs
    n = find(isnan(r));
    r(n) = [];
    c(n) = [];
    
    h = waitbar(0);
    % Export knickpoints to text file
    if export_options(1)
        
        waitbar((1/k)*kn(ix), h, 'Saving knickpoint data');
        ix = ix+1;
        
        fname = [output_location ,filesep, identifier,'_knickpoints.txt'];
        
        x = zeros(length(stream_objects)-1,1);
        y = zeros(length(stream_objects)-1,1);
        
        for p=2:length(stream_objects)
            n = p-1;
            if p == length(stream_objects)
                x(n) = stream_objects(p).x(1);
                y(n) = stream_objects(p).y(1);                
            else
                x(n) = stream_objects(p).x(end);
                y(n) = stream_objects(p).y(end);
            end
        end
        
        z = knickpoints(:,6);
        writetable(table(x,y,z),fname);
    end

    FD = FLOWobj(DEM, 'preprocess','carve');
    cDEM = imposemin(FD,DEM,0.0001);

    % Flow Accumulation
    A = flowacc(FD);

    X = 42.0;                  %# A3 paper size
    Y = 29.7;                  %# A3 paper size
    xMargin = 0;               %# left/right margins from page borders
    yMargin = 2;               %# bottom/top margins from page borders
    xSize = X - 2*xMargin;     %# figure size on paper (width & height)
    ySize = Y - 2*yMargin;     %# figure size on paper (width & height)

    % Gradients
    G   = gradient8(cDEM);
    
    if export_options(1)
        ixx = 2;
    else
        ixx = 1;
    end
        
    for p=1:length(stream_objects)
        ix = ixx;
        % Upstream area
        S = stream_objects(p);
        a = A.Z(S.IXgrid).*(A.cellsize).^2;

        % Binned slope area calc
        STATS = slopearea_ksn(S,cDEM,A, 'areabins', aggregrate_ksn_length, 'plot', false);

        % Localised KSN
        KSN = G./(A.*(A.cellsize^2)).^-.45;
        ksn = demprofile(KSN,numel(S.x),S.x,S.y);

        MS = STREAMobj2mapstruct(S,'seglength',aggregrate_ksn_length,'attributes',...
        {'ksn' KSN @mean 'uparea' (A.*(A.cellsize^2)) @mean 'gradient' G @mean});

        shapewrite(MS, [output_location ,filesep, identifier,'_',num2str(p),'_ksn.shp']);

        if export_options(3)
            waitbar((1/k)*kn(ix), h, 'Writing projection data');
            ix = ix+1;
            % Write projection file
            fid = fopen([output_location ,filesep, identifier,'_',num2str(p),'_ksn.prj'],'w');
            fprintf(fid,proj_data);
            fclose(fid);
        end

        if export_options(4)
            
            waitbar((1/k)*kn(ix), h, 'Saving plots');
            try

                kn = kn+1;

                f1 = figure('Menubar','none');
                set(f1,'visible','off');
                set(f1, 'PaperSize',[X X]);
                set(f1, 'PaperPosition',[0 xMargin xSize xSize])
                set(f1, 'PaperUnits','centimeters');

                symbolspec = makesymbolspec('line',...
                    {'ksn' [min([MS.ksn]) max([MS.ksn])] 'color' jet(6)});
                colorbar;
                imageschs(cDEM,cDEM,'colormap',gray,'colorbar',false);
                mapshow(MS,'SymbolSpec',symbolspec);
                caxis([min([MS.ksn]) max([MS.ksn])]);
                contourcbar;
                print(f1,[output_location ,filesep, identifier,'_',num2str(p),'_ksn_plot'], '-dpdf');

                f2 = figure('Menubar','none');
                set(f2,'visible','off');
                set(f2, 'PaperSize',[X Y]);
                set(f2, 'PaperPosition',[0 yMargin xSize ySize])
                set(f2, 'PaperUnits','centimeters');

                sb1 = subplot(2,2,1);
                max_val = max(cDEM.Z(:));
                vdata = cDEM;
                vdata.Z(isnan(vdata.Z)) = max_val + max_val/10;
                imagesc(vdata);
                colormap bone;
                colorbar
                hold on;
                plot(S);
                title(['Catchment ', identifier]);

                subplot(2,2,2);
                SA = slopearea(S,cDEM,A);
                sa_values = {['\bf \theta', '\rm ',  num2str(SA.theta)], ...
                    ['\bf ks ', '\rm ',  num2str(SA.ks)]
                };
                DataX = interp1( [0 1], xlim(), 0.01 );
                DataY = interp1( [0 1], ylim(), 0.01 );

                text(DataX,DataY,sa_values,'EdgeColor', 'black', 'FontSize', 14);

                title('Slope v Area');

                subplot(2,2,3);
                axis equal tight
                plot(S, 'k-', 'LineWidth', 2);
                title('River plan');

                subplot(2,2,4)
                axis normal
                plotdz(S,cDEM);
                title('Stream profile elevation');


                print(f2,[output_location, filesep, identifier,'_',num2str(p), '_plots'], '-dpdf');
            catch exception
               waitfor(msgbox('PDF creation failed. Try increasing the Java Heap Size setting in the MATLAB preferences'));
            end
        end
        
        
        local_slope = gradient(S, cDEM);
        outlet_distance = distance(S,'from_outlet');
        x = S.x;
        y = S.y;
        upstream_area = a;
        elevation = cDEM.Z(S.IXgrid);
        
        if export_options(2)
            waitbar((1/k)*kn(ix), h, 'Saving Ksn data');
            results = table(outlet_distance, x, y, elevation, local_slope, upstream_area, ksn);
            writetable(results,[output_location, filesep, identifier,'_', num2str(p), '.csv']);
        end
    end
    close(h);
end
  