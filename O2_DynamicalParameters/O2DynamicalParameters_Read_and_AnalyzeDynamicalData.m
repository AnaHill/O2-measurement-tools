%% O2DynamicalParameters_Read_and_AnalyzeDynamicalData
   % Read and analyze data from: O2DynamicalParameters_MAIN
clear,clc,
%% Read folder where .mat files are
files_folder = [uigetdir(pwd,'Pick a Directory of measurement files'),'\'];
disp(['Folder: ',files_folder])
listdir = dir(files_folder);
filename=[];
for ii = 1 : length(listdir)
    [~,name, ext] = fileparts(listdir(ii).name);
    if strcmp(ext, '.mat')
        filename{end+1,1} = fullfile(listdir(ii).name);
    end
end
if isempty(filename)
    error('No files found!')
end

disp([10,'%%%%%%%%%%%%%%%',10,'List of .mat files found:'])
% https://se.mathworks.com/help/matlab/ref/disp.html
for ii = 1 : length(filename)
    fprintf('Files#%d) %s\n',ii, filename{ii})   
end
filenames=[];ii=1; temp=[num2str(ii),') ',filename{ii}]; filenames=[filenames,temp];
if length(filename) > 1
   for ii = 2 : length(filename)
       temp=[' %%% ',num2str(ii),')  ',filename{ii}];
       filenames=[filenames,temp];
   end
end
%% If necessary, exclude some data 
options.Resize = 'on';
options.Interpreter = 'tex';
options.Default = 'Yes';
wantToUseAllData = questdlg(['Want to use all data (see list on MATLAB workspace)?'], ...
   'Excluding data','Yes', 'No, exclude some data',options);

% [SELECTION,OK] = listdlg('ListString',S) % creates a modal dialog box
% d = dir;str = {d.name};
if ~strcmp(wantToUseAllData,'Yes') % if excluding some data
   % Asking which data are used
   [s,v] = listdlg('PromptString','Select data which you want:',...
                'SelectionMode','multiple','ListSize', [500 300],...
                'ListString',filename);
    if v == 1 % ok pressed
       wanted_file_names = filename(s);
    else % chancel pressed or none chose
       return
    end
else % if using all data
   wanted_file_names = filename;
end

if isempty(wanted_file_names)
   error('No files')
end
%% Load all data to variable Full_Data 
kk=1;
for kk  = 1:length(wanted_file_names)
   Full_Data{kk} = load([files_folder, wanted_file_names{kk}]);
end

%% Collect most important information from  Full_Data to one table
TimeParameters = {'Rise_time';'tStep';'Time_Constant';'Delay_time'};
Comments = {'Filename of the measurement';...
   'Rise time = time between 10% and 90% of the final value (inital reduced)';...
   ['Step response = time it takes output 0%->63.2% (step up) or ',...
   '100%->36.8% (step down). Delay is already reduced (basically 0.1% -> 63.2%)'];...
   'tau = time constant from the fitted 1st order ';...
   ['Delay = time it takes that output starts to change ',...
   '(basically, when output has been changed 0.1% from the initial value)']};
%Info_for_table = table(Comments, 'RowNames', TimeParameters(:));
T= [];
for kk  = 1:length(wanted_file_names)
   T = [T; table(cellstr(wanted_file_names{kk}(1:10)),Full_Data{kk}.Rise_time,...
      Full_Data{kk}.tStep,Full_Data{kk}.Time_Constant2,...
      Full_Data{kk}.Delay_time,'VariableNames',...
      {'Filename','Rise_Time','Step_Resp','tau','Delay'})];
   if kk <= length(Comments)
      T.Properties.VariableDescriptions{kk} = Comments{kk};
   end
end

%% regexp käyttäen nimestä etsitään _ jonka perusteella up or down
strName = string(wanted_file_names);
pat = '\_';
alku=cell2mat(regexp(strName, pat,'once')); % finding first '_' -> Step info before

% strName = string(wanted_file_names);
patVol = 'ml';
vol_info_point=regexp(strName, patVol,'once');

for kk  = 1:length(wanted_file_names)
   StepDirection{kk,1} = wanted_file_names{kk}(1:alku(kk)-1); % step direction
   if ~isempty(vol_info_point{kk})
      vol_temp{kk,1} = (wanted_file_names{kk}...
         (vol_info_point{kk}-3:vol_info_point{kk}-1));
      vol_temp{kk,1} = strrep(vol_temp{kk,1}, ',', '.');
      Volume_(kk,1) = str2double(vol_temp{kk,1});
   else
      Volume_(kk,1) = 0;
   end
   FullNam_temp{kk,1} = [T.Filename{kk}, ': Vol: ',num2str(Volume_(kk)), ' ml' ];
end
T.StepDirection = StepDirection;
T.LiquidVolume = Volume_;
T.Fullname = FullNam_temp;

% Rise times, both
Trise= [];
for kk  = 1:length(wanted_file_names)
   Trise = [Trise; table(cellstr(wanted_file_names{kk}(1:10)),Full_Data{kk}.Rise_time,...
      Full_Data{kk}.Rise_time_own,'VariableNames',...
      {'Filename','Rise_Time','Rise_Time_own'})];
end
Trise.LiquidVolume = T.LiquidVolume;
% Trise.NiceName = zeros(length(wanted_file_names)); 
% Trise.Properties.VariableNames{end+1} = 'NiceName'
for kk = 1:length(wanted_file_names)
   Trise.NiceName{kk} = [Trise.Filename{kk}, ', Vol: ',...
      num2str(Trise.LiquidVolume(kk)),'ml'];
end

figure('units','normalized','outerposition',[0 0 1 1])
subplot(211),bar([Trise.Rise_Time Trise.Rise_Time_own])
xticklabels([Trise.NiceName]);
ax = gca; ax.XTick = [1:length(Trise.Filename)]; 
ax.XTickLabelRotation = 90; xlim([0 height(Trise)+1])
subplot(212),bar([Trise.Rise_Time./Trise.Rise_Time_own]*100), ylim([90 110])
xticklabels([Trise.NiceName]);
ax = gca; ax.XTick = [1:length(Trise.Filename)]; 
ax.XTickLabelRotation = 90; xlim([0 height(Trise)+1])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting
figure('units','normalized','outerposition',[0 0 1 1])
%subplot(2,2,1), bar(T.Rise_Time)
T1b = sortrows(T,{'StepDirection','LiquidVolume'},{'ascend','ascend'});
% Plotted_variables={T.Rise_Time, T.Step_Resp,T.tau,T.Delay};
Plotted_variables={T1b.Rise_Time, T1b.Step_Resp,T1b.tau,T1b.Delay};

for kk = 1:4
   subplot(2,2,kk), bar(Plotted_variables{kk})
   title(T.Properties.VariableNames{kk+1},'interpreter','none')
%    xticklabels(T.Filename);
   xticklabels(T1b.Fullname);
   ax = gca; 
   ax.XTick = [1:length(T.Filename)]; ax.XTickLabelRotation = 90;
   xlim([0 height(T)+1])
end
%% Plotting tau and Rise times 
T2=table;
for kk = [8,6,7,4,2]
   T2.(T.Properties.VariableNames{kk})=T.(T.Properties.VariableNames{kk});
end
t2b = sortrows(T2,{'StepDirection','LiquidVolume'},{'ascend','ascend'});
figure('units','normalized','outerposition',[0 0 1 1])
subplot(2,2,1), bar(t2b.tau),  
xticklabels(t2b.Fullname);ax = gca; 
ax.XTick = [1:length(t2b.Fullname)]; ax.XTickLabelRotation = 90;
xlim([0 height(t2b)+1])
title(t2b.Properties.VariableNames{4},'interpreter','none')
subplot(2,2,2), bar(t2b.Rise_Time),  
xticklabels(t2b.Fullname);ax = gca; 
ax.XTick = [1:length(t2b.Fullname)]; ax.XTickLabelRotation = 90;
title(t2b.Properties.VariableNames{5},'interpreter','none')
xlim([0 height(t2b)+1])
% 
plotted = strcmp(t2b.StepDirection,'Down');
subplot(4,2,5), plot(t2b.LiquidVolume(plotted), t2b.tau(plotted),'*'), 
title(['\tau for Step ',t2b.StepDirection{find(plotted == 1,1)}])
plotted = strcmp(t2b.StepDirection,'Up');
subplot(4,2,7), plot(t2b.LiquidVolume(plotted), t2b.tau(plotted),'*'),  
title(['\tau for Step ',t2b.StepDirection{find(plotted == 1,1)}])

plotted = strcmp(t2b.StepDirection,'Down');
subplot(4,2,6), plot(t2b.LiquidVolume(plotted), t2b.tau(plotted),'*'), 
title(['Step Response Rise Time: ',t2b.StepDirection{find(plotted == 1,1)}])
plotted = strcmp(t2b.StepDirection,'Up');
subplot(4,2,8), plot(t2b.LiquidVolume(plotted), t2b.tau(plotted),'*'),  
title(['Step Response Rise Time: ',t2b.StepDirection{find(plotted == 1,1)}])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saving %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for kk = 1:length(Full_Data)
   Meas_Data{kk,1} = Trise.NiceName{kk};
	Meas_Data{kk,2} = Trise.LiquidVolume(kk);
   Meas_Data{kk,3} = Full_Data{kk}.Data_O2;   
end


