function varargout = knicktools(varargin)
% KNICKTOOLS MATLAB code for knicktools.fig
%      KNICKTOOLS, by itself, creates a new KNICKTOOLS or raises the existing
%      singleton*.
%
%      H = KNICKTOOLS returns the handle to a new KNICKTOOLS or the handle to
%      the existing singleton*.
%
%      KNICKTOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KNICKTOOLS.M with the given input arguments.
%
%      KNICKTOOLS('Property','Value',...) creates a new KNICKTOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before knicktools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to knicktools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help knicktools

% Last Modified by GUIDE v2.5 10-Oct-2016 16:14:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @knicktools_OpeningFcn, ...
                   'gui_OutputFcn',  @knicktools_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before knicktools is made visible.
function knicktools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to knicktools (see VARARGIN)

% Choose default command line output for knicktools
handles.output = hObject;
handles.catchments_shapefile = [];
handles.dem = [];
handles.dem_obj = [];
handles.dam_handle = [];
handles.flow_acc = [];
handles.current_catchment = [];
handles.text_handles = [];
handles.catchment_handles = [];
handles.catchment_dems = [];
handles.backdrop_raster = [];
handles.backdrop_handle = [];
handles.view_mode = 'dem';

handles.catchment_overview = knicktools_createMapOverview(handles);
disp(handles)
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes knicktools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function overview = knicktools_createMapOverview(handles)
    overview = axesm('MapProjection','utm');
    set(overview, 'Position',[7.8 5.615 152.2 44.692], 'Tag',...
        'catchment_overview', 'Box', 'on', 'BoxStyle', 'full','Parent', ...
        handles.output);

% --- Outputs from this function are returned to the command line.
function varargout = knicktools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function knicktools_PopulateList(handles, attr)
    S = shaperead(handles.catchments_shapefile);
    disp(attr)
    
    shape_attr = fieldnames(S);
    disp(shape_attr)
    id_n = find(strcmpi(shape_attr,attr));
    
    disp(id_n)
    af = shape_attr{id_n};

    attribs_list = {};
    for i = 1:numel(S)
        attribs_list = [attribs_list; num2str(S(i).(af))];
    end
    
    set(handles.catchment_lists, 'String', attribs_list);
    

function knicktools_ProcessDEM(handles)
    handles.dem_obj = GRIDobj(handles.dem);
    handles.view_mode = 'dem';
    guidata(handles.output, handles);
    knicktools_CatchmentOverviewUpdate(handles, 1);
    


function knicktools_ProcessBackdrop(handles, raster_path)

[raster, D] = geotiffread(raster_path);
R = raster(:,:,1);
G = raster(:,:,2);
B = raster(:,:,3);

I = cat(3,R,G,B);
J = imadjust(I,stretchlim(I,[.3; .95]));
handles.backdrop_raster = {J, D};
handles.view_mode = 'backdrop';
guidata(handles.output, handles);
knicktools_CatchmentOverviewUpdate(handles, 1);

function knicktools_ProcessCatchments(handles)
    
    axes(handles.catchment_overview);
    
    S = shaperead(handles.catchments_shapefile);
    
    catchment_handles = {};
    for i = 1:numel(S)
       c = S(i);
       ch = mapshow(c.X,c.Y, 'DisplayType', 'polygon');
       set(ch, 'FaceColor', [0.5 1.0 0.5]);
       set(ch, 'FaceAlpha', .7);
       catchment_handles = [catchment_handles; ch];
    end
    handles.catchment_handles = catchment_handles;
    
    handles.catchment_dems = cell(numel(S), 1);
    
    text_handles = {};
    for i = 1:numel(S)
       c = S(i);
       c1 = c.BoundingBox(1,:);
       c2 = c.BoundingBox(2,:);
       cc = [(c1(1)+c2(1))/2, (c1(2)+c2(2))/2];
       t = text(cc(1),cc(2),num2str(c.ID));
       set(t, 'FontSize', 7);
       text_handles = [text_handles; t];
    end
    
    handles.text_handles = text_handles;

	shape_attr = fieldnames(S);
    id_n = find(strcmpi(shape_attr,'ID'));

    attribs = shape_attr(id_n:end);
    set(handles.catchment_id_chooser, 'String', attribs);
    
    guidata(handles.output, handles);
    
