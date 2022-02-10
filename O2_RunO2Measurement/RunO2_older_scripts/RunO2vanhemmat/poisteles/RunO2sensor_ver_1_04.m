%% Reading O2 sensor and plotting & saving (read more info in the end)
   % Requires m-files: SternVolmerC.m
% Version 1.04 updates
   % bug fixs: 
      % Plotting x&y-labels outside while loop
clear, close all
pause_time=1; % sets pause time (in sec) before next measurement
FigsToPlot=[1:3]; %[3];% Figs to plot: % 1 = Phase, 2 = Amp, 3 = pO_2
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
Enable_to_change_calibration_data=0;
% Change values in O2_ChangeSensorCalib_parameters.txt during the measurement
%% Saving data to .mat file, asking name(+adding starting time) and folder,
data_folder_to_save = [uigetdir(pwd,'Pick a Directory where data is saved'),'\'];
prompt = ['Give measurement file name, it will be save to: ',10,...
   data_folder_to_save,10,...
   '(date and time will be added automatically to the end of name)' ];
name = 'Measurement file name';numlines=1; defaultanswer={'data'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
Dataname=answer{:};
fname=[strcat(Dataname,'_',datestr(now,'yyyy_mm_dd__HH_MM_SS')),'.mat'];
disp(['Measurement file name: ',fname,', saving location: ',data_folder_to_save])
phiM_=[]; ampM_=phiM_; pO2M_=phiM_; t_=phiM_;
%% Measurement
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
               ylabel('Phase (deg)');
            case 2
               ylabel('Amplitude ()'); 
            case 3
               ylabel('O_2 (%)'); 
               %h3 = animatedline('Marker','x','Color','b');  
         end
         xlabel('time [s]')
   end
else % no plotting during measurement, only closing&subplotting figure
   StopFig = figure('Name','Press Subplot to see measurement, Stop button to stop measurement');
   set(StopFig, 'units','normalized','outerposition',[0.35 0.4 0.3 0.45]);
   H = uicontrol('Style', 'PushButton','String', 'Stop', 'Callback',...
      'delete(gcbf)','fontsize',16,'ForegroundColor','r','Fontweight','bold');
   set(H,'units','normalized','Outerposition', [0.4 0.2 0.2 0.1])  
   H2subplot = uicontrol('Style', 'PushButton','String', 'Plot measurement', 'Callback',...
      'subplotting=1','fontsize',16,'Fontweight','bold');
   set(H2subplot,'units','normalized','Outerposition', [0.3 0.6 0.4 0.1])
end

if exist('FigsToPlot','var') && length(FigsToPlot) >= 1
   while(ishandle(H))
      % Reading data
      if exist('Testing_Script','var') && Testing_Script == 1  % for testing purposes
         phi=rand(30,1); amp=rand(30,1);
         phi = mean(phi(11:end));amp = mean(amp(11:end));
      else 
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
      t_(end+1)=tnow;
      % Check&load calibration values
      if exist('Enable_to_change_calibration_data','var') && Enable_to_change_calibration_data == 1
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
       % saving and drawing
       phiM_(end+1)=phi; ampM_(end+1)=amp; pO2M_(end+1)=pO2;
       save([data_folder_to_save,fname],'t_', 'phiM_', 'ampM_','pO2M_')
       if length(FigsToPlot) == 3
            figure(h1fig),line([tnow],[phi],'marker',Markers{1},'color',Colours{1})
            figure(h2fig),line([tnow],[amp],'marker',Markers{2},'color',Colours{2})
            figure(h3fig),line([tnow],[pO2],'marker',Markers{3},'color',Colours{3})
       else
          if exist('h1fig','var')
            figure(h1fig),line([tnow],[phi],'marker',Markers{FigsToPlot(1)},...
               'color',Colours{FigsToPlot(1)})
%              addpoints(h1,tnow,phi);drawnow;
          end
          if exist('h2fig','var')
             figure(h2fig),line([tnow],[amp],'marker',Markers{FigsToPlot(2)},...
               'color',Colours{FigsToPlot(2)})
%              addpoints(h2,tnow,amp);drawnow;
          end
          if exist('h3fig','var')
             figure(h3fig),line([tnow],[pO2],'marker',Markers{FigsToPlot(3)},...
               'color',Colours{FigsToPlot(3)})
%              addpoints(h3,tnow,pO2);drawnow;
          end
       end
       x=x+1;
       if exist('pause_time','var') && pause_time > 0 % possible pause before next measurement
         pause(abs(pause_time))
       end
   end
else % Running measurement but not plotting continuously (use Subplot button)
   while(ishandle(H))
      if exist('subplotting','var') && subplotting == 1 
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
         clear subplotting;
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
      t_(end+1)=tnow;
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
       phiM_(end+1)=phi; ampM_(end+1)=amp; pO2M_(end+1)=pO2;
       save(fname,'t_', 'phiM_', 'ampM_','pO2M_')
       x=x+1;
       if exist('pause_time','var') && pause_time > 0 % possible pause before next measurement
         pause(abs(pause_time))
       end                 
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Stop button pressed. Stopping measurement')  
%%% SAVING %%%%%%%%%%%%%%%
time=t_;phiM=phiM_;ampM=ampM_;pO2M=pO2M_;
save(fname,'time', 'phiM', 'ampM','pO2M',...
   't_', 'phiM_', 'ampM_','pO2M_')
disp('Measurement saved')  

%% plotting all in one subplot
disp('Plotting phase, amp, and O2% in subplot, closing separate figures')  
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
% Calibration parameters 1) KSV, 2) phi0, 3) caldevi
   % Typical values: Ksv=0.185; phi0=53;caldevi=18; 
   % Here, these are read from .txt file:'O2_Sensor_Calibration_parameters.txt'
      % NOTICE: if Enable_to_change_calibration_data == 1 -->
      % New calibration values are read from O2_ChangeSensorCalib_parameters.txt
      % calibration file rows: 1) KSV, 2) phi0, 3) caldevi
% O2 sensor information
   % COM port: assuming the sensor is in (virtual) COM port 7 
      % -> -p7 in dos command
      % -> if else COM port is used, change -p7 value to correct port number in 
      % TWO lines where is the command
      % y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat');
   % Illumination time is now 3s, defined in -t30 (fs=10Hz) --> takes 30 samples
% pause_time
   % Notice, that MATLAB is 'busy' during pause_time 
   % --> pressing STOP button will stop measurement after pause_time is ended
   % Method to stop MATLAB during pause_time: use cntr+C (not recommended)
% Plotting or not during the measurement
   % WITHOUT can be more stable, thusbetter for a long-term measurements, SET: 
   % FigsToPlot=[];  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Future improvements
% a) Stopping during "pause" state (now have to wait for pause time while)
   % Unknown how to do it (easily)...
% b) Temperature-dependent O2% calculation
% c) For plotting during measurement, would comet/else be better than line?
   % https://se.mathworks.com/matlabcentral/answers/3739-comet-how-can-slow-down-the-animation
% d) COMport asking/changing easily (how to work in dos - command?) following not working
   % COMport=7; port=['-p',num2str(COMport)]; 
   % y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat'); 
% e) Write a log file to see if/when measurement stopped




