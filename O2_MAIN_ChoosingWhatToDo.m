%% Main figure to choose what want to do from the list below
   % 1) Run O2 measurement
   % 2) Run O2 sensor calibration
   % 3) Crop O2 measurement data
   % 4) Plot O2 data
   % 5) Define dynamical parameters (rise time etc) from the measurement
%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear, close all
% mfilename('fullpath')
% P = mfilename('fullpath')
% [PATHSTR,NAME,EXT] = fileparts(FILE)
%%% Setting figure
WhatToDo=0;
ChoosingFig = figure('Name',['O2 Settings']); % [left bottom width height].
scrsz = get(groot,'ScreenSize'); % [0.25 0.4 0.5 0.6]
% set(ChoosingFig, 'units','normalized','outerposition',[0 0 1 1]);
set(ChoosingFig, 'units','normalized','outerposition',[0.25 0.2 0.6 0.8]);
guidata(ChoosingFig,struct('WhatToDo',0));
bs = [0.6 0.15]; % button size
% Run
kk=1;
button_meas = uicontrol('Parent', ChoosingFig,'Style',...
   'PushButton','String', 'Run O2 measurement',...
   'fontsize',30,'ForegroundColor','k','Fontweight','bold',...
   'Callback','WhatToDo = 1; close all');
set(button_meas,'units','normalized',...
   'position',[0.1 1-bs(2)*kk-(kk-1)*.05 bs]);
% Calib
kk=kk+1;
button_calib = uicontrol('Parent', ChoosingFig,'Style',...
   'PushButton','String', 'Run Calibration',...
   'fontsize',30,'ForegroundColor','k','Fontweight','bold',...
   'Callback','WhatToDo = 2; close all');
set(button_calib,'units','normalized',...
   'position',[0.1 1-bs(2)*kk-(kk-1)*.05 bs])
% Cropping
kk=kk+1;
button_crop = uicontrol('Parent', ChoosingFig,'Style',...
   'PushButton','String', 'Cropping Measurement',...
   'fontsize',30,'ForegroundColor','k','Fontweight','bold',...
   'Callback','WhatToDo = 3; close all');
set(button_crop,'units','normalized',...
   'position',[0.1 1-bs(2)*kk-(kk-1)*.05 bs])
% Plotting
kk=kk+1;
button_plot = uicontrol('Parent', ChoosingFig,'Style',...
   'PushButton','String', 'Plotting Measurement',...
   'fontsize',30,'ForegroundColor','k','Fontweight','bold',...
   'Callback','WhatToDo = 4; close all');
set(button_plot,'units','normalized',...
   'position',[0.1 1-bs(2)*kk-(kk-1)*.05 bs])
% Calculating dynamical parameters
kk=kk+1;
button_dyn_param = uicontrol('Parent', ChoosingFig,'Style',...
   'PushButton','String', 'Finding Rise time etc.',...
   'fontsize',30,'ForegroundColor','k','Fontweight','bold',...
   'Callback','WhatToDo = 5; close all');
set(button_dyn_param,'units','normalized',...
   'position',[0.1 1-bs(2)*kk-(kk-1)*.05 bs])

uiwait(gcf) % wait for button press
BackToMainFigure = 1;
switch WhatToDo
   case 0 % no button pressed
      disp('No button pressed'), close all
   case 1 % run measurement
      cd O2_RunO2Measurement\
      O2RunMeas_MAIN_ver_2
   case 2 % calibration from the measurement file
      cd O2_SensorCalibration\
      O2_SensorCalibration
   case 3 % cropping
      cd O2_CroppingMeasData\
      O2Cropping_MAIN
   case 4 % Plotting Measurement
      cd O2_PlottingMeasData\
      O2Plotting_MAIN
   case 5 % Finding Rise times etc
      cd O2_DynamicalParameters\               
      O2DynamicalParameters_MAIN
end

