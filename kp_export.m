function varargout = kp_export(varargin)
% KP_EXPORT MATLAB code for kp_export.fig
%      KP_EXPORT, by itself, creates a new KP_EXPORT or raises the existing
%      singleton*.
%
%      H = KP_EXPORT returns the handle to a new KP_EXPORT or the handle to
%      the existing singleton*.
%
%      KP_EXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KP_EXPORT.M with the given input arguments.
%
%      KP_EXPORT('Property','Value',...) creates a new KP_EXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kp_export_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kp_export_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kp_export

% Last Modified by GUIDE v2.5 27-Oct-2016 17:55:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kp_export_OpeningFcn, ...
                   'gui_OutputFcn',  @kp_export_OutputFcn, ...
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


% --- Executes just before kp_export is made visible.
function kp_export_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to kp_export (see VARARGIN)

% Choose default command line output for kp_export
handles.output = hObject;
handles.options = [0, get(handles.data_value,'Value'), ...
    get(handles.shapefile_value,'Value'), get(handles.plots_value,'Value')];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes kp_export wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = kp_export_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% export_options(1) = knickpoint text
% export_options(2) = Ksn data
% export_options(3) = Ksn shapefile
% export_options(4) = Plots
varargout{1} = hObject;
varargout{2} = handles.options;
delete(handles.output);

% --- Executes on button press in set_export_values.
function set_export_values_Callback(hObject, eventdata, handles)
% hObject    handle to set_export_values (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.options = [0, get(handles.data_value,'Value'), ...
    get(handles.shapefile_value,'Value'), get(handles.plots_value,'Value')];
% Update handles structure
guidata(handles.output, handles);
uiresume(handles.figure1);

% --- Executes on button press in data_value.
function data_value_Callback(hObject, eventdata, handles)
% hObject    handle to data_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of data_value


% --- Executes on button press in shapefile_value.
function shapefile_value_Callback(hObject, eventdata, handles)
% hObject    handle to shapefile_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shapefile_value


% --- Executes on button press in plots_value.
function plots_value_Callback(hObject, eventdata, handles)
% hObject    handle to plots_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plots_value