function knicktools_cropDEM(handles, S, idx)

    DEM = handles.dem_obj;
    
    if isempty(handles.dem_obj) < 1
        poly = S(idx);

        polyarea(poly.X, poly.Y)

        [r,c] = coord2sub(DEM,poly.X,poly.Y);

        %Remove NaNs
        n = find(isnan(r));
        r(n) = [];
        c(n) = [];

        % convert points outside catchment poly to NaN
        mask = poly2mask(c,r,DEM.size(1),DEM.size(2));

        DEM.Z(find(mask==0)) = NaN;

        cDEM = crop(DEM, mask);

        handles.catchment_dems{idx} = cDEM;
        
        knicktools_previewPlot(handles, handles.current_catchment);

        guidata(handles.output, handles);
    end
    
    
function knicktools_previewPlot(handles, idx)

    axes(handles.profile_preview);
    
    cDEM = handles.catchment_dems{idx};
    FD = FLOWobj(cDEM);

    % Flow Accumulation
    A = flowacc(FD);

    % Streams
    S1 = STREAMobj(FD,A>300);
    S1 = klargestconncomps(S1);
    T = trunk(S1);
    

    axis normal
    cla;
    plotdz(T,cDEM);
    title('Stream profile elevation');
       
    
function knicktools_CatchmentOverviewTextUpdate(handles, attr)
    axes(handles.catchment_overview);
    
    S = shaperead(handles.catchments_shapefile);
    
     for k = 1:numel(handles.text_handles)
        delete(handles.text_handles(k))
     end
     
     text_handles = {};
     
     for i = 1:numel(S)
        c = S(i);
        c1 = c.BoundingBox(1,:);
        c2 = c.BoundingBox(2,:);
        cc = [(c1(1)+c2(1))/2, (c1(2)+c2(2))/2];
        t = text(cc(1),cc(2),num2str(c.(attr)));
        set(t, 'FontSize', 7);
        text_handles = [text_handles; t];
     end
    
     handles.text_handles = text_handles;
     guidata(handles.output, handles);
    
function knicktools_CatchmentOverviewUpdate(handles, full_refresh)
    axes(handles.catchment_overview);
    cla;
    
    if full_refresh > 0
        if strcmp(handles.view_mode, 'dem') > 0
            if isempty(handles.dem_obj) < 1
                handles.dem_handle = imagesc(handles.dem_obj);
            else
                if isempty(handles.dem_obj) < 1
                    handles.dem_obj = GRIDobj(handles.dem);
                    handles.dem_handle = imagesc(handles.dem_obj);
                end
            end
        else
            if isempty(handles.backdrop_raster) < 1
                handles.backdrop_handle = mapshow(handles.backdrop_raster{1}, handles.backdrop_raster{2});
            end
        end

        if isempty(handles.catchments_shapefile) < 1
            geoshow(handles.catchments_shapefile,'FaceColor',[0.5 1.0 0.5])
        end
    end
    
    guidata(handles.output, handles);

function knicktools_SelectCatchment(handles)
    axes(handles.catchment_overview);
    
    if isempty(handles.current_catchment) < 1
         for k = 1:numel(handles.catchment_handles)
            if k == handles.current_catchment
                set(handles.catchment_handles(k), 'FaceColor', [1 0 0]);
                set(handles.catchment_handles(k), 'FaceAlpha', 1);
            else
               set(handles.catchment_handles(k), 'FaceColor', [0.5 1.0 0.5]);
               set(handles.catchment_handles(k), 'FaceAlpha', .7);
            end
         end
         
        if isempty(handles.dem_obj) < 1
            
            S = shaperead(handles.catchments_shapefile);
  
            if isempty(handles.catchment_dems{handles.current_catchment}) > 0
                knicktools_cropDEM(handles, S, handles.current_catchment);
            else
                knicktools_previewPlot(handles, handles.current_catchment);
            end
            
        end    
    end
    
   
    
