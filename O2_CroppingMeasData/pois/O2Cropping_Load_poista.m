% O2Cropping_Load: loading measurement file
disp('Plotting O2 data')
ise = evalin( 'base', 'exist(''phiM_'',''var'') == 1' );
ise2 = evalin( 'base', 'exist(''ampM_'',''var'') == 1' );
ise3 = evalin( 'base', 'exist(''pO2M_'',''var'') == 1' );
if ise && ise2 && ise3
   useFoundData = questdlg(['Required variables found; use them?'], ...
   'Chosen ','Yes','No, load from file', 'Yes');
end
if ~(ise && ise2 && ise3) || strcmp(useFoundData ,'No, load from file')
%    Loading data from a file 
   [loadfilename, loadpathname] = uigetfile({'*.mat;*.txt;', ' .mat or .txt file';},...
      'Choose measurement file');
   if loadfilename(end-2:end) == 'txt'
      delimiter = '\t';startRow = 2;formatSpec = '%f%f%f%f%[^\n\r]';
      fileID = fopen([loadpathname,loadfilename],'r');
      dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,...
         'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
      fclose(fileID);
      t_ = dataArray{:, 1}; %time = t_;
      phiM_ = dataArray{:, 2}; %phiM = phiM_;
      ampM_ = dataArray{:, 3}; %ampM = ampM_;
      pO2M_ = dataArray{:, 4}; %pO2M = pO2M_;
   else
      load([loadpathname,loadfilename]);
   end
   iseA = evalin( 'base', 'exist(''phiM_'',''var'') == 1' );
   iseA2 = evalin( 'base', 'exist(''ampM_'',''var'') == 1' );
   iseA3 = evalin( 'base', 'exist(''pO2M_'',''var'') == 1' );
   iseA4 = evalin( 'base', 'exist(''t_'',''var'') == 1' );
   if ~(iseA && iseA2 && iseA3 && iseA4)
      iseB = evalin( 'base', 'exist(''phiM'',''var'') == 1' );
      iseB2 = evalin( 'base', 'exist(''ampM'',''var'') == 1' );
      iseB3 = evalin( 'base', 'exist(''pO2M'',''var'') == 1' );
      iseB4 = evalin( 'base', 'exist(''t'',''var'') == 1' );
      if iseB
         phiM_ = phiM;
      end
      if iseB2
         ampM_ = ampM;
      end
      if iseB3
         pO2M_ = pO2M;
      end
      if iseB4
         t_ = t;
      end
   end
end
% Clear temporary variables
clearvars  delimiter startRow formatSpec fileID dataArray ans;
disp(['%%%',10,'Read measurement file:'])  
disp([loadfilename])
disp('From:')  
disp([loadpathname,10,'%%%'])

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
hsubplotting=figure();
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