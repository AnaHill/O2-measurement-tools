%% Reading O2 sensor and plotting & saving (read more info in the end)
   % Requires m-files: SternVolmerC.m
% Version 1.2 updates
   % Asking plotting or not
   % Asking calibration values/files
   % Always Plotting "command figure" with buttons: Plot / Stop / Change Calibration
      % Now reading (new) calibration file only when clicked
clear, close all
pause_time=1; % sets pause time (in sec) before next measurement
Testing_Script = 1; % set 1 only if testing/debugging script
% FigsToPlot=[1:3];% Figs to plot: % 1 = Phase, 2 = Amp, 3 = pO_2
answer_plotting = questdlg(['How do you want plot (on-real time) during measurement?'], ...
   'Plotting','Yes','No', 'Yes');
if strcmp(answer_plotting ,'Yes')
   dlg_title = ['Figures '];
   prompt = {['Insert numbers that you want to plot',10,...
      '1 = Phase, 2 = Amp, 3 = pO2',10,...
      'E.g. set 3 --> Plot only pO2, set 1,2,3 --> plot all three']};
   num_lines = 1;
   defaultans = {'3'};
   answer = inputdlg(prompt,[dlg_title],num_lines,defaultans);    
   FigsToPlot = str2num(answer{:});
   if any(FigsToPlot < 0) || any(FigsToPlot > 3)
      error('No correct figures chosen')
   end
else
   FigsToPlot=[];
