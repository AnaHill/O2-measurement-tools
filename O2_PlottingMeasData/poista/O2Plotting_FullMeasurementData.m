%% Plotting different full measurement O2 data
clear, close all, 
%% Plot Phase, Amp, and O2% in a subplot figure
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
   time_ = time; xlabeling = ('Time (sec)'); time_unit=1;
elseif (MaxTime_sec >= 300 && MaxTime_sec < 60*60*3)
   time_ = time/60; xlabeling = ('Time (min)');time_unit=2;
else
   time_ = time/(60*60); xlabeling = ('Time (h)'); time_unit=3;
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
%% Plotting only O2
legendas=[];
plot_fig = 1;
% % Checking if variables exists
% ise = evalin( 'base', 'exist(''phiM_'',''var'') == 1' );
% ise2 = evalin( 'base', 'exist(''ampM_'',''var'') == 1' );
% ise3 = evalin( 'base', 'exist(''pO2M_'',''var'') == 1' );
% if ise && ise2 && ise3 
%    useFoundData = questdlg(['Required variables found; use them?'], ...
%    'Chosen ','Yes','No, load from file', 'Yes');
% else
%    ise = evalin( 'base', 'exist(''phiM'',''var'') == 1' );
%    ise2 = evalin( 'base', 'exist(''ampM'',''var'') == 1' );
%    ise3 = evalin( 'base', 'exist(''pO2M'',''var'') == 1' );
%    if ise && ise2 && ise3
%       useFoundData = questdlg(['Required variables found; use them?'], ...
%          'Chosen ','Yes','No, load from file', 'Yes');
%    end
% end
% if ~(ise && ise2 && ise3) || strcmp(useFoundData ,'No, load from file')
% %    Loading data from a file 
%    [filename, pathname] = uigetfile({'*.mat;*.txt;', ' .mat or .txt file';},...
%       'Pick a file');
%    if filename(end-2:end) == 'txt'
%       delimiter = '\t';startRow = 2;formatSpec = '%f%f%f%f%[^\n\r]';
%       fileID = fopen([pathname,loadfilename],'r');
%       dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,...
%          'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
%       fclose(fileID);
%       t_ = dataArray{:, 1}; %time = t_;
%       phiM_ = dataArray{:, 2}; %phiM = phiM_;
%       ampM_ = dataArray{:, 3}; %ampM = ampM_;
%       pO2M_ = dataArray{:, 4}; %pO2M = pO2M_;
%    else
%       load([pathname,loadfilename]);
%    end
%    disp('Read files from')  
%    disp([pathname,loadfilename])
% end
% iseA = evalin( 'base', 'exist(''phiM_'',''var'') == 1' );
% iseA2 = evalin( 'base', 'exist(''ampM_'',''var'') == 1' );
% iseA3 = evalin( 'base', 'exist(''pO2M_'',''var'') == 1' );
% iseA4 = evalin( 'base', 'exist(''t_'',''var'') == 1' );
% if ~(iseA && iseA2 && iseA3 && iseA4)
%    iseB = evalin( 'base', 'exist(''phiM'',''var'') == 1' );
%    iseB2 = evalin( 'base', 'exist(''ampM'',''var'') == 1' );
%    iseB3 = evalin( 'base', 'exist(''pO2M'',''var'') == 1' );
%    iseB4 = evalin( 'base', 'exist(''t'',''var'') == 1' );
%    if iseB
%       phiM_ = phiM;
%    end
%    if iseB2
%       ampM_ = ampM;
%    end
%    if iseB3
%       pO2M_ = pO2M;
%    end
%    if iseB4
%       t_ = t;
%    end
% end
% Clear temporary variables
disp(['%%%',10,'Read measurement file:'])  
disp([filename]),disp('From:'),disp([pathname,10,'%%%'])
% time=t_; %colours={'r',[0 0.5 0],'b'};
% MaxTime_sec=max(time);
% if MaxTime_sec < 300
%    time_ = time; xlabeling = ('Time (sec)');time_unit=1;
% elseif (MaxTime_sec >= 300 && MaxTime_sec < 60*60*3)
%    time_ = time/60; xlabeling = ('Time (min)');time_unit=2;
% else
%    time_ = time/(60*60); xlabeling = ('Time (h)');time_unit=3;
% end
figure('units','normalized','outerposition',[0 0 1 1]);
plot(time_,DataToPlot{3}), hold all, xlabel(xlabeling),ylabel('O_2 (%)')

