% O2RunMeas_Settings.m
clear, close all
FigsToPlot=[];
if ~(exist('default_Calibration_files','var'))
   default_Calibration_files = {'0.185','53','18'}; 
elseif ~(iscell(default_Calibration_files) || length(default_Calibration_files) == 3)
   default_Calibration_files = {'0.185','53','18'}; 
end
Ksv=str2double(default_Calibration_files{1}); 
phi0=str2double(default_Calibration_files{2});
caldevi=str2double(default_Calibration_files{3});
Testing_Script = [0]; 
%%% Setting figure
SettingsFig = figure('Name',['Settings']); % [left bottom width height].
scrsz = get(groot,'ScreenSize');
set(SettingsFig, 'outerposition',[800/3 500  800 500]);
%%%
% Plotting buttons
dimPlottingTitle = [0.05 0.85 0.45 0.15];
FigsToPlot_Names = {'Plotting Phase', 'Plotting Amp', 'Plotting O2%'};
annotation('textbox',dimPlottingTitle,'String','Check to plot',...
   'Fontsize',20,'Fontweight','bold','interpreter','none',...
   'Linestyle','none','FitBoxToText','on');
Colours={'r',[0 0.5 0],'b'};
for kk=1:3
   if kk < 3
      H4settings_FigsToPlot(kk) = uicontrol('Style','checkbox','String',FigsToPlot_Names(kk), ...
         'Value',0,'Callback',{@checkBoxCallback,kk});
   else % O2 chosen as a default
      H4settings_FigsToPlot(kk) = uicontrol('Style','checkbox','String',FigsToPlot_Names(kk), ...
         'Value',1,'Callback',{@checkBoxCallback,kk});
   end
   set(H4settings_FigsToPlot(kk),'units','normalized','Outerposition', [0.05 0.9-kk/10 0.2 0.1]) 
   set(H4settings_FigsToPlot(kk),'fontsize',14,'ForegroundColor',Colours{kk},'Fontweight','bold')
end

% Calibration buttons values
dimCalibTitle = [0.4 0.85 0.45 0.15];
annotation('textbox',dimCalibTitle,'String','Calibration',...
   'Fontsize',20,'Fontweight','bold','interpreter','none',...
   'Linestyle','none','FitBoxToText','on');
dimCalib = [.4 .8 .08 .08];
H3settings_calibValues_Ksv_button = uicontrol('Style', 'edit','String',...
   num2str(Ksv), 'fontsize',14,'Fontweight','bold',...
   'units','normalized','Outerposition', dimCalib);
dim2 = dimCalib; dim2(2) = dim2(2)-0.1;
H3settings_calibValues_phi0_button = uicontrol('Style', 'edit','String',...
   num2str(phi0), 'fontsize',14,'Fontweight','bold',...
   'units','normalized','Outerposition', dim2);
dim3 = dimCalib; dim3(2) = dim3(2)-0.1*2;
H3settings_calibValues_caldevi_button = uicontrol('Style', 'edit','String',...
   num2str(caldevi), 'fontsize',14,'Fontweight','bold',...
   'units','normalized','Outerposition', dim3);
dimcalibText = [0.4 0.8 0.08 0.08];
strCalibText = {'Ksv','phi0','caldevi'};
for kk = 1:3
   annotation('textbox',[0.48 0.9-kk/10 0.08 0.08],'String',strCalibText{kk},...
      'Fontsize',14,'Fontweight','bold','interpreter','none',...
      'Linestyle','none','FitBoxToText','on');
end

% Toggle button: Measurement or testing script
H1settings_ = uicontrol('Style','togglebutton','Callback',@togglebutton1_Callback,...
   'Value',0,'String','Measurement');
set(H1settings_,'fontsize',20,'ForegroundColor','b','Fontweight','bold')
set(H1settings_,'units','normalized','Outerposition', [0.05 0.3 0.3 0.15]) 
dimMeasTitle = [0.05 0.15 0.4 0.15];
annotation('textbox',dimMeasTitle,'String',...
   'Click above to change between measurement and testing script',...
   'Fontsize',12,'interpreter','none',...
   'Linestyle','none');%,'FitBoxToText','on');

