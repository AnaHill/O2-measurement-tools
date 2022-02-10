% O2DynamicalParameters_Load: loading measurement file
disp('Plotting O2 data')
ise = evalin( 'base', 'exist(''RawData_time_phase_O2'',''var'') == 1' );
if ise
   clear RawData_time_phase_O2
end
% % % ise = evalin( 'base', 'exist(''phiM_'',''var'') == 1' );
% % % ise2 = evalin( 'base', 'exist(''ampM_'',''var'') == 1' );
% % % ise3 = evalin( 'base', 'exist(''pO2M_'',''var'') == 1' );
% % % if ise && ise2 && ise3
% % %    useFoundData = questdlg(['Required variables found; use them?'], ...
% % %    'Chosen ','Yes','No, load from file', 'Yes');
% % % end
% % % if ~(ise && ise2 && ise3) || strcmp(useFoundData ,'No, load from file')
% % % %    Loading data from a file 
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
   % Clear temporary variables
   clearvars  delimiter startRow formatSpec fileID dataArray ans;
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
% % % end
iseRaw = evalin( 'base', 'exist(''RawData_time_phase_O2'',''var'') == 1' );
if iseRaw
   t_=RawData_time_phase_O2(:,1)-RawData_time_phase_O2(1,1);
   phiM_ = RawData_time_phase_O2(:,2);
   ampM_ = rand(1,length(t_)); % no Amp was saved in cropped data
   DataToPlot{1}=RawData_time_phase_O2(:,2);
   DataToPlot{2}=zeros(1,length(ampM_));
   DataToPlot{3}=RawData_time_phase_O2(:,3);
   pO2M_ = RawData_time_phase_O2(:,3);
   time = t_; disp('RawData_time_phase_O2 found, using time vector from first column.')
end
disp(['%%%',10,'Read measurement file:'])  
disp([loadfilename])
disp('From:')  
disp([loadpathname,10,'%%%'])

Data_={phiM_, ampM_, pO2M_};time=t_;
if isrow(time)
   time=time';
end
colours={'r',[0 0.5 0],'b'};