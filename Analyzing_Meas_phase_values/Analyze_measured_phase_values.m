%% load phase data to one variable
fold = ['S:\71301_MST-cells\OxygenMeasurement\MeasurementData\',...
    'MatiasFastHypoxiaMeas\O2MittaustenAnalysointia\'];
fileList = dir([fold,'Cropped_meas_data\*.mat']);
% get time and phases to vars 
vars = struct();

for kk=1:length(fileList)
%kk=1;
    %data_crop = load('S:\71301_MST-cells\OxygenMeasurement\MeasurementData\MatiasFastHypoxiaMeas\O2MittaustenAnalysointia\Cropped_meas_data\exp1down_FromDATA_EXP_1_500ul_H2O_2019_06_19__16_30_55.mat');
    data_crop = load([fileList(kk).folder,'\',fileList(kk).name]);
    vars(kk).name = data_crop.fname;
    vars(kk).time = data_crop.Data_O2(:,1);
    vars(kk).phase = data_crop.RawData_time_phase_O2(:,2);
    vars(kk).o2 = data_crop.Data_O2(:,2);
    % normalized phase
    vars(kk).phase_n = (vars(kk).phase - min(vars(kk).phase)) ./ ...
        (max(vars(kk).phase)- min(vars(kk).phase));
end

%% When collected data saved
fold = ['S:\71301_MST-cells\OxygenMeasurement\MeasurementData\',...
    'MatiasFastHypoxiaMeas\O2MittaustenAnalysointia\'];
load([fold,'Cropped_meas_phase_data\Data_phases.mat']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Choosing which data to plot
xlimit=[0 5e3]; xlimit=xlimit/60;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot all down data phases
title_text = 'All Down 19% to 1% O2';
chosen_dat = [1,2,5,7,9,11,12,14,16,18,20,21]; % xlimit=[0 5e3];
Plot_chosen_data_phases
Plot_chosen_data
%% Plot 800 ul down data
title_text = 'V=800ul Down 19% to 1% O2';
chosen_dat = [16,18]; % xlimit=[0 5e3];
Plot_chosen_data_phases
Plot_chosen_data

%% Plot 500 ul down data
title_text = 'V=500ul Down 19% to 1% O2';
chosen_dat = [5,7,9,11,12,14]; % xlimit=[0 5e3];
Plot_chosen_data_phases
Plot_chosen_data
%% Plot 400 ul down data
title_text = 'V=400ul Down 19% to 1% O2';
chosen_dat = [20,21]; % xlimit=[0 5e3];
Plot_chosen_data_phases

%% Plot down data: jokaista volume 1
title_text = 'Jokaista tilavuutta yksi mittaus: Down 19% to 1% O2';
chosen_dat = [20,5,18]; 
Plot_chosen_data_phases

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot all up data phases
xlimit=[0 2.4e3]/60;

title_text = 'All Up 1% to 19% O2';
dat_all = [1:length(vars)];
chosen_dat_all_down = [1,2,5,7,9,11,12,14,16,18,20,21]; 
chosen_dat = setdiff(dat_all,chosen_dat_all_down);
Plot_chosen_data_phases

%% Plot 800 ul up data
title_text = 'V=800ul up 1% to 19% O2';
chosen_dat = [16,18]+1;
Plot_chosen_data_phases

%% Plot 500 ul down data
title_text = 'V=500ul up 1% to 19% O2';
chosen_dat = [5,7,9,12,14]+1; 
Plot_chosen_data_phases

%% Plot 400 ul data
title_text = 'V=400ul up 1% to 19% O2';
chosen_dat = [20,21]+2; 
Plot_chosen_data_phases

%% Plot down data: jokaista volume 1
xlimit=[0 5e3]; xlimit=xlimit/60;
title_text = 'Jokaista tilavuutta yksi mittaus: Up 1% to 19% O2';
chosen_dat = [22,6,19]; Plot_chosen_data_phases







