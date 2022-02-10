%% Reading O2 sensor and plotting & saving
clear, close all
FigsToPlot=[3]; % which figs you want to plot: % 1) phase, 2) amp, 3) pO_2
Enable_to_change_calibration_data=1; % mark 1, if want to change calibration data during measurement
Testing_Script = 0; % set one if want only to test the scipt (random data used)
pause_time=0; % sets time (in sec) before next measurement --> useful for long term measurement 
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
% m=1e7;phiM_(1:m)=NaN; ampM_=phiM_; pO2M_=phiM_; t_=phiM_;
%m=1e7;phiM_=zeros(1,m); ampM_=phiM_; pO2M_=phiM_; t_=phiM_;

%%
hFig=figure(FigsToPlot(1)); set(hFig, 'KeyPressFcn', 'keep=0')
hFig.Name='Press ESC to stop measurement';
keep = 1; % press ESC in the first figure to Stop measurement
for pp = 1:length(FigsToPlot)
   figure(FigsToPlot(pp)), grid on, clf
   xlabel('time [s]')
   switch FigsToPlot(pp)
      case 1
         ylabel('phase [deg]');h1 = animatedline('Marker','o','Color','r'); 
      case 2
         ylabel('amp [µV]');   h2 = animatedline('Marker','v','Color','g'); 
      case 3
         ylabel('pO_2 [kPa]'); h3 = animatedline('Marker','x','Color','b');  
   end    
end
% Reading data and plotting
x=1;
%sample interval. Estimated illumination time 4s -> dt=26 + 4 lead to ~30s interval
%pause_time=1; % change this to include pause before next measurement
while keep>0 % Running till ESC pressed in the first figure
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
    % Converting to pO2
    pO2 = SternVolmerC(Ksv,phi0,-phi,caldevi);
    res = ['Time ',num2str(tnow, '%.1f'), 's -> pO2: ',num2str(pO2,'%.2f'),...
       ' (phi: ',num2str(phi,'%.3f'),...
       ', amp: ',num2str(amp,'%.3f'),')'];
    disp([res, ' (',calib,')'])
    % saving and drawing
    %phiM_(x)=phi; ampM_(x)=amp; pO2M_(x)=pO2;
    phiM_(end+1)=phi; ampM_(end+1)=amp; pO2M_(end+1)=pO2;
	 save(fname,'t_', 'phiM_', 'ampM_','pO2M_')
   % save([fname(1:end-4),'.txt'],'t_', 'phiM_', 'ampM_','pO2M_','-ascii','-append')
    if length(FigsToPlot) == 3
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
time=t_;phiM=phiM_;ampM=ampM_;pO2M=pO2M_;
save(fname,'time', 'phiM', 'ampM','pO2M',...
   't_', 'phiM_', 'ampM_','pO2M_')
%%% OLD, keep still: reducing NaN or zeros (if any) away from the measurement
% phiM=phiM_(~isnan(phiM_));ampM=ampM_(~isnan(ampM_));
% pO2M=pO2M_(~isnan(pO2M_));time=t_(~isnan(t_));
% % phiM=nonzeros(phiM_);ampM=nonzeros(ampM_);pO2M=nonzeros(pO2M_); time=[0; nonzeros(t_)];
% save(fname,'time', 'phiM', 'ampM','pO2M',...
%    't_', 'phiM_', 'ampM_','pO2M_')
%% plotting all in one subplot
Data_={phiM, ampM, pO2M};
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
   subplot(3,1,pp), plot(time_,Data_{pp},'color',colours{pp}),
   xlabel(xlabeling)
   switch pp
      case 1
         ylabel('phase (deg)');
      case 2
         ylabel('amp (µV)');   
      case 3
         ylabel('pO_2 (kPa)');
   end   

end


%% Mahdollisia lisäyksi
% muuta pO2  -> pO2[%]
   % a) manuaalinen 1 atm:n arvon asetus alkuun
   % b) lämpötilaperusteinen laskeminen








