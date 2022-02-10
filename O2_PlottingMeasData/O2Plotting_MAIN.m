% O2Plotting_MAIN
% Plot different O2 datas, cropped/full, and change calibration if needed
%% Main figure to choose what want to plot from the list below
   % 1) Plotting (multiple) measurement data for a comparison:
      % O2Plotting_MeasurementData.m
   % 2) Plotting Phase, Amp, and O2% from ONE measurement to subplot figure
      % O2Plotting_PhaseAmplitudeO2percent.m
   % 3) Plotting data with different calibration values: 
      % O2Plotting_MeasurementWithDifferentCalibrationValues.m
%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
iseBack = evalin( 'base', 'exist(''BackToMainFigure'',''var'') == 1' );
if iseBack
   clear, BackToMainFigure = 1;
else
   clear
end
close all
%%% Setting figure 
WhatToDo=0;
ChoosingFig = figure('Name',['O2 Plot Settings']); % [left bottom width height].
scrsz = get(groot,'ScreenSize'); % [0.25 0.4 0.5 0.6]
set(ChoosingFig, 'units','normalized','outerposition',[0.25 0.2 0.6 0.6]);
guidata(ChoosingFig,struct('WhatToDo',0));
bs = [0.9 0.15]; % button size
% O2Plotting_MeasurementData
kk=1;
button_meas = uicontrol('Parent', ChoosingFig,'Style',...
   'PushButton','String', 'Plotting (multiple) measurement data for a comparison',...
   'fontsize',14,'ForegroundColor','k','Fontweight','bold',...
   'Callback','WhatToDo = 1; close all');
set(button_meas,'units','normalized',...
   'position',[0.1/2 1-bs(2)*kk-(kk-1)*.05 bs]);
%  O2Plotting_PhaseAmplitudeO2percent
kk=kk+1;
button_calib = uicontrol('Parent', ChoosingFig,'Style',...
   'PushButton','String', 'Plotting Phase, Amp, and O2%',...
   'fontsize',14,'ForegroundColor','k','Fontweight','bold',...
   'Callback','WhatToDo = 2; close all');
set(button_calib,'units','normalized',...
   'position',[0.1/2 1-bs(2)*kk-(kk-1)*.05 bs])
% Plotting data with different calibration values
kk=kk+1;
button_crop = uicontrol('Parent', ChoosingFig,'Style',...
   'PushButton','String', 'Plot and compare O2% with different calibration values',...
   'fontsize',14,'ForegroundColor','k','Fontweight','bold',...
   'Callback','WhatToDo = 3; close all');
set(button_crop,'units','normalized',...
   'position',[0.1/2 1-bs(2)*kk-(kk-1)*.05 bs])

uiwait(gcf)
switch WhatToDo
   case 0 % no button pressed
      disp('No button pressed'), close all
   case 1 % plot measurement data
      O2Plotting_MeasurementData
   case 2 % plot phase, amp and O2% in a subplot figure
      O2Plotting_PhaseAmplitudeO2percent
   case 3 % plot measurement data (one) with different calibration values
      O2Plotting_MeasurementWithDifferentCalibrationValues
end
% % If ran from the main figure --> returning
% iseBack = evalin( 'base', 'exist(''BackToMainFigure'',''var'') == 1' );
% if iseBack
%    cd .. 
%    O2_MAIN_ChoosingWhatToDo
% end