% Pause time button
dimPauseTitle = [0.4 0.45 0.45 0.15];
annotation('textbox',dimPauseTitle,'String','Pause time',...
   'Fontsize',20,'Fontweight','bold','interpreter','none',...
   'Linestyle','none','FitBoxToText','on');
dimPause = [0.4 0.42 .08 .08];
pause_time_button = uicontrol('Style', 'edit','String',...
   1, 'fontsize',14,'Fontweight','bold',...
   'units','normalized','Outerposition', dimPause);
dimPauseText = ['sec'];
annotation('textbox',[0.48 0.42 0.08 0.08],'String',dimPauseText ,...
   'Fontsize',14,'Fontweight','bold','interpreter','none',...
   'Linestyle','none','FitBoxToText','on');


% Continuing / Closing button
Hsettings_close = uicontrol('Style', 'PushButton','String', 'Continue', 'Callback',...
   'uiresume(gcbf)','fontsize',46,'ForegroundColor','r','Fontweight','bold');
set(Hsettings_close,'units','normalized','Outerposition', [0.4 0.05 0.35 0.25]) 

%% Waiting for clicking close button --> taking values + closing figure
disp(['Choose proper setting',10,'%%%%%%%%%%%%%%%%%%%'])
uiwait(gcf)
disp(['Close button pressed. Chosen settings are: ',10,'%%%%%%%%%%%%%%%%%%%'])
Testing_Script = get(H1settings_,'Value');
if exist('Testing_Script','var') && Testing_Script == 1  % for testing purposes
   disp('Choosing testing script')
else
   disp('Choosing measurement')
end
for kk  = 1:3
   if get(H4settings_FigsToPlot(kk),'Value') == 1
      FigsToPlot(end+1) = kk;
   end
end
if isempty(FigsToPlot)
   disp('No plotting')
else
   disp(['Plotting following:',10])
   for ll = 1:length(FigsToPlot)
      if FigsToPlot(ll) == 1
         disp(['Phase'])
      elseif FigsToPlot(ll) == 2
         disp(['Amp'])
      else
         disp(['O2%'])
      end
   end
end
Ksv = str2num(get(H3settings_calibValues_Ksv_button,'String'));
if isempty(Ksv)
   set(Ksv,'string','0');
   warndlg('Ksv must be numerical');
end
phi0 = str2num(get(H3settings_calibValues_phi0_button,'String'));
if isempty(phi0)
   set(phi0,'string','0');
   warndlg('phi0 must be numerical');
end
caldevi = str2num(get(H3settings_calibValues_caldevi_button,'String'));
if isempty(caldevi)
   set(caldevi,'string','0');
   warndlg('caldevi must be numerical');
end
calib = ['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
   ', caldevi: ',num2str(caldevi)]; % disp(calib)
disp('Calibration values are:')
disp(calib)

pause_time = str2num(get(pause_time_button,'String'));
disp(['Pause time: ',num2str(pause_time),' sec'])
disp('Closing Settings figure')
close(SettingsFig);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% fucntions
function checkBoxCallback(hObject,eventData,checkBoxId)
   value = get(hObject,'Value');
   if value == 1
      switch checkBoxId
         case 1
            fprintf('Choosing to plot phase.\n');
         case 2
            fprintf('Choosing to plot amp.\n');
         otherwise
            fprintf('Choosing to plot O2%%.\n');
      end
   end
   if value == 0
      switch checkBoxId
         case 1
            fprintf('Not plotting phase.\n');
         case 2
            fprintf('Not plotting amp.\n');
         otherwise
            fprintf('Not plotting O2%%.\n');
      end
   end
end

function togglebutton1_Callback(hObject,~)% eventdata)% ,handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1
button_state = get(hObject,'Value');
   if button_state == get(hObject,'Max')
      disp('Testing script');
      hObject.String = 'Testing script';
      hObject.ForegroundColor = 'k';
      hObject.FontSize = 14;
      hObject.FontWeight='normal';
   elseif button_state == get(hObject,'Min')
      disp('Measurement');
      hObject.String = 'Measurement';
      hObject.ForegroundColor = 'b';
      hObject.FontSize = 20;
      hObject.FontWeight='bold';
   end
end