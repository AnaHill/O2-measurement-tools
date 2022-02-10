%% Reading O2 sensor and plotting & saving
% close all, RunO2sensor
clear all
FigsToPlot=3% [1:3]; % which figs you want to plot: % 1) phase, 2) amp, 3) pO_2
Enable_to_change_calibration_data=1; % mark 1, if want to change calibration data during measurement
% Testing_Script = 1; % set 1 if want only to test the device
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
mm=5; m=1e7; phiM=zeros(m,1); ampM=phiM; pO2=phiM; t=phiM;
%%
hFig=figure(FigsToPlot(1)); set(hFig, 'KeyPressFcn', 'keep=0')
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
x=1;dt=1; %sample interval. Estimated illumination time 4s -> dt=26 + 4 lead to ~30s interval
while keep>0 % Running till ESC pressed in the first figure
   if exist('Testing_Script','var') && Testing_Script == 1 
         phi=rand();
         amp=rand();
   else % p?-> COM port, t?-> time?, i?-> ??, ...
%       y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat');
      y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz one_meas.mat');
      load one_meas.mat
      phi=mean(angle(Measurement-StopCal)/pi*180);
      amp=mean(abs(Measurement-StopCal)/pi*180);
   end
    
    
    if x<2 % tic in the begin to log time
        tic
        tnow=0;
        t(x)=0;
    else
        tnow=toc;
        t(x)=tnow;
    end
    % This enables to change
    if exist('Enable_to_change_calibration_data','var') && Enable_to_change_calibration_data == 1
      % loading calibration file,rows: 1) KSV, 2) phi0, 3) caldevi
      temp=load('O2_Sensor_Calib_changing_parameters.txt'); 
      Ksv=temp(1); phi0=temp(2);  caldevi=temp(3); 
      calib = ['Calib: Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
         ', caldevi: ',num2str(caldevi)]; % disp(calib) 
    end    
    % Converting to pO2
    pO2 = SternVolmerC(Ksv,phi0,-phi,caldevi);
    res = ['pO2: ',num2str(pO2,3),' (phi: ',num2str(phi,4),...
       ', amp: ',num2str(amp,4),')'];
    disp([res, ' (',calib,')'])
    % saving and drawing
    phiM(x)=phi; ampM(x)=amp; pO2M(x)=pO2;
	 save(fname,'t', 'phiM', 'ampM','pO2M')
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
end
%%% Lopuksi poista nollat datasta
phiM1=nonzeros(phiM);
ampM1=nonzeros(ampM);
pO2M1=nonzeros(pO2M);
t1=[0;nonzeros(t)]; 
% save(fname,'t', 'phiM', 'ampM','pO2M')
save(fname,'t1', 'phiM1', 'ampM1','pO2M1')
%% plotting all in one subplot
Data_={phiM1, ampM1,pO2M1};
colours={'r',[0 0.5 0],'b'};
MaxTime_sec=max(t1);
if MaxTime_sec < 300
   time_ = t1; xlabeling = ('Time (sec)');
elseif (MaxTime_sec >= 300 && MaxTime_sec < 60*60*3)
   time_ = t1/60; xlabeling = ('Time (min)');
else
   time_ = t1/(60*60); xlabeling = ('Time (h)');
end
figure, 
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


%% Muita










