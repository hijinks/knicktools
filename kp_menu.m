function varargout = kp_menu(varargin)
% KP_MENU MATLAB code for kp_menu.fig
%      KP_MENU, by itself, creates a new KP_MENU or raises the existing
%      singleton*.
%
%      H = KP_MENU returns the handle to a new KP_MENU or the handle to
%      the existing singleton*.
%
%      KP_MENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KP_MENU.M with the given input arguments.
%
%      KP_MENU('Property','Value',...) creates a new KP_MENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kp_menu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kp_menu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kp_menu

% Last Modified by GUIDE v2.5 27-Oct-2016 14:42:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kp_menu_OpeningFcn, ...
                   'gui_OutputFcn',  @kp_menu_OutputFcn, ...
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


% --- Executes just before kp_menu is made visible.
function kp_menu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to kp_menu (see VARARGIN)

% Choose default command line output for kp_menu
handles.output = hObject;

handles.dem = varargin{1};
handles.poly = varargin{2};
handles.identifier = varargin{3};
handles.projection = varargin{4};
handles.knickpoints = [];

set(handles.name_box, 'String', handles.identifier);
FD = FLOWobj(handles.dem, 'preprocess','carve');

% Flow Accumulation
A = flowacc(FD);

% Streams
S1 = STREAMobj(FD,A>500);

S1 = klargestconncomps(S1);

axes(handles.catchment_axes);

plot(S1);
hold on;

T = trunk(S1);
plot(T, 'k-', 'LineWidth', 2);

axes(handles.slope_axes);
h = plotdz(T, handles.dem);

elevation = get(h,'YData');
dist = get(h,'XData');

handles.FD = FD;
handles.A = A;
handles.S1 = S1;
handles.T = T;
handles.elevation = elevation;
handles.distance = dist;
handles.cDEM = handles.dem;
handles.ksn_shapefile = get(handles.ksn_shapefile_btn,'Value');
handles.plots_btn = get(handles.plots_btn,'Value');
handles.location_choice = get(handles.kp_location_choice,'Value');
handles.ksn_choice = get(handles.ksn_choice_btn,'Value');


set(varargin{5},'Pointer','arrow');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes kp_menu wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function process_knickpoints(handles, output_location)
    s = size(handles.knickpoints);
    stream_objs = {};
    
    % Sort knickpoints by distance from outlet
    knickpoints_sorted = sortrows(handles.knickpoints,6);
    
    for k = 1:s(1)
       kd = knickpoints_sorted(k, :);
       
       if s(1) == 1

            S1 = modify(handles.T,'distance', [0, kd(5)]);
            S2 = modify(handles.T,'distance', [kd(5), max(handles.distance)]);
            stream_objs = [stream_objs; S1; S2];      
       else
           if k == 1 
                % Starting knickpoint
                S = modify(handles.T,'distance', [0, kd(5)]);
                stream_objs = [stream_objs; S];

           elseif k == max(s(1))
                % Last knickpoint
                kd2 = knickpoints_sorted(k-1, :);
                % From previous knickpoint to current knickpoint
                S1 = modify(handles.T,'distance', [kd2(5), kd(5)]);
                % From current knickpoint
                S2 = modify(handles.T,'distance', [kd(5), max(handles.distance)]);
                stream_objs = [stream_objs; S1; S2];
           else
                % Middle knickpoints
                kd2 = knickpoints_sorted(k-1, :);
                S = modify(handles.T,'distance', [kd2(5), kd(5)]);
                stream_objs = [stream_objs; S];
           end
       end
    end
    identifier = get(handles.name_box,'String');
    % export_options(1) = knickpoint text
    % export_options(2) = Ksn data
    % export_options(3) = Ksn shapefile
    % export_options(4) = Plots
    export_options = [handles.location_choice, handles.ksn_choice,...
        handles.ksn_shapefile, handles.plots_btn]; 
    stream_profiler(handles.poly, handles.dem, stream_objs, ...
        identifier, output_location, handles.knickpoints, ...
        handles.projection, export_options);
 

% --- Outputs from this function are returned to the command line.
function varargout = kp_menu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in save_btn.
function save_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.knickpoints) < 1
    output_location = uigetdir;
    process_knickpoints(handles, output_location);
else
    msgbox('Please select some knickpoints');
end

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in select_knickpoints.
function select_knickpoints_Callback(hObject, eventdata, handles)
% hObject    handle to select_knickpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.knickpoints = [];
cla(handles.slope_axes,'reset')
axes(handles.slope_axes);
h = plotdz(handles.T, handles.dem);

[x,y]= getpts;

%Fires when return key is pressed

cla(handles.catchment_axes,'reset');

axes(handles.catchment_axes);

plot(handles.S1);
hold on;

plot(handles.T, 'k-', 'LineWidth', 2);

kp_data = [];

for k=1:length(x)
	x1 = x(k);
	y1 = y(k);

    xdiff = abs(handles.distance-x1);
    ydiff = abs(handles.elevation'-y1);
    [~, ax_I] = min(xdiff'+ydiff); % slope axes that's closest

    axes(handles.slope_axes);
    hold on;
    
    plot(handles.distance(ax_I), handles.elevation(ax_I), 'rd');
    
    % Now we need to find the real closest node in the stream object
    
    min_diff = abs(handles.T.distance-handles.distance(ax_I));
    Ix = find(abs(min_diff)==abs(min(min_diff)));
    
    coordX = handles.T.x(Ix);
    coordY = handles.T.y(Ix);
    axes(handles.catchment_axes);
    
    % knickpoint columns
    % x coordinate, y coodinate, length - node,  node,   distance,   elevation
    % kd(1),        kd(2),       kd(3),          kd(4),  kd(5),      kd(6)
    kp_data = [kp_data; [coordX, coordY, 0, Ix, handles.distance(ax_I), handles.elevation(ax_I)]];
    
    hold on;
    
    plot(coordX, coordY, 'rd');
end

handles.knickpoints = kp_data;
guidata(handles.output, handles);

% --------------------------------------------------------------------

function name_box_Callback(hObject, eventdata, handles)
% hObject    handle to name_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of name_box as text
%        str2double(get(hObject,'String')) returns contents of name_box as a double


% --- Executes during object creation, after setting all properties.
function name_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function notes_box_Callback(hObject, eventdata, handles)
% hObject    handle to notes_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notes_box as text
%        str2double(get(hObject,'String')) returns contents of notes_box as a double


% --- Executes during object creation, after setting all properties.
function notes_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notes_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ksn_choice_btn_Callback(hObject, eventdata, handles)
% hObject    handle to plots_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plots_btn
handles.ksn_choice = get(hObject,'Value');
guidata(handles.output, handles);

function kp_location_choice_Callback(hObject, eventdata, handles)
% hObject    handle to plots_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plots_btn
handles.location_choice = get(hObject,'Value');
guidata(handles.output, handles);

function ksn_shapefile_btn_Callback(hObject, eventdata, handles)
% hObject    handle to plots_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plots_btn
handles.ksn_shapefile = get(hObject,'Value');
guidata(handles.output, handles);

function plots_btn_Callback(hObject, eventdata, handles)
% hObject    handle to plots_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plots_btn
handles.plots_btn = get(hObject,'Value');
guidata(handles.output, handles);
