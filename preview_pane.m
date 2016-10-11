function varargout = preview_pane(varargin)
% PREVIEW_PANE MATLAB code for preview_pane.fig
%      PREVIEW_PANE, by itself, creates a new PREVIEW_PANE or raises the existing
%      singleton*.
%
%      H = PREVIEW_PANE returns the handle to a new PREVIEW_PANE or the handle to
%      the existing singleton*.
%
%      PREVIEW_PANE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREVIEW_PANE.M with the given input arguments.
%
%      PREVIEW_PANE('Property','Value',...) creates a new PREVIEW_PANE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before preview_pane_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to preview_pane_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help preview_pane

% Last Modified by GUIDE v2.5 11-Oct-2016 09:56:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @preview_pane_OpeningFcn, ...
                   'gui_OutputFcn',  @preview_pane_OutputFcn, ...
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


% --- Executes just before preview_pane is made visible.
function preview_pane_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to preview_pane (see VARARGIN)

% Choose default command line output for preview_pane
handles.output = hObject;

if isempty(varargin) < 1
    preview_pane_Update(handles, varargin{1}, varargin{2})
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes preview_pane wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function preview_pane_Update(handles, S, DEM)
    axes(handles.profile_preview);
    cla;
    plotdz(S,DEM);
    title('Stream profile elevation');    

% --- Outputs from this function are returned to the command line.
function varargout = preview_pane_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
