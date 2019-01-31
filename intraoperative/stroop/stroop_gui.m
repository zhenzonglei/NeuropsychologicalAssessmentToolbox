function varargout = stroop_gui(varargin)
% STROOP_GUI MATLAB code for stroop_gui.fig
%      STROOP_GUI, by itself, creates a new STROOP_GUI or raises the existing
%      singleton*.
%
%      H = STROOP_GUI returns the handle to a new STROOP_GUI or the handle to
%      the existing singleton*.
%
%      STROOP_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STROOP_GUI.M with the given input arguments.
%
%      STROOP_GUI('Property','Value',...) creates a new STROOP_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stroop_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stroop_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to Run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stroop_gui

% Last Modified by GUIDE v2.5 30-Jan-2019 15:02:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stroop_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @stroop_gui_OutputFcn, ...
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


% --- Executes just before stroop_gui is made visible.
function stroop_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stroop_gui (see VARARGIN)

% Choose default command line output for stroop_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes stroop_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = stroop_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function PatientID_Callback(hObject, eventdata, handles)
% hObject    handle to PatientID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PatientID as text
%        str2double(get(hObject,'String')) returns contents of PatientID as a double


% --- Executes during object creation, after setting all properties.
function PatientID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PatientID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% init paient ID
set(hObject,'string','Alien');


function SiteID_Callback(hObject, eventdata, handles)
% hObject    handle to SiteID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SiteID as text
%        str2double(get(hObject,'String')) returns contents of SiteID as a double


% --- Executes during object creation, after setting all properties.
function SiteID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SiteID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string','A1');


% --- Executes on selection change in Task.
function Task_Callback(hObject, eventdata, handles)
% hObject    handle to Task (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Task contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Task


% --- Executes during object creation, after setting all properties.
function Task_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Task (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in stimtype.
function stimtype_Callback(hObject, eventdata, handles)
% hObject    handle to stimtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stimtype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stimtype


% --- Executes during object creation, after setting all properties.
function stimtype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stimtype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function StimDuration_Callback(hObject, eventdata, handles)
% hObject    handle to StimDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StimDuration as text
%        str2double(get(hObject,'String')) returns contents of StimDuration as a double


% --- Executes during object creation, after setting all properties.
function StimDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StimDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string','1');

function SOA_Callback(hObject, eventdata, handles)
% hObject    handle to SOA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SOA as text
%        str2double(get(hObject,'String')) returns contents of SOA as a double


% --- Executes during object creation, after setting all properties.
function SOA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SOA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'string','2');


function TrialNum_Callback(hObject, eventdata, handles)
% hObject    handle to TrialNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TrialNum as text
%        str2double(get(hObject,'String')) returns contents of TrialNum as a double


% --- Executes during object creation, after setting all properties.
function TrialNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TrialNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'string','10');


% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

run_stroop(handles)