% --------------------------------------------------------------------
function config_options_Callback(hObject, eventdata, handles)
% hObject    handle to config_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function load_config_Callback(hObject, eventdata, handles)
% hObject    handle to load_config (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function save_config_Callback(hObject, eventdata, handles)
% hObject    handle to save_config (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in catchment_lists.
function catchment_lists_Callback(hObject, eventdata, handles)
% hObject    handle to catchment_lists (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns catchment_lists contents as cell array
%        contents{get(hObject,'Value')} returns selected item from catchment_lists
    handles.current_catchment = get(hObject,'Value');
    guidata(handles.output, handles);
    knicktools_SelectCatchment(handles);
    
% --- Executes during object creation, after setting all properties.
function catchment_lists_CreateFcn(hObject, eventdata, handles)
% hObject    handle to catchment_lists (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function catchment_path_Callback(hObject, eventdata, handles)
% hObject    handle to catchment_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of catchment_path as text
%        str2double(get(hObject,'String')) returns contents of catchment_path as a double


% --- Executes during object creation, after setting all properties.
function catchment_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to catchment_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_catchments.
function select_catchments_Callback(hObject, eventdata, handles)
% hObject    handle to select_catchments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile('*.shp', 'Select catchment shapefile');
handles.catchments_shapefile = fullfile(pathname, filename);
set(handles.catchment_path,'String',filename)
guidata(handles.output, handles);
knicktools_ProcessCatchments(handles);

function dem_path_Callback(hObject, eventdata, handles)
% hObject    handle to dem_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dem_path as text
%        str2double(get(hObject,'String')) returns contents of dem_path as a double

% --- Executes during object creation, after setting all properties.
function dem_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dem_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_dem.
function select_dem_Callback(hObject, eventdata, handles)
% hObject    handle to select_dem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile('*.tif', 'Select DEM');
handles.dem = fullfile(pathname, filename);
set(handles.dem_path,'String',filename)
guidata(handles.output, handles);
knicktools_ProcessDEM(handles);


function backdrop_path_Callback(hObject, eventdata, handles)
% hObject    handle to backdrop_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of backdrop_path as text
%        str2double(get(hObject,'String')) returns contents of backdrop_path as a double


% --- Executes during object creation, after setting all properties.
function backdrop_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to backdrop_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_backdrop.
function select_backdrop_Callback(hObject, eventdata, handles)
% hObject    handle to select_backdrop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile('*.tif', 'Select raster backdrop');
raster_path = fullfile(pathname, filename);
set(handles.backdrop_path,'String',filename)
knicktools_ProcessBackdrop(handles, raster_path);

% --- Executes on button press in highlight_catchment.
function highlight_catchment_Callback(hObject, eventdata, handles)
% hObject    handle to highlight_catchment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in knickpoint_analysis.
function knickpoint_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to knickpoint_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if isempty(handles.current_catchment) < 1
        kp_menu(handles.catchment_dems{handles.current_catchment});
    end


% --- Executes on selection change in catchment_id_chooser.
function catchment_id_chooser_Callback(hObject, eventdata, handles)
% hObject    handle to catchment_id_chooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns catchment_id_chooser contents as cell array
%        contents{get(hObject,'Value')} returns selected item from catchment_id_chooser
    val = get(hObject, 'Value');
    opts = get(hObject, 'String');
    if strcmp(val, 'Identification Attribute') < 1
        knicktools_PopulateList(handles, opts{val});
        knicktools_CatchmentOverviewTextUpdate(handles, opts{val});
    end

% --- Executes during object creation, after setting all properties.
function catchment_id_chooser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to catchment_id_chooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in processAllCatchments.
function processAllCatchments_Callback(hObject, eventdata, handles)
% hObject    handle to processAllCatchments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in dem_viewchooser.
function dem_viewchooser_Callback(hObject, eventdata, handles)
% hObject    handle to dem_viewchooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in backdrop_viewchooser.
function backdrop_viewchooser_Callback(hObject, eventdata, handles)
% hObject    handle to backdrop_viewchooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in projection_chooser.
function projection_chooser_Callback(hObject, eventdata, handles)
% hObject    handle to projection_chooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.catchment_overview);
axesmui

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
