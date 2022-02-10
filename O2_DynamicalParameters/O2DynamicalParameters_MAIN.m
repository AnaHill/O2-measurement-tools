% O2DynamicalParameters_MAIN
% Plotting dynamical parameters from the measurement
% 1) Load data and crop it to certain area
% 2) Calculate rise times, delay, and time constants
   % Required m-files
      % O2DynamicalParameters_Load.m -> load measurement data
      % O2DynamicalParameters_ChooseArea(DataO2).m -> choosing area from data
      % O2DynamicalParameters_CroppingMore.m --> cropping more or not from the
      % chosen area
      % O2DynamicalParameters_PlotParameters.m -> calculating dynamical parameters
% clear, close all
iseBack = evalin( 'base', 'exist(''BackToMainFigure'',''var'') == 1' );
if iseBack
   clear, close all, BackToMainFigure = 1;
else
   clear, close all
end
%% Loading and plotting data
options.Resize = 'on';
options.Interpreter = 'tex';
options.Default = 'Yes';

O2DynamicalParameters_Load % .m
pp=3;
disp('Plotting measurement data (O2%)')
hfig1=figure('Name','Choosing values','units',...
   'normalized','outerposition',[0 0 1 1]);
plot(t_,Data_{pp}),%xlim([1 length(Data_{pp})])
title([loadpathname,loadfilename],'Interpreter', 'none'), 
xlabel('Measurement time (s)')
ylabel('Measured O2 (%)'), 
if isrow(t_)
   t_=t_';
end
if isrow(Data_{pp})
   Data_{pp}=Data_{pp}';
end
DataO2=[t_ Data_{pp}];
%% Choosing area (or not)
CroppingMethodChosed = 0; % 0 => no cropping, asking next
wantToCropORG = questdlg(['Want to crop the data?'], ...
   'Cropping ','Yes, with a mouse', 'Yes, manually','No','Yes, with a mouse');
if ~strcmp(wantToCropORG,'No')
   if strcmp(wantToCropORG,'Yes, with a mouse')
      CroppingMethodChosed=2;
   else % set manually
      CroppingMethodChosed=1;
   end
   [DataChosen, meas_start_time, meas_end_time] = ...
      O2DynamicalParameters_ChooseArea(DataO2, CroppingMethodChosed);
   % Asking is the cropped area good
   wantToCrop = questdlg(['Is the cropped area good?'], ...
   'Cropping   ','Yes', 'No, crop more from the cropped area',...
   'No, choose another region', options);
else % no cropping
   DataChosen = DataO2;
   meas_start_time = 0; 
   meas_end_time = DataO2(end,1);
   wantToCrop = 'Yes';
end
% Cropping more if necessary
O2DynamicalParameters_CroppingMore

%% Calculating dynamical parameters
% Plotting parameters, saving figures and information (rise times etc)
O2DynamicalParameters_PlotParameters

%% Asking to choose more data  different region from the loaded data
options2.Resize = 'on';
options2.Interpreter = 'tex';
options2.Default = 'No, stop.';
wantToChooseMore = questdlg(['Want to choose another data?'], ...
   'Choosing More','Yes, another part from this data.','Yes, another data.',...
   'No, stop.',options2);
while strcmp(wantToChooseMore ,'Yes, another part from this data.') 
   fighandles = findall(allchild(0), 'type', 'figure');
   if length(fighandles) > 1
      close(figure(fighandles(1)))
   end
   [DataChosen,meas_start_time, meas_end_time]=O2DynamicalParameters_ChooseArea(DataO2);
   wantToCrop= questdlg(['Is the cropped area good?'], ...
   'Cropping   ','Yes', 'No, crop more from the cropped area',...
   'No, choose another region', options);
   O2DynamicalParameters_CroppingMore
   O2DynamicalParameters_PlotParameters
   wantToChooseMore = questdlg(['Want to choose another data?'], ...
      'Choosing More','Yes, another part from this data.','Yes, another data.',...
      'No, stop.',options2);
end
if strcmp(wantToChooseMore ,'Yes, another data.')
   disp(['%%%',10,'Stopped with current measurement data, choosing another data'])
   fighandles = findall(allchild(0), 'type', 'figure');
   for kk=1:length(fighandles)
      close(figure(fighandles(kk)))
   end
   O2DynamicalParameters_MAIN
else
   disp('Stopping'),
%    if exist('hfig1','var')
%       close(hfig1)
%    end
end
% If ran from the main figure --> returning
iseBack = evalin( 'base', 'exist(''BackToMainFigure'',''var'') == 1' );
if iseBack
%    if exist('hfig1','var')
%       close(hfig1)
%    end
   cd .. 
   O2_MAIN_ChoosingWhatToDo
end



