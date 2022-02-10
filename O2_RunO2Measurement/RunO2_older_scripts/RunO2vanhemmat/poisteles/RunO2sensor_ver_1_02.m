%% Reading O2 sensor and plotting & saving
% Notice: now assuming sensor is in (virtual) COM port 7 -> -p7 in dos command
   % if else, change -p7 value to current port in TWO lines where is the command
      % y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat');
% Version 1.02
   % New in this version:
      % O2 is plotted in [%] as calibration is (almost always) done with dry gas
         %  -> calibration values presents O2[%]
      % Stop button to stop measurement (instead of ESC)
      % Asking before quitting
      % Possible to run measurement without plotting 
         % + possibility to plot current data
         % This MIGHT be more stable, thus increase stability (for long-term
         % measurements) --> USE: FigsToPlot=[] % or not create it at all
clear, close all
FigsToPlot=[1:3];[1:3]; %[3]; % which figs you want to plot: % 1) phase, 2) amp, 3) pO_2
% If WITHOUT PLOTTING (more stable, better for a long-term measurements, SET: 
   % FigsToPlot=[];  
Enable_to_change_calibration_data=1; % mark 1, if want to change calibration data during measurement
Testing_Script = 1; % set one if want only to test the scipt (random data used)
pause_time=1; % sets time (in sec) before next measurement --> useful for long term measurement 
%% Calibration info
% Changing this .txt file values you change calibration parameters during
% measurement: 1) KSV, 2) phi0, 3) caldevi
temp=load('O2_Sensor_Calibration_parameters.txt'); 
% typical values: Ksv=0.185; phi0=53;caldevi=18; 
Ksv=temp(1);  % 0.18-0.215
phi0=temp(2);  % 53-55.84
caldevi=temp(3); % 18
% manual run (change to correct): Ksv=0.185; phi0=53;caldevi=18; 
%% Saving data to .mat file, name based on starting time
fname=[strcat('data_',datestr(now,'yyyy_mm_dd__HH_MM_SS')),'.mat'];
phiM_=[]; ampM_=phiM_; pO2M_=phiM_; t_=phiM_;
%% Plotting (OR NOT)
x=1;
if exist('FigsToPlot','var') && length(FigsToPlot) >= 1
   fig_size_normalized=[0.3000 0.4267]; % width and height
   h1fig=figure(FigsToPlot(1)); grid on
   set(h1fig, 'units','normalized','outerposition',[0 0.5 fig_size_normalized]);
   H = uicontrol('Style', 'PushButton', 'String', 'Stop', 'Callback', 'delete(gcbo)');
   if length(FigsToPlot) > 1
      h2fig=figure(FigsToPlot(2)); grid on
      set(h2fig, 'units','normalized','outerposition',[0.35 0.5 fig_size_normalized]);
   end
   if length(FigsToPlot)> 2
      h3fig=figure(FigsToPlot(3)); grid on
      set(h3fig, 'units','normalized','outerposition',[0.7 0.5 fig_size_normalized]);
   end
else
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
      for pp = 1:length(FigsToPlot)
         figure(FigsToPlot(pp))
         switch FigsToPlot(pp)
            case 1               
               ylabel('Phase (deg)');h1 = animatedline('Marker','o','Color','r'); 
            case 2
               ylabel('Amplitude (µV)'); h2 = animatedline('Marker','v','Color','g'); 
            case 3
               ylabel('O_2 (%)'); h3 = animatedline('Marker','x','Color','b');  
         end
         xlabel('time [s]')
      end
   % Reading data and plotting
   %sample interval. Estimated illumination time 4s -> dt=26 + 4 lead to ~30s interval
   %pause_time=1; % change this to include pause before next measurement
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
         amp=mean(abs(Measurement-StopCal)/pi*180);
      end 
      if x<2 % tic in the begin to log time
         tic
         tnow=0;
      else
         tnow=toc;
      end
   %    t_(x)=tnow; 
      t_(end+1)=tnow;
      % This enables to change calibration parameters
      if exist('Enable_to_change_calibration_data','var') && Enable_to_change_calibration_data == 1
         % loading calibration file,rows: 1) KSV, 2) phi0, 3) caldevi
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
       disp([res, ' (',calib,')'])
       % saving and drawing
       phiM_(end+1)=phi; ampM_(end+1)=amp; pO2M_(end+1)=pO2;
       save(fname,'t_', 'phiM_', 'ampM_','pO2M_')
       % save([fname(1:end-4),'.txt'],'t_', 'phiM_', 'ampM_','pO2M_','-ascii','-append')
       if length(FigsToPlot) == 3
%           figure(h1),line(x,y,'marker','o'
          addpoints(h1,tnow,phi);drawnow;
          addpoints(h2,tnow,amp);drawnow;
          addpoints(h3,tnow,pO2);drawnow;
       else
          if exist('h1','var')
             addpoints(h1,tnow,phi);drawnow;
          end
          if exist('h2','var')
             addpoints(h2,tnow,amp);drawnow;
          end
          if exist('h3','var')
             addpoints(h3,tnow,pO2);drawnow;
          end
       end
       x=x+1;
       if exist('pause_time','var') && pause_time > 0 % possible pause before next measurement
         pause(abs(pause_time))
       end
   end
% Running measurement but not plotting continuously
else 
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
                  ylabel('Amplitude (µV)');   
               case 3 % pO2 calibrated with dry gas in a certain O2% -> given in O2%
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
         amp=mean(abs(Measurement-StopCal)/pi*180);
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
       disp([res, ' (',calib,')'])
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
%disp('Plotting phase, amp, and O2% in subplot')  
disp('Plotting phase, amp, and O2% in subplot, closing separate figures')  
if length(FigsToPlot) > 0
   if ishandle(h1fig)
      close(h1fig)
   end
   if ishandle(h2fig)
      close(h2fig)
   end
   if ishandle(h3fig)
      close(h3fig)
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
         ylabel('Amplitude (µV)');   
      case 3 % pO2 calibrated with dry gas in a certain O2% -> given in O2%
         ylabel('O_2 (%)')% ('pO_2 (kPa)');
   end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Future improvements / Mahdollisia lisäyksiä
% a) Stopping during "pause" state (now have to wait for pause time while)
   % Unknown how to do it (easily)...
% b) Temperature-dependent O2% calculation
% c) Replacing add points + drawnow with comet (or else better)
   % https://se.mathworks.com/matlabcentral/answers/3739-comet-how-can-slow-down-the-animation
% d) COMport asking/changing easily (how to work in dos - command?) following not working
   % COMport=7; port=['-p',num2str(COMport)]; 
   % y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat'); 





