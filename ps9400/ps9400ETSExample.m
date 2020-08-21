clear
clc
% Open 9400 and PicoSample 4
handle=actxserver('PicoSample4.COMRC');
% Remvoe headers from return values
handle.ExecCommand("Header? Off");
%% Wait for GUI to finish loading
ready='ON';
proceed='ON';
while strcmp(ready,proceed) ~= 1
    ready=handle.ExecCommand("Instr:GuiReady?");
    pause(0.1)
end

%% Set GUI control
handle.ExecCommand("Gui:Control? RemoteLocal");
%% Turn Channel 1+2 On
handle.ExecCommand("Ch1:Display? On");
handle.ExecCommand("Ch2:Display? On");
% Turn Channel 3+4 Off
handle.ExecCommand("Ch3:Display? Off");
handle.ExecCommand("Ch4:Display? Off");
%% Set Aquisition from channel 1+2 only
handle.ExecCommand("Ch1:AcqOnlyEn? On");
handle.ExecCommand("Ch2:AcqOnlyEn? On");
handle.ExecCommand("Ch3:AcqOnlyEn? Off");
handle.ExecCommand("Ch4:AcqOnlyEn? Off");
%% Set channel 1+2 scale to 100 mV/div
handle.ExecCommand("Ch1:Scale? 0.1");
handle.ExecCommand("Ch2:Scale? 0.1");
%% Set scope to Random ET mode
handle.ExecCommand("Instr:TimeBase:SampleModeSet? RandomET");
%% Set timebase scale to 1 ns/div
handle.ExecCommand("Instr:TimeBase:ScaleT? 1e-9");
%% Set number of samples to 2000
handle.ExecCommand("Instr:TimeBase:RecLen? 2000");
%% Set pretrigger to 50%
handle.ExecCommand("TB:TrigPos? 50");
%% Set rising edge trigger on Channel 1 with 0 V level
handle.ExecCommand("Trig:Analog:Source? Ch1");
handle.ExecCommand("Trig:Analog:Ch1:Level? 0");
handle.ExecCommand("Trig:Analog:Style? Edge");
handle.ExecCommand("Trig:Analog:Ch1:Slope? Pos");
handle.ExecCommand("Trig:Mode? Free");
%% Run scope and wait for it to finish
handle.ExecCommand("*RunControl? Single");
pause(2)
%% Make a measurement on the waveform
handle.ExecCommand("Meas:SingleMeas?");
%% Retrive and plot waveform
handle.ExecCommand("Wfm:Source? Ch1");
wfmCh1=str2num(handle.ExecCommand("Wfm:Data?"));
points=str2double(handle.ExecCommand("Wfm:Preamb:Poin?"));
sampleInterval=str2double(handle.ExecCommand("Wfm:Preamb:XInc?"));
timeOffset=str2double(handle.ExecCommand("Wfm:Preamb:XOrg?"));
times=(linspace(0,points,points)*sampleInterval)+timeOffset;
handle.ExecCommand("Wfm:Source? Ch2");
wfmCh2=str2num(handle.ExecCommand("Wfm:Data?"));
xAxisUnit=handle.ExecCommand("Wfm:Preamb:XU?");
yAxisUnit=handle.ExecCommand("Wfm:Preamb:YU?");
xAxisLabel =strcat("Time (",xAxisUnit,")");
yAxisLabel=strcat("Data (",yAxisUnit,")");
figure(1)
plot(times,wfmCh1,'r')
hold on
plot(times,wfmCh2,'b')
xlabel(xAxisLabel)
ylabel(yAxisLabel)
hold off

%%
clear handle
