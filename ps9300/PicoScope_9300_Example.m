%% PicoScope 9300 Series Sampling Oscilloscopes Example Code for communicating with the PicoSample 3 Application using ActiveX. 
%  
% Description:
%     Demonstrates how to call commands using the PicoSample 3 software
%     application and ActiveX. This example shows how to call some basic
%     commands and how we can call a string of commands to get data.
%
% Copyright: © 2014 - 2017 Pico Technology Ltd. See LICENSE file for terms. 

function varargout = PicoScope_9300_Example(varargin)

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @PicoScope_9300_Example_OpeningFcn, ...
                       'gui_OutputFcn',  @PicoScope_9300_Example_OutputFcn, ...
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


% --- Executes just before PicoScope_9300_Example is made visible.
function PicoScope_9300_Example_OpeningFcn(hObject, eventdata, handles, varargin)

    handles.output = hObject;

    % Makes the buttons only useful if PicoSample is open
    set(handles.OnButton,'Enable','on');
    set(handles.SendButton,'Enable','off');
    set(handles.OffButton,'Enable','off');
    set(handles.RunButton,'Enable','off');
    set(handles.StopButton,'Enable','off');
    set(handles.SingleButton,'Enable','off');
    set(handles.GetDataButton,'Enable','off');

    % Need this to hold all variables stored in handles e.g handles.Onbutton or
    % handles.h
    guidata(hObject, handles);

    % UIWAIT makes PicoScope_9300_Example wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PicoScope_9300_Example_OutputFcn(hObject, eventdata, handles) 

    varargout{1} = handles.output;


% --- Executes on button press in OnButton.
function OnButton_Callback(hObject, eventdata, handles)

    % Creates object to hold PicoSample 
    handles.h = actxserver('PicoSample3.COMRC');

    %enables button now that we can use the program
    set(handles.OnButton,'Enable','off');
    set(handles.OffButton,'Enable','on');
    set(handles.SendButton,'Enable','on');
    set(handles.RunButton,'Enable','on');
    set(handles.StopButton,'Enable','on');
    set(handles.SingleButton,'Enable','on');
    set(handles.GetDataButton,'Enable','on');

    guidata(hObject, handles);

% --- Executes on button press in OffButton.
function OffButton_Callback(hObject, eventdata, handles)

    % Disables buttons so cannot click while closing program
    set(handles.OnButton,'Enable','on');
    set(handles.SendButton,'Enable','off');
    set(handles.OffButton,'Enable','off');
    set(handles.RunButton,'Enable','off');
    set(handles.StopButton,'Enable','off');
    set(handles.SingleButton,'Enable','off');
    set(handles.GetDataButton,'Enable','off');

    % By giving object a number it will drop PicoSample
    handles.h= 1;

    guidata(hObject, handles);

    % hObject    handle to OffButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in SendButton.
function SendButton_Callback(hObject, eventdata, handles)

    % To control using activeX we can send commands to PicoSample and it will do
    %reply with relative command check programmers guide
    set(handles.text1,'String', handles.h.ExecCommand(get(handles.Command,'String')));

    guidata(hObject, handles);

function Command_Callback(hObject, eventdata, handles)
    
    % Nothing here as we do not need to check when text has been changed

% --- Executes during object creation, after setting all properties.
function Command_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)

    % This is an example of sending a 'run' command to PicoSample using ActiveX.
    % Do not need guidata(hObject, handles) because not changing stored variable
    handles.h.ExecCommand('*Runcontrol:Run');

% --- Executes on button press in StopButton.
function StopButton_Callback(hObject, eventdata, handles)

    % This is an example of sending a 'stop' command to PicoSample using ActiveX.
    % Do not need guidata(hObject, handles) because not changing stored variable
    handles.h.ExecCommand('*Runcontrol:Stop');


% --- Executes on button press in SingleButton.
function SingleButton_Callback(hObject, eventdata, handles)

    % This is an example of sending a 'single' command to PicoSample using ActiveX.
    % Do not need guidata(hObject, handles) because not changing stored variable
    handles.h.ExecCommand('*Runcontrol:Single');

% --- Executes on button press in GetDataButton, this is an example to
% grab data and then show it as the graph
function GetDataButton_Callback(hObject, eventdata, handles)

    % First turn off header stop word from appearing when we only need numbers
    handles.h.ExecCommand('Header Off');

    % Please note that all value returned when calling a command is a string

    % These are the values they are returned from the command, but returned as a
    % string with comma separated variables
    Y = str2double(strsplit(handles.h.ExecCommand('wfm:Data?'),','));
    assignin('base','values', Y);

    % This gives the initial value of x
    X_start = str2double(handles.h.ExecCommand('Wfm:Preamb:XOrg?'));
    assignin('base','timeStart', X_start);

    % This gives the increment value of x
    X_increment = str2double(handles.h.ExecCommand('Wfm:Preamb:XInc?'));
    assignin('base','timeIncrement', X_increment);

    % This gives the units of the Y axis
    Y_unit=handles.h.ExecCommand('Wfm:Preamb:YU?');
    assignin('base','valuesUnit', Y_unit);

    % This gives the units of the X axis
    X_unit=handles.h.ExecCommand('Wfm:Preamb:XU?');
    assignin('base','timeUnits', X_unit);

    % Creating the variables to plot them
    no_points = size(Y,2);
    X= X_start:X_increment:(X_increment*(no_points-1)+X_start);
    plot(X,Y, '.');
    xlabel(['Time in ' X_unit]);
    ylabel(['Values in ' Y_unit]);
