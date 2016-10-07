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

% Last Modified by GUIDE v2.5 05-Oct-2016 11:22:53

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
handles.flow_acc = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes knicktools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = knicktools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function knicktools_ProcessDEM(handles)
    handles.dem_obj = GRIDobj(handles.dem);
    guidata(handles.output, handles);
    knicktools_CatchmentOverviewUpdate(handles);

    
function knicktools_CatchmentOverviewUpdate(handles)
	
    axes(handles.catchment_overview);
    
    if isempty(handles.dem) < 1
        h = imagesc(handles.dem_obj);
    end
    
    if isempty(handles.catchments_shapefile) < 1
        geoshow(handles.catchments_shapefile,'FaceColor',[0.5 1.0 0.5])
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
guidata(handles.output, handles);
knicktools_CatchmentOverviewUpdate(handles);

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


% --- Executes on selection change in catchment_id_chooser.
function catchment_id_chooser_Callback(hObject, eventdata, handles)
% hObject    handle to catchment_id_chooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns catchment_id_chooser contents as cell array
%        contents{get(hObject,'Value')} returns selected item from catchment_id_chooser


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
