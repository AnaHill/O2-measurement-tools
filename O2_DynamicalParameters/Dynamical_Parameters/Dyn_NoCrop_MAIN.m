% No Cropping, saving automatically

% clear, close all

%% Parameters
options.Resize = 'on';
options.Interpreter = 'tex';
options.Default = 'Yes';
%% Load data
% DynamicalParameters_Load
Is_file_loaded= evalin( 'base', 'exist(''loadfilename'',''var'')' );

if ~Is_file_loaded
    [loadfilename, loadpathname] = uigetfile({'*.mat;', ' .mat file';},...
       'Choose measurement file');
    load([loadpathname,loadfilename]);
    disp(['%%%',10,'Read measurement file:'])  
    disp([loadfilename])
    disp('From:')  
    disp([loadpathname,10,'%%%'])
    colours={'r',[0 0.5 0],'b'};
end
%% Go through data, get x and y to Data
% Using_Manual_kk = 1;
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

%% no cropping
DataChosen = Data;
meas_start_time = 0; 
meas_end_time = Data(end,1);
IsAreaGood = 'Yes';
%% Fitting, analyzing, and saving
% DataChosen is data to be analyzed
% Plotting parameters, saving figures and information (rise times etc)
DynamicalParameters_PlotParameters
disp('Stopping'),
%% saving all
if ~exist('savepath', 'var')
  savepath = uigetdir(pwd,'Saving folder');
  savepath(end+1)='\';
end
savepathname = savepath;
if exist('name_file','var')
  fname=['DynPar_',name_file];
else
  fname=[SaveDataname];
end
disp(['%%%',10,'Measurement file name: ',10,fname(1:end-4)])
disp(['Saving location: ',10,savepathname])
save([savepathname,fname],'Data_To_Analyzed','Datafiltered','timeVector','fname',...
  't10','t90','Rise_time_own','Rise_time','Delay_time','tStep','Time_Constant',...
  'Time_Constant2','X0','Y','StepInformation','Rise_time')   

saveas(hparam,[savepathname,fname(1:end-4)],'fig')
if length(fname) > 62
    fname2=fname(1:end-4);
    montako_pois = length(fname2)-62;
    if montako_pois > 0
        saveas(hparam,[savepathname,fname2(1:end-montako_pois)],'m')
    else
        saveas(hparam,[savepathname,fname2],'m')
    end
else
  saveas(hparam,[savepathname,fname(1:end-4)],'m')
end
saveas(hparam,[savepathname,fname(1:end-4)],'png')
disp('Fig saved to:')  
disp([savepathname,10,'Names: ',fname(1:end-4),10,'%%%%%%%%%%%%%%'])