end 
%% Calibration info: create variables Ksv, phi0, and caldevi
if exist('O2_Sensor_Calibration_parameters.txt', 'file')
   useFoundData = questdlg(['Required calibration file (.txt) found; use it?'], ...
   'Chosen ','Yes','No', 'Yes');
   if strcmp(useFoundData ,'Yes')
      temp=load('O2_Sensor_Calibration_parameters.txt'); % read from file 
      Ksv=temp(1); phi0=temp(2); caldevi=temp(3);
      disp(['Calibration parameters from the file are:'])
      disp(['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)])
   end
end
ise = evalin( 'base', 'exist(''Ksv'',''var'') == 1' );
ise2 = evalin( 'base', 'exist(''phi0'',''var'') == 1' );
ise3 = evalin( 'base', 'exist(''caldevi'',''var'') == 1' );
if~(ise && ise2 && ise3)
   answer_calibValues = questdlg(['How do you want to set calibration value?'], ...
   'Choosing ','From file','Manually', 'From file');
   if strcmp(answer_calibValues ,'From file')
      [FileName,PathName,FilterIndex] = uigetfile('*.txt','Pick a (.txt) calibration file.');
      temp=load([PathName,FileName]);
      if length(temp) == 3
         Ksv=temp(1); phi0=temp(2); caldevi=temp(3);
      end
      disp(['Calibration parameters from the file are:'])
      disp(['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)])
   else % choose manually
      prompt = {'Ksv:','phi0:','caldevi:'};
      dlg_title = 'Set calibration values';
      num_lines = 1;
      defaultans = {'0.185','53','18'};
      answer = inputdlg(prompt,dlg_title,num_lines,defaultans); 
      Ksv=str2num(answer{1}); phi0=str2num(answer{2}); caldevi=str2num(answer{3});
      disp(['Manually chosen calibration parameters:'])
      disp(['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)])      
   end
end
% Check that proper calibration parameters exist
ise = evalin( 'base', 'exist(''Ksv'',''var'') == 1' );
ise2 = evalin( 'base', 'exist(''phi0'',''var'') == 1' );
ise3 = evalin( 'base', 'exist(''caldevi'',''var'') == 1' );
if ise && ise2 && ise3
   calib = ['calib. param.: Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)]; 
   disp(['Final calibration parameters are:'])
   disp(['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)])
else
   [FileName,PathName,FilterIndex] = uigetfile('*.txt','Pick a (.txt) calibration file.');
   temp=load([PathName,FileName]);
   if length(temp) == 3
      Ksv=temp(1); phi0=temp(2); caldevi=temp(3);
   end
   ise = evalin( 'base', 'exist(''Ksv'',''var'') == 1' );
   ise2 = evalin( 'base', 'exist(''phi0'',''var'') == 1' );
   ise3 = evalin( 'base', 'exist(''caldevi'',''var'') == 1' );
   if ise && ise2 && ise3
      calib = ['calib. param.: Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
         ', caldevi: ',num2str(caldevi)]; 
      disp(['Final Calibration parameters are:'])
      disp(['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
         ', caldevi: ',num2str(caldevi)])
   else
      error('No calibration values found!')
   end
end
disp(['To change these calibration values during measurement ->'])
disp(['Edit/create O2_ChangeSensorCalib_parameters.txt file e.g. in Notepad'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Creating .txt & .mat files where data is saving
% asking file name (starting time is added) and folder,
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Set folder where data is saved.')
data_folder_to_save = [uigetdir(pwd,' Choose a Directory where data is saved'),'\'];
prompt = ['Give measurement file name, it will be save to: ',10,...
   data_folder_to_save,10,...
   '(date and time will be added automatically to the end of name)' ];
name = 'Measurement file name';numlines=1; defaultanswer={'Data'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer) % if cancel is pressed
   error('Cancelled')
end
Dataname=answer{:};
fname=[strcat(Dataname,'_',datestr(now,'yyyy_mm_dd__HH_MM_SS')),'.mat'];
fnametxt=[fname(1:end-3),'txt'];
fileID = fopen([data_folder_to_save,fnametxt], 'a');
fprintf(fileID,'%s %8s %8s %8s\n','t_', 'phiM_', 'ampM_','pO2M_');
fclose(fileID);
disp(['Measurement file name: ',fname,', saving location: ',data_folder_to_save])
phiM_=[]; ampM_=phiM_; pO2M_=phiM_; t_=phiM_;
if exist('FigsToPlot','var') && length(FigsToPlot) >= 1 % plotting
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
               ylabel('Phase (deg)');h1 = animatedline('Marker','o','Color','r'); 
            case 2
               ylabel('Amplitude ()');h2 = animatedline('Marker','v','Color',Colours{2}); 
            case 3
               ylabel('O_2 (%)');h3 = animatedline('Marker','x','Color','b');  
         end
         xlabel('Time (s)')
   end
end
StopFig = figure('Name','Press Subplot to see measurement, Stop button to stop measurement');
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
dim = [.5 .5 .3 .3];
str = ['When clicked, calibration parameters are read from file',10,...
   'O2_ChangeSensorCalib_parameters.txt',10,...
   '-> Change parameters from that file'];
annotation('textbox',dim,'String',str,'interpreter','none','FitBoxToText','on');
if exist('one_meas.mat','file') 
   delete one_meas.mat % 
end
x=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Start measurement')
while(ishandle(H))
      if exist('subplotting','var') && subplotting == 1 
         disp('Loading data from text file and plotting')
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
         disp('Read files from')  
         disp([data_folder_to_save,fnametxt])
         Data_={phiM_, ampM_, pO2M_};time=t_;
         colours={'r',[0 0.5 0],'b'};
         MaxTime_sec=max(time);
         if MaxTime_sec < 300
            time_ = time; xlabeling = ('Time (sec)');
         elseif (MaxTime_sec >= 300 && MaxTime_sec < 60*60*3)
            time_ = time/60; xlabeling = ('Time (min)');
         else
            time_ = time/(60*60); xlabeling = ('Time (h)');
         end
         if exist('hsubplotting','var') 
            if ishandle(hsubplotting)
               close(hsubplotting)
            end
         end
         hsubplotting=figure('Name','Subplotting current state');
         for pp = 1:3
            subplot(3,1,pp), plot(time_,Data_{pp},'color',colours{pp}),grid on;
            xlabel(xlabeling)
            switch pp
               case 1
                  ylabel('Phase (deg)');
               case 2
                  ylabel('Amplitude ()');   
               case 3 
                  ylabel('O_2 (%)')% ('pO_2 (kPa)');
            end   
         end
         clear subplotting t_ phiM_ ampM_ pO2M_
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
      disp('Reading calibration values from: O2_ChangeSensorCalib_parameters.txt')
      temp=load('O2_ChangeSensorCalib_parameters.txt'); 
      Ksv=temp(1); phi0=temp(2);  caldevi=temp(3); 
      calib = ['calib. param.: Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
         ', caldevi: ',num2str(caldevi)]; % disp(calib) 
       clear change_calibration
      disp('Calibration values read from .txt file, new values are:')
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
      if exist('h1','var')
         addpoints(h1,tnow,phi);drawnow;
      end
      if exist('h2','var')
         addpoints(h2,tnow,amp);drawnow;
      end
      if exist('h3','var')
         addpoints(h3,tnow,pO2);drawnow;
      end
   else % no plotting
       disp(['No Plotting ',num2str(x),')',res, ' (',calib,')'])
   end
   if exist('pause_time','var') && pause_time > 0 % if pause before next measurement
      pause(abs(pause_time))
   end
   x=x+1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Stop button pressed. Stopping measurement')  
%%% SAVING %%%%%%%%%%%%%%% read measurement FROM .txt and save to .mat file
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
save([data_folder_to_save,fname],'time', 'phiM', 'ampM','pO2M',...
   't_', 'phiM_', 'ampM_','pO2M_')
disp('Measurement saved to (.txt and .mat files)')  
disp([data_folder_to_save,fname(1:end-4)])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting all measurement data in one subplot
disp('Closing separate figures')
% close all
if length(FigsToPlot) > 0
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
end
Data={phiM, ampM, pO2M};
colours={'r',[0 0.5 0],'b'};
MaxTime_sec=max(time);
if MaxTime_sec < 300
   time_ = time; xlabeling = ('Time (sec)');
elseif (MaxTime_sec >= 300 && MaxTime_sec < 60*60*3)
   time_ = time/60; xlabeling = ('Time (min)');
else
   time_ = time/(60*60); xlabeling = ('Time (h)');
end
disp('Plotting phase, amp, and O2% in subplot')  
figure('Name','Subplot','units','normalized','outerposition',[0 0 1 1])
for pp = 1:3
   subplot(3,1,pp), plot(time_,Data{pp},'color',colours{pp}),grid on;
   xlabel(xlabeling)
   switch pp
      case 1
         ylabel('Phase (deg)');
      case 2
         ylabel('Amplitude ()');   
      case 3 
         ylabel('O_2 (%)')
   end   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Useful information %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Calibration parameters 1) KSV, 2) phi0, 3) caldevi
   % Typical values: Ksv=0.185; phi0=53;caldevi=18; 
   % Here, these are read from .txt file:'O2_Sensor_Calibration_parameters.txt'
      % % Calibration file rows: 1) KSV, 2) phi0, 3) caldevi
   % Changing during measurement, set: Enable_to_change_calibration_data == 1 
      % --> New values read from_ O2_ChangeSensorCalib_parameters.txt
      % Change these parameters e.g. in Notepad and save text file
         % NOTICE: for long-term stability, it might be better disable this
      
%%%% O2 sensor information
   % COM port: assuming the sensor is in (virtual) COM port 7 
      % -> -p7 in dos command
      % -> if else COM port is used, change -p7 value to correct port number in 
      % TWO lines where is the command
      % y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat');
   % Illumination time is now 3s, defined in -t30 (fs=10Hz) --> takes 30 samples

%%%% pause_time
   % Notice, that MATLAB is 'busy' during pause_time 
   % --> pressing STOP button will stop measurement after pause_time is ended
      % Method to stop MATLAB during pause_time: use cntr+C (not recommended)

%%%% Plotting or not during the measurement
   % WITHOUT maybe more stable in long-term measurements, SET ->: FigsToPlot=[];  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Future improvements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stopping during "pause" state (now have to wait for pause time while)
   % Unknown how to do it (easily)...

% Jos kirjoittaisi vasta x hetken jälkeen, eikä jokaisen loopin yhteydessä --> vähemmän avaamista&sulkemista
   
% Temperature-dependent O2% calculation
   % Requires to know temperature + using SternVolmerTcompensated.m

% Plotting: would comet/else be better than addpoints?
   % https://se.mathworks.com/matlabcentral/answers/3739-comet-how-can-slow-down-the-animation

% Asking&changing COMport easily (how to work in dos - command?) 
   % following example not working: % COMport=7; port=['-p',num2str(COMport)]; 
   % y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat'); 

% säikeistys, jossa mittauspuoli ja piirtopuoli erillään
% Write a log file to see if/when measurement stopped
      % during while, in certain places
      % fileID = fopen([data_folder_to_save,fname(1:end-4),'_log.txt'],'a');
      % fprintf(fileID,'%s,'Text in this line (e.g. data from dos received etc)');
      % fclose(fileID);
      
% Including calibration changes in Command GUI/window
   % pystyisi muuttamaan kalibrointiarvoja suoraan figuressa
