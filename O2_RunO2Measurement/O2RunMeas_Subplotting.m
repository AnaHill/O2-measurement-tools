% O2RunMeas_subplotting.m
% To subplot O2 measurement: during and after measurement
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
hsubplotting=figure('Name','Subplotting all measurement data');
disp('Subplotting')
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