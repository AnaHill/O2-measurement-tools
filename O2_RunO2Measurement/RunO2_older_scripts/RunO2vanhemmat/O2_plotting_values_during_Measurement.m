%% Plotting current O2 sensor values while the measurement is running
% Second MATLAB required (if same computer used
% 1) Open new MATLAB (MATLAB2 from now on)
% 2) In MATLAB2, load current .mat-file (e.g. drag & drop to Command Window)
   % Variables should be seen now in Workspace
   % phiM_, ampM_, pO2M_, t_
% 3) Run following commands
% reduces NaNs away (if any)
phiM=phiM_(~isnan(phiM_));ampM=ampM_(~isnan(ampM_));
pO2M=pO2M_(~isnan(pO2M_));time=t_(~isnan(t_));
% plotting all in one subplot
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