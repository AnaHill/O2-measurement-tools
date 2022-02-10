% DynamicalParameters_MAIN
% Plotting dynamical parameters from the measurement
% 1) Load data and crop it to certain area
% 2) Calculate rise times, delay, and time constants
   % Required m-files
      % DynamicalParameters_Load.m -> load measurement data
        % how to get x and y -> DynamicalParameters_DATA_FastHypox_norm_phases.m
      % DynamicalParameters_QuestionToChooseArea.m asking to choose area from data
        % DynamicalParameters_ChooseArea(Data).m -> choosing area 
        % DynamicalParameters_CroppingMore.m -> cropping more or not 
      % DynamicalParameters_PlotParameters.m -> calculating dynamical parameters
clear, close all
%% Parameters
options.Resize = 'on';
options.Interpreter = 'tex';
options.Default = 'Yes';
%% Load data
DynamicalParameters_Load

%% Go through data, get x and y to Data
Using_Manual_kk = 1;
% Manual_kk_number  = 5;
DynamicalParameters_DATA_FastHypox_norm_phases
% kk=1;% x=vars(kk).time;
% name_file=vars(kk).name;% y = vars(kk).phase_n;
% disp(['Data: ',name_file]);% Data = [x,y];

% save x and y to Data
Data = [x,y];
%% Plotting data
disp('Plotting measurement data')
hfig1=figure('Name','Choosing values','units',...
   'normalized','outerposition',[0 0 1 1]);
plot(Data(:,1),Data(:,2)),
% title([loadpathname,loadfilename],'Interpreter', 'none'), 
title(['File: ',loadfilename,', Data: ',name_file],'Interpreter', 'none'), 

xlabel('Measurement time (s)')
% ylabel('data'), % TODO: oma nimi mikä y-akselilla

%% Choosing area (full or cropped)
DynamicalParameters_QuestionToChooseArea
    % DynamicalParameters_ChooseArea
    % DynamicalParameters_CroppingMore
%% Fitting, analyzing, and saving
% DataChosen is data to be analyzed
% Plotting parameters, saving figures and information (rise times etc)
DynamicalParameters_PlotParameters

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
   [DataChosen,meas_start_time, meas_end_time]=DynamicalParameters_ChooseArea(DataO2);
   IsAreaGood = questdlg(['Is the cropped area good?'], ...
   'Cropping   ','Yes', 'No, crop more from the cropped area',...
   'No, choose another region', options);
   DynamicalParameters_CroppingMore
   DynamicalParameters_PlotParameters % plot
   DynamicalParameters_Saving % saving
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
   DynamicalParameters_MAIN
else
   disp('Stopping'),
   DynamicalParameters_Saving % saving

end