iseA1 = evalin( 'base', 'exist(''Ksv'',''var'') == 1' );
iseA2 = evalin( 'base', 'exist(''phi0'',''var'') == 1' );
iseA3 = evalin( 'base', 'exist(''caldevi'',''var'') == 1' );

legendas{1} = [filename(1:end-4)];
NextMeasurement = questdlg(['Plot another measurement'], ...
         'Plotting','Yes','No, stop', 'Yes');
if strcmp(NextMeasurement ,'Yes')
   [loadfilename, loadpathname] = uigetfile({'*.mat', ' .mat file';},...
   'Choose measurement file');
   load([loadpathname,loadfilename]);
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
else
   plot_fig = 0;
end
% kk=1;  
while plot_fig == 1
   legendas{end+1} = [loadfilename(1:end-4)];
   time=t_; %colours={'r',[0 0.5 0],'b'};
   MaxTime_sec=max(time);
   switch time_unit
      case 1
         time_ = time;   
      case 2
         time_ = time/60;
      case 3 % hours
         time_ = time/(60*60);
   end
   plot(time_,pO2M_), xlabel(xlabeling),ylabel('O_2 (%)')
   NextMeasurement = questdlg(['Plot another measurement'], ...
         'Plotting','Yes','No, stop', 'Yes');
   if strcmp(NextMeasurement ,'Yes')
      [loadfilename, loadpathname] = uigetfile({'*.mat', ' .mat file';},...
         'Choose measurement file');
      load([loadpathname,loadfilename]);
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
   else
      plot_fig = 0;
   end
end
legend(legendas,'Location','best','Interpreter','none')

% % while plot_fig == 1
% %    if kk == 1
% %       ise = evalin( 'base', 'exist(''fname'',''var'') == 1' );
% %       if ise
% %          idx = strfind(fname,'_FromDATA');
% %          if isempty(idx)
% %             legendas{end+1} = fname;
% %          else
% %             legendas{end+1} = fname(1:idx-1);
% %          end
% %       else % if no fname variable -> ask name
% %          prompt = {'Name'};
% %          dlg_title = 'Insert name';
% %          num_lines = 1;   defaultans = {''};
% %          answer = inputdlg(prompt,dlg_title,num_lines,defaultans); 
% %          legendas{kk}=(answer{1});
% %       end
% %       isefig = evalin( 'base', 'exist(''O2meas_figs'',''var'') == 1' );
% %       if ~isefig
% %          O2meas_figs = figure('units','normalized','outerposition',[0.2 0.4 0.6 0.6]);
% %          hold all
% %       end
% %       hO2{kk}=plot(Data_O2(:,1), Data_O2(:,2)); 
% %    end
% %    kk=kk+1;
% %    % ask more
% %    NextMeasurement = questdlg(['Change calibration values'], ...
% %       'Changing calibration','Yes','No, stop', 'Yes');
% %    if strcmp(NextMeasurement ,'Yes')
% %       prompt = {'Ksv:','phi0:','caldevi:'};
% %       dlg_title = 'Set calibration values';
% %       num_lines = 1;
% %       defaultans = {'0.185','53','18'};
% %       answer = inputdlg(prompt,dlg_title,num_lines,defaultans); 
% %       Ksv=str2num(answer{1}); phi0=str2num(answer{2}); caldevi=str2num(answer{3});
% %       disp(['Manually chosen calibration parameters:'])
% %       disp(['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
% %       ', caldevi: ',num2str(caldevi)])   
% % % %       % plotting with new calibration files
% % % %       
% % % %       pO2 = SternVolmerC(Ksv,phi0,-phi,caldevi);
% % % %       phi=mean(angle(Measurement-StopCal)/pi*180);
% %       time=RawData_time_phase_O2(:,1)-RawData_time_phase_O2(1,1);
% %       phi = RawData_time_phase_O2(:,2);
% %       pO2 = SternVolmerC(Ksv,phi0,-phi,caldevi);
% %       plot(time, pO2)
% %    else
% %       plot_fig = 0;
% %    end
% % end
% % legend(legendas,'Location','best','Interpreter','none')
% % %clear O2meas_figs
%%
