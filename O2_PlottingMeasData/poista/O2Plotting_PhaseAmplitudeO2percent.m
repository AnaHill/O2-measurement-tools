%% Plotting O2 data (typically) from a measurement file or from workspace
% PlottingO2MeasData
disp('Plotting O2 data from a file or from variables on the workspace')
% Checking if variables exists
ise = evalin( 'base', 'exist(''phiM_'',''var'') == 1' );
ise2 = evalin( 'base', 'exist(''ampM_'',''var'') == 1' );
ise3 = evalin( 'base', 'exist(''pO2M_'',''var'') == 1' );
if ise && ise2 && ise3 
   useFoundData = questdlg(['Required variables found; use them?'], ...
   'Chosen ','Yes','No, load from file', 'Yes');
else
   ise = evalin( 'base', 'exist(''phiM'',''var'') == 1' );
   ise2 = evalin( 'base', 'exist(''ampM'',''var'') == 1' );
   ise3 = evalin( 'base', 'exist(''pO2M'',''var'') == 1' );
   if ise && ise2 && ise3
      useFoundData = questdlg(['Required variables found; use them?'], ...
         'Chosen ','Yes','No, load from file', 'Yes');
   end
end
if ~(ise && ise2 && ise3) || strcmp(useFoundData ,'No, load from file')
%    Loading data from a file 
   [filename, pathname] = uigetfile({'*.mat;*.txt;', ' .mat or .txt file';},...
      'Pick a file');
   if filename(end-2:end) == 'txt'
      delimiter = '\t';startRow = 2;formatSpec = '%f%f%f%f%[^\n\r]';
      fileID = fopen([pathname,filename],'r');
      dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,...
         'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
      fclose(fileID);
      t_ = dataArray{:, 1}; %time = t_;
      phiM_ = dataArray{:, 2}; %phiM = phiM_;
      ampM_ = dataArray{:, 3}; %ampM = ampM_;
      pO2M_ = dataArray{:, 4}; %pO2M = pO2M_;
   else
      load([pathname,filename]);
   end
   disp('Read files from')  
   disp([pathname,filename])
end
% Clear temporary variables
clearvars  delimiter startRow formatSpec fileID dataArray ans;

% Check if phiM or phiM_ (and other) exist
ise = evalin( 'base', 'exist(''phiM_'',''var'') == 1' );
ise2 = evalin( 'base', 'exist(''ampM_'',''var'') == 1' );
ise3 = evalin( 'base', 'exist(''pO2M_'',''var'') == 1' );
if ise && ise2 && ise3
   DataToPlot={phiM_, ampM_, pO2M_};
   disp('phiM_, ampM_, and pO2M_ found.')
end
ise = evalin( 'base', 'exist(''phiM'',''var'') == 1' );
ise2 = evalin( 'base', 'exist(''ampM'',''var'') == 1' );
ise3 = evalin( 'base', 'exist(''pO2M'',''var'') == 1' );
if ise && ise2 && ise3
   DataToPlot={phiM, ampM, pO2M};
   disp('phiM, ampM, and pO2M found.')
end
ise4 = evalin( 'base', 'exist(''t_'',''var'') == 1' );
ise5 = evalin( 'base', 'exist(''t'',''var'') == 1' );
if ise4
   time=t_; disp('t_ found, using that as time vector.')
elseif ise5 
   time = t; disp('t found, using that as time vector.')
else
   time=0:length(DataToPlot{1})-1; 
   disp('No time vector found, creating with 0:length(DataToPlot{1})-1')
   disp('This is probably incorrect time vector!!!')
end

colours={'r',[0 0.5 0],'b'};
MaxTime_sec=max(time);
if MaxTime_sec < 300
   time_ = time; xlabeling = ('Time (sec)');
elseif (MaxTime_sec >= 300 && MaxTime_sec < 60*60*3)
   time_ = time/60; xlabeling = ('Time (min)');
else
   time_ = time/(60*60); xlabeling = ('Time (h)');
end
hsubplotting=figure('units','normalized','outerposition',[0 0 1 1]);
for pp = 1:3
   subplot(3,1,pp), plot(time_,DataToPlot{pp},'color',colours{pp}),grid on;
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