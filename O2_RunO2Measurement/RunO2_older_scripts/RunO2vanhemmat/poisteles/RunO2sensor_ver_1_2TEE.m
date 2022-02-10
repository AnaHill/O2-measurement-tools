%% Reading O2 sensor and plotting & saving (read more info in the end)
   % Requires m-files: SternVolmerC.m
% Version 1.2 updates
% TEE seuraavat
   % Plotting always "command fig" with buttons: Plot / Stop 
clear, close all
pause_time=1; % sets pause time (in sec) before next measurement
FigsToPlot=[1:3]%1:3]; %[3];% Figs to plot: % 1 = Phase, 2 = Amp, 3 = pO_2
% Without PLOTTING, set: FigsToPlot=[];  
%% Testing script (set 1 only if testing/debuggin script)
Testing_Script = 1; 
%% Calibration info: create variables Ksv, phi0, and caldevi
% manual run (change to correct): Ksv=0.185; phi0=53;caldevi=18; 
temp=load('O2_Sensor_Calibration_parameters.txt'); % read from file 
Ksv=temp(1); phi0=temp(2); caldevi=temp(3);
calib = ['calib. param.: Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
	', caldevi: ',num2str(caldevi)]; 
% Below, mark 1 if want to change calibration data during measurement
% NOTICE: for long-term stability, it might be better disable this
Enable_to_change_calibration_data=0;
% Change values in O2_ChangeSensorCalib_parameters.txt during the measurement
%% Saving data to .txt & .mat file, asking name(+adding starting time) and folder,
data_folder_to_save = [uigetdir(pwd,'Pick a Directory where data is saved'),'\'];
prompt = ['Give measurement file name, it will be save to: ',10,...
   data_folder_to_save,10,...
   '(date and time will be added automatically to the end of name)' ];
name = 'Measurement file name';numlines=1; defaultanswer={'Data'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
   exit('Cancelled')
end
Dataname=answer{:};
fname=[strcat(Dataname,'_',datestr(now,'yyyy_mm_dd__HH_MM_SS')),'.mat'];
fnametxt=[fname(1:end-3),'txt'];
fileID = fopen([data_folder_to_save,fnametxt], 'a');
fprintf(fileID,'%s %8s %8s %8s\n','t_', 'phiM_', 'ampM_','pO2M_');
fclose(fileID);
disp(['Measurement file name: ',fname,', saving location: ',data_folder_to_save])
phiM_=[]; ampM_=phiM_; pO2M_=phiM_; t_=phiM_;
%% MUUTA TÄSSÄ, että aina tuo StopFig piirretään
x=1;
if exist('FigsToPlot','var') && length(FigsToPlot) >= 1 % plotting
   Markers={'o','v','x'}; Colours={'r',[0 0.5 0],'b'};
   FigsToPlot=sort(FigsToPlot);
   fig_size_normalized=[0.3000 0.4267]; % width and height
   h1fig=figure(FigsToPlot(1)); grid on, hold on,
   set(h1fig, 'units','normalized','outerposition',[0 0.5 fig_size_normalized]);
   H = uicontrol('Style', 'PushButton', 'String', 'Stop', 'Callback', 'delete(gcbo)');
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
               ylabel('Amplitude ()');h2 = animatedline('Marker','v','Color','g'); 
            case 3
               ylabel('O_2 (%)');h3 = animatedline('Marker','x','Color','b');  
         end
         xlabel('Time (s)')
   end
else % no plotting during measurement, only closing&subplotting figure
   StopFig = figure('Name','Press Subplot to see measurement, Stop button to stop measurement');
   set(StopFig, 'units','normalized','outerposition',[0.35 0.4 0.3 0.45]);
   H = uicontrol('Style', 'PushButton','String', 'Stop', 'Callback',...
      'delete(gcbf)','fontsize',16,'ForegroundColor','r','Fontweight','bold');
   set(H,'units','normalized','Outerposition', [0.4 0.2 0.2 0.1])  
   H2subplot = uicontrol('Style', 'PushButton','String', 'Plot measurement', 'Callback',...
      'subplotting=1','fontsize',14,'Fontweight','bold');
   set(H2subplot,'units','normalized','Outerposition', [0.3 0.8 0.4 0.1])
end
if exist('one_meas.mat','file') 
   delete one_meas.mat % this if loop takes ~0.03 sec
end
if exist('FigsToPlot','var') && length(FigsToPlot) >= 1
   while(ishandle(H))
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
      % Check & load calibration values (if want to change during)
      if exist('Enable_to_change_calibration_data','var') && ...
            Enable_to_change_calibration_data == 1
         temp=load('O2_ChangeSensorCalib_parameters.txt'); 
         Ksv=temp(1); phi0=temp(2);  caldevi=temp(3); 
         calib = ['calib. param.: Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
            ', caldevi: ',num2str(caldevi)]; % disp(calib) 
       end    
       % Converting to pO2 [%]
       pO2 = SternVolmerC(Ksv,phi0,-phi,caldevi);
       res = ['Time ',num2str(tnow, '%.1f'), 's -> pO2: ',num2str(pO2,'%.2f'),...
          ' (phi: ',num2str(phi,'%.3f'),...
          ', amp: ',num2str(amp,'%.3f'),')'];
       disp([num2str(x),')',res, ' (',calib,')'])
       % saving
       phiM_(1)=phi; ampM_(1)=amp; pO2M_(1)=pO2; Dat=[t_, phi, amp, pO2];
       fileID = fopen([data_folder_to_save,fnametxt], 'a');
       fprintf(fileID,'%d %8d %8d %8d\n', Dat);
       fclose(fileID);    
       if length(FigsToPlot) == 3
            addpoints(h1,tnow,phi);drawnow;
            addpoints(h2,tnow,amp);drawnow;
            addpoints(h3,tnow,pO2);drawnow;
       else
          if exist('h1fig','var')
             addpoints(h1,tnow,phi);drawnow;
          end
          if exist('h2fig','var')
             addpoints(h2,tnow,amp);drawnow;
          end
          if exist('h3fig','var')
             addpoints(h3,tnow,pO2);drawnow;
          end
       end
       if exist('pause_time','var') && pause_time > 0 % possible pause before next measurement
         pause(abs(pause_time))
       end
       x=x+1;
   end
%% MODAA
else % Running measurement but not plotting continuously (use Subplot button)
   while(ishandle(H))
      if exist('subplotting','var') && subplotting == 1 
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
         figure('Name','Subplotting current state');
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
      if exist('Testing_Script','var') && Testing_Script == 1  % for testing purposes
         phi=rand(30,1); amp=rand(30,1);
         phi = mean(phi(11:end));amp = mean(amp(11:end));
      else % measurement p = COM port #, t = time (fs=10Hz -> t30 = 3sec), ...
         y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat');
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
      if exist('Enable_to_change_calibration_data','var') && Enable_to_change_calibration_data == 1
         temp=load('O2_ChangeSensorCalib_parameters.txt'); 
         Ksv=temp(1); phi0=temp(2);  caldevi=temp(3); 
         calib = ['calib. param.: Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
            ', caldevi: ',num2str(caldevi)]; % disp(calib) 
       end    
       % Converting to pO2
       pO2 = SternVolmerC(Ksv,phi0,-phi,caldevi);
       res = ['No plotting, Time ',num2str(tnow, '%.1f'), 's -> pO2: ',num2str(pO2,'%.2f'),...
          ' (phi: ',num2str(phi,'%.3f'),...
          ', amp: ',num2str(amp,'%.3f'),')'];
       disp([num2str(x),')',res, ' (',calib,')'])
       % saving
       phiM_(1)=phi; ampM_(1)=amp; pO2M_(1)=pO2; Dat=[t_, phi, amp, pO2];
       fileID = fopen([data_folder_to_save,fnametxt], 'a');
       fprintf(fileID,'%d %8d %8d %8d\n', Dat);
       fclose(fileID); 
       if exist('pause_time','var') && pause_time > 0 % possible pause before next measurement
         pause(abs(pause_time))
       end
       x=x+1;
   end
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
time=t_;phiM=phiM_;ampM=ampM_;pO2M=pO2M_;
save([data_folder_to_save,fname],'time', 'phiM', 'ampM','pO2M',...
   't_', 'phiM_', 'ampM_','pO2M_')
disp('Measurement saved to (.txt and .mat files)')  
disp([data_folder_to_save,fname(1:end-4)])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plotting all in one subplot
disp('Closing separate figures')
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
figure('Name','Subplot');
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
%% Useful information
%%%% Calibration parameters 1) KSV, 2) phi0, 3) caldevi
   % Typical values: Ksv=0.185; phi0=53;caldevi=18; 
   % Here, these are read from .txt file:'O2_Sensor_Calibration_parameters.txt'
      % NOTICE: if Enable_to_change_calibration_data == 1 -->
      % New calibration values are read from O2_ChangeSensorCalib_parameters.txt
      % calibration file rows: 1) KSV, 2) phi0, 3) caldevi
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
%% Future improvements
% Stopping during "pause" state (now have to wait for pause time while)
   % Unknown how to do it (easily)...
% Temperature-dependent O2% calculation
   % Requires to know temperature + using SternVolmerTcompensated.m
% Plotting: comet/else be better than addpoints?
   % https://se.mathworks.com/matlabcentral/answers/3739-comet-how-can-slow-down-the-animation
% Asking&changing COMport easily (how to work in dos - command?) 
   % following example not working: % COMport=7; port=['-p',num2str(COMport)]; 
   % y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat'); 
% Write a log file to see if/when measurement stopped
      % during while, in certain places
      % fileID = fopen([data_folder_to_save,fname(1:end-4),'_log.txt'],'a');
      % fprintf(fileID,'%s,'Text in this line (e.g. data from dos received etc)');
      % fclose(fileID);

