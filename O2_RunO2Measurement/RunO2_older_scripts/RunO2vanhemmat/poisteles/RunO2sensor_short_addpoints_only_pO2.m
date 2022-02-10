%% Reading O2 sensor SHORT
clear, close all
pause_time=1; % sets pause time (in sec) before next measurement
FigsToPlot=[3];  % VAIN 3 = pO_2
%% Testing script (set 1 only if testing/debuggin script)
Testing_Script = 0; 
%% Calibration info: create variables Ksv, phi0, and caldevi
temp=load('O2_Sensor_Calibration_parameters.txt'); % read from file 
Ksv=temp(1); phi0=temp(2); caldevi=temp(3);
calib = ['calib. param.: Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
	', caldevi: ',num2str(caldevi)]; 
% Enable_to_change_calibration_data=0;
%% Saving data to .mat file, name based on starting time
fname=[strcat('data_',datestr(now,'yyyy_mm_dd__HH_MM_SS')),'.mat'];
phiM_=[]; ampM_=phiM_; pO2M_=phiM_; t_=phiM_;
%% Measurement
Markers={'o','v','x'}; Colours={'r',[0 0.5 0],'b'};
FigsToPlot=sort(FigsToPlot);
fig_size_normalized=[0.3000 0.4267]; % width and height
% figs
h1fig=figure(FigsToPlot(1)); grid on, hold on,
set(h1fig, 'units','normalized','outerposition',[0 0.5 fig_size_normalized]);
H = uicontrol('Style', 'PushButton', 'String', 'Stop', 'Callback', 'delete(gcbo)');
% % % h2fig=figure(FigsToPlot(2)); grid on, hold on,
% % % set(h2fig, 'units','normalized','outerposition',[0.35 0.5 fig_size_normalized]);
% % % h3fig=figure(FigsToPlot(3)); grid on, hold on,
% % % set(h3fig, 'units','normalized','outerposition',[0.7 0.5 fig_size_normalized]);
for pp = 1:length(FigsToPlot)
      figure(FigsToPlot(pp))
      switch FigsToPlot(pp)
% % %          case 1               
% % %             ylabel('Phase (deg)'); h1 = animatedline('Marker','o','Color','r'); 
% % %          case 2
% % %             ylabel('Amplitude ()'); h2 = animatedline('Marker','v','Color',[0 0.5 0]); 
         case 3
            ylabel('O_2 (%)'); h3 = animatedline('Marker','x','Color','b');
      end
      xlabel('time [s]')
end
x=1;
while(ishandle(H))
   if exist('Testing_Script','var') && Testing_Script == 1  % for testing purposes
      phi=rand(30,1); amp=rand(30,1);
      phi = mean(phi(11:end));amp = mean(amp(11:end));
   else 
      y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat');
      load one_meas.mat
      phi=mean(angle(Measurement-StopCal)/pi*180);
      amp=mean(abs(Measurement-StopCal));
   end 
   if x<2 % tic in the begin to log time
      tic, tnow=0;
   else
      tnow=toc;
   end
   t_(end+1)=tnow;  
    % Converting to pO2 [%]
    pO2 = SternVolmerC(Ksv,phi0,-phi,caldevi);
    res = ['Time ',num2str(tnow, '%.1f'), 's -> pO2: ',num2str(pO2,'%.2f'),...
       ' (phi: ',num2str(phi,'%.3f'),...
       ', amp: ',num2str(amp,'%.3f'),')'];
    disp([num2str(x),')',res, ' (',calib,')'])
    % saving
    phiM_(end+1)=phi; ampM_(end+1)=amp; pO2M_(end+1)=pO2;
    save(fname,'t_', 'phiM_', 'ampM_','pO2M_')
    % drawing
% % %     addpoints(h1,tnow,phi);drawnow;
% % %     addpoints(h2,tnow,amp);drawnow;
	 addpoints(h3,tnow,pO2);drawnow;
    if exist('pause_time','var') && pause_time > 0 % possible pause
      pause(abs(pause_time))
    end
    x=x+1;
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


