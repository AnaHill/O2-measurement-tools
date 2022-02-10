%% Reading O2 sensor and plotting & saving (read more info in the end)
% Version 1.4 updates
   % Calibration parameters changed on window
   % Not asking plotting or not 
      % For no plot --> SET to empty 'Insert numbers (1-3) to plot following'
   % When asking saving -> if pressing CANCEL, will not save the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
   % Requires files: 
      % SternVolmerC.m, 
      % RunO2sensor_Subplotting.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notice: assuming, that O2 sensor is in COM port 7 --> if not, you need to
% modify -p7 in dos command (change -p7 to correct port)
   %  y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat')
clear, close all
% Calibration
defaultans = {'0.185','53','18'}; % Defaut calibration values
   % change these if needed to get them directly correct
prompt = {'Ksv:','phi0:','caldevi:'};
dlg_title = 'Set calibration values';
num_lines = [1 50];
answer = inputdlg(prompt,dlg_title,num_lines,defaultans); 
Ksv=str2double(answer{1}); phi0=str2double(answer{2}); caldevi=str2double(answer{3});
disp(['Calibration parameters:'])
disp(['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
', caldevi: ',num2str(caldevi)])     
calib = ['calib. param.: Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)]; 
% pause time
dlg_title = ['Pause Time'];
prompt = {['Insert pause time after each measurement ',10,...
   'If 0 --> no pausing time after measurement ',10,...
   'NOTICE: it takes about 4 sec between each measurement even pause time = 0']};
num_lines = [1 50];
defaultans = {'1'};
answer = inputdlg(prompt,[dlg_title],num_lines,defaultans);    
pause_time = str2double(answer{:}); % sets pause time (in sec) before next measurement

answer_testing = questdlg(['Measurement or testing script (debugging)?'], ...
   'Measurement or Testing','Measurement','Testing script', 'Measurement');
if strcmp(answer_testing ,'Testing script')
   Testing_Script = 1; % set 1 only if testing/debugging script
end
dlg_title = ['Figures '];
prompt = {['Insert numbers (1-3) to plot following: ',10,...
   '1 = Phase, 2 = Amp, 3 = pO2',10,...
   'E.g. Setting 3 plots only pO2, setting 1,2,3 will plot all three',10,...
   'NO PLOTTING --> SET empty (clear all from the row)']};
num_lines = [1 100];
defaultans = {'3'};
answer = inputdlg(prompt,[dlg_title],num_lines,defaultans); 
if ~isnan(str2num(answer{:}))
   FigsToPlot = str2num(answer{:});
   if any(FigsToPlot < 0) || any(FigsToPlot > 3)
      error('No correct figures chosen')
   end
else
   FigsToPlot=[];   
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Creating files (.txt & .mat) where data is saved 
% asking file name (starting time is added to the end) and folder
% If CANCEL pressed -> no saving (mainly used for testing purposes)
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Choosing saving folder.')
data_folder_to_save = [uigetdir(pwd,['Choose a folder where data will be saved',...
   ' %%%%%% Press CANCEL if not want to save (e.g. testing)']),'\'];
if length(data_folder_to_save) <= 2 % canceled
   disp('Cancel pressed -> no saving') % if cancel is pressed
   Dataname = 'DeleteThis';
   data_folder_to_save = [pwd,'\'];
   fname=[strcat(Dataname),'.mat'];
   fnametxt=[fname(1:end-3),'txt'];
   if exist('DeleteThis.txt','file')
      delete DeleteThis.txt
   end
   fileID = fopen([data_folder_to_save,fnametxt], 'a');
   fprintf(fileID,'%s %8s %8s %8s\n','t_', 'phiM_', 'ampM_','pO2M_');
   fclose(fileID);
else
   prompt = ['Give measurement file name, it will be save to: ',10,...
      data_folder_to_save,10,...
      '(date and time will be added automatically to the end of name)'];
   name = 'Measurement file name';numlines=1; defaultanswer={'Data'};
   answerSaving=inputdlg(prompt,name,numlines,defaultanswer);
   Dataname=answerSaving{:};
   fname=[strcat(Dataname,'_',datestr(now,'yyyy_mm_dd__HH_MM_SS')),'.mat'];
   fnametxt=[fname(1:end-3),'txt'];
   fileID = fopen([data_folder_to_save,fnametxt], 'a');
   fprintf(fileID,'%s %8s %8s %8s\n','t_', 'phiM_', 'ampM_','pO2M_');
   fclose(fileID);
   disp(['Measurement file name: ',fname,', saving location: ',data_folder_to_save])
end
%% Create figs
if exist('FigsToPlot','var') && length(FigsToPlot) >= 1 && ~isempty(FigsToPlot)% plotting
   Markers={'o','v','x'}; Colours={'r',[0 0.5 0],'b'};
   FigsToPlot=sort(FigsToPlot);
   fig_size_normalized=[0.3000 0.4267]; % width and height
   h1fig=figure(FigsToPlot(1)); grid on, hold on,
	set(h1fig, 'units','normalized','outerposition',[0 0.5 fig_size_normalized]);   
   if length(FigsToPlot) > 1
      h2fig=figure(FigsToPlot(2)); grid on, hold on,
      set(h2fig, 'units','normalized','outerposition',[0.35 0.5 fig_size_normalized]);
   end
   if length(FigsToPlot)> 2
      h3fig=figure(FigsToPlot(3)); grid on, hold on,
      set(h3fig, 'units','normalized','outerposition',[0.7 0.5 fig_size_normalized]);
   end
   for pp = 1:length(FigsToPlot)
         figure(FigsToPlot(pp))
         switch FigsToPlot(pp)
            case 1               
               ylabel('Phase (deg)');
               li1 = line(0, 0,'Marker','o','Color','r','LineStyle','none');
            case 2
               ylabel('Amplitude ()');
               li2 = line(0, 0,'Marker','v','Color',Colours{2},'LineStyle','none');
            case 3
               ylabel('O_2 (%)');
               li3 = line(0, 0,'Marker','x','Color','b','LineStyle','none');             
         end
         xlabel('Time (s)'), hold all;
   end
end
StopFig = figure('Name',['Here you can plot all values during measurement',...
   ', change calibration values, and stop measurement.']);
set(StopFig, 'units','normalized','outerposition',[0.3 0.03 0.6 0.45]);
H = uicontrol('Style', 'PushButton','String', 'Stop', 'Callback',...
   'delete(gcbf)','fontsize',20,'ForegroundColor','r','Fontweight','bold');
set(H,'units','normalized','Outerposition', [0.1 0.2 0.2 0.15])  
H2subplot = uicontrol('Style', 'PushButton','String', 'Plot measurement', 'Callback',...
   'subplotting=1;','fontsize',14,'Fontweight','bold');
set(H2subplot,'units','normalized','Outerposition', [0.05 0.8 0.3 0.15])
H3calib_button = uicontrol('Style', 'PushButton','String',...
   'Press to change calibration', 'Callback',...
   'change_calibration=1;','fontsize',14,'Fontweight','bold');
set(H3calib_button,'units','normalized','Outerposition', [0.5 0.8 0.45 0.15])
dim = [.6 .7 .08 .08];
H3calibValues_Ksv_button = uicontrol('Style', 'edit','String',...
   num2str(Ksv), 'fontsize',14,'Fontweight','bold',...
   'units','normalized','Outerposition', dim);
dim2 = dim; dim2(2) = dim2(2)-0.1;
H3calibValues_phi0_button = uicontrol('Style', 'edit','String',...
   num2str(phi0), 'fontsize',14,'Fontweight','bold',...
   'units','normalized','Outerposition', dim2);
dim3 = dim; dim3(2) = dim3(2)-0.1*2;
H3calibValues_caldevi_button = uicontrol('Style', 'edit','String',...
   num2str(caldevi), 'fontsize',14,'Fontweight','bold',...
   'units','normalized','Outerposition', dim3);
str = ['Ksv',10,'phi0',10,'caldevi'];
dim_text=dim; dim_text(1) = dim_text(1)-0.1;
dim_text(2) = dim_text(2)+0.03;
annotation('textbox',dim_text,'String',str,...
   'Fontsize',14,'Fontweight','bold','interpreter','none',...
   'Linestyle','none','FitBoxToText','on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Starting measurement / testing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('Testing_Script','var') && Testing_Script == 1  % for testing purposes
   disp('Start testing script')
else
   disp('Start measurement')
end
x=1;
phiM_=[]; ampM_=phiM_; pO2M_=phiM_; t_=phiM_;
if exist('one_meas.mat','file') 
   delete one_meas.mat % 
end
while(ishandle(H)) % Continuing while Stop button is not pressed
      if exist('subplotting','var') && subplotting == 1 
         RunO2sensor_Subplotting
      end
   % Reading data
   if exist('Testing_Script','var') && Testing_Script == 1  % for testing purposes
      phi=rand(30,1); amp=rand(30,1);
      phi = mean(phi(11:end));amp = mean(amp(11:end));
   else 
      if exist('one_meas.mat','file') 
         delete one_meas.mat % this if loop takes ~0.03 sec
      end
      y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat');
      while~(exist('one_meas.mat','file'))
         % do nothing, check if one_meas.mat exists
      end
      load one_meas.mat
      % deleting first 10 samples (device might be slightly warming etc.)
      if length(Measurement) >= 20
         Measurement = Measurement(11:end);   
      end
      phi=mean(angle(Measurement-StopCal)/pi*180);
      amp=mean(abs(Measurement-StopCal));
   end 
   if x<2 % tic in the begin to log time
      tic
      tnow=0;
   else
      tnow=toc;
   end
   t_(1)=tnow;
   if exist('change_calibration','var') && change_calibration == 1
      disp('Changing calibration parameters')
      Ksv = str2num(get(H3calibValues_Ksv_button,'String'));
      if isempty(Ksv)
         set(Ksv,'string','0');
         warndlg('Ksv must be numerical');
      end
      phi0 = str2num(get(H3calibValues_phi0_button,'String'));
      if isempty(phi0)
         set(phi0,'string','0');
         warndlg('phi0 must be numerical');
      end
      caldevi = str2num(get(H3calibValues_caldevi_button,'String'));
      if isempty(caldevi)
         set(caldevi,'string','0');
         warndlg('caldevi must be numerical');
      end
      calib = ['calib. param.: Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
         ', caldevi: ',num2str(caldevi)]; % disp(calib) 
      clear change_calibration
      disp('New calibration values are:')
%       disp('Calibration values read from .txt file, new values are:')
      disp(calib)
   end
   %%%%%%%%%%%%%%%%%%
   % Converting to pO2 [%]
   pO2 = SternVolmerC(Ksv,phi0,-phi,caldevi);
   res = ['Time ',num2str(tnow, '%.1f'), 's -> O2: ',num2str(pO2,'%.2f'),...
       '% (phi: ',num2str(phi,'%.3f'),...
       ', amp: ',num2str(amp,'%.3f'),')'];
   % saving
   phiM_(1)=phi; ampM_(1)=amp; pO2M_(1)=pO2; Dat=[t_, phi, amp, pO2];
   fileID = fopen([data_folder_to_save,fnametxt], 'a');
   fprintf(fileID,'%d %8d %8d %8d\n', Dat);
   fclose(fileID); 
   % plotting
   if exist('FigsToPlot','var') && length(FigsToPlot) >= 1
      disp([num2str(x),')',res, ' (',calib,')'])
      if exist('li1','var')
         if x == 1
            li1.XData = tnow; li1.YData = phi; drawnow;
         else
            li1.XData = [li1.XData tnow]; li1.YData = [li1.YData phi]; drawnow;
         end
      end
      if exist('li2','var')
         if x == 1
            li2.XData = tnow; li2.YData = amp; drawnow;
         else
            li2.XData = [li2.XData tnow]; li2.YData = [li2.YData amp]; drawnow;
         end
      end
      if exist('li3','var')
         if x == 1
            li3.XData = tnow; li3.YData = pO2; drawnow;
         else
            li3.XData = [li3.XData tnow]; li3.YData = [li3.YData pO2]; drawnow;
         end
      end
   else % no plotting
       disp(['No Plotting ',num2str(x),')',res, ' (',calib,')'])
   end
   if exist('pause_time','var') && pause_time > 0 % if pause before next measurement
      x_pause = 0;
      if pause_time < 1
         pause(pause_time)
      else
         while x_pause <= pause_time
            if (ishandle(H))
               pause(1)
               x_pause = x_pause+1;
               if exist('subplotting','var') && subplotting == 1 
                  RunO2sensor_Subplotting
               end
            else
               break
            end
         end
      end
   end
   x=x+1;
end
disp('Stop button pressed. Stopping measurement')  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVING %%%%%%%%%%%%%%% read measurement FROM .txt and save to .mat file
delimiter = '\t';startRow = 2;formatSpec = '%f%f%f%f%[^\n\r]';
fileID = fopen([data_folder_to_save,fnametxt],'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,...
   'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
t_ = dataArray{:, 1}; %time = t_;
phiM_ = dataArray{:, 2}; %phiM = phiM_;
ampM_ = dataArray{:, 3}; %ampM = ampM_;
pO2M_ = dataArray{:, 4}; %pO2M = pO2M_;
% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
if exist('one_meas.mat','file') 
   delete one_meas.mat  
end
% save to .mat file
time=t_;phiM=phiM_;ampM=ampM_;pO2M=pO2M_;
if ~strcmp(Dataname,'DeleteThis')
   save([data_folder_to_save,fname],'time', 'phiM', 'ampM','pO2M',...
      't_', 'phiM_', 'ampM_','pO2M_')
   disp('Measurement saved to (.txt and .mat files)')  
   disp([data_folder_to_save,fname(1:end-4)])
else
   disp('No saving') 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting all measurement data in one subplot
disp('Closing separate figures')
if exist('h1fig')
   if ishandle(h1fig)
      close(h1fig)
   end
end
if exist('h2fig')
   if ishandle(h2fig)
      close(h2fig)
   end
end
if exist('h3fig')
   if ishandle(h3fig)
      close(h3fig)
   end
end
if exist('hsubplotting')
   if ishandle(hsubplotting)
      close(hsubplotting)
   end
end
RunO2sensor_Subplotting
if strcmp(Dataname,'DeleteThis')
   disp('No saving') % deleting files
   if exist('DeleteThis.txt','file')
      delete DeleteThis.txt
      disp('All files deleted.')
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Useful information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% O2 sensor information
   % COM port: assuming the sensor is in (virtual) COM port 7 
      % -> -p7 in dos command
      % -> if else COM port is used, change -p7 value to correct port number in 
      % y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat');
   % Illumination time is now 3s, defined in -t30 (fs=10Hz) --> takes 30 samples

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Future improvements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Temperature-dependent O2% calculation
   % Requires to know temperature + using SternVolmerTcompensated.m

% Asking&changing COMport easily (how to work in dos - command?) 
   % following example not working: % COMport=7; port=['-p',num2str(COMport)]; 
   % y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat'); 

%%%% Nice to Have features %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Write a log file (in certain lines during the loop) to see when measurement stopped
% Säikeistys, jossa mittauspuoli ja piirtopuoli erillaan
% Better method to stop during pause state 
   % using MATLAB timers etc
      

