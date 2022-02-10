%% % O2Plotting_ConvertRawPhaseDataToConcentration: 
% Loading raw phase data from a file, convert it to oxygen percent with wanted
% calibration values, and then plot (all) data
   % Required files:
      % SternVolmerC.m: for converting phase -> O2%
      % function [ pO2 ] = SternVolmerC(Ksv,phi0,-Measured_Phase,phiC)
%%
% I) Calibration 
  % Ask calibration values 
  % Read file or manually
% II) Loading measurement file(s)
   % Ask measurement: folder or file
      % Folder: read all (*.mat) files
      % File: read file
   % Load data
% III) Plotting data
clear,pp=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% I) Calibration 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DefaultCalibs=[0.12999545, 50.29295, 16.04606150]; % Ksv, phi0, caldevi
% ask file / set manually
choice_calibration = questdlg(['Would you like to read calibration file',...
   ' or set calibration parameters manually?'], ...
   'Calibration',  'Read file', 'Manually', 'Manually');
% Handle response
switch choice_calibration
    case 'Manually'
      prompt = {'Ksv:','phi0:','caldevi:'};
      dlg_title = ['Set calibration values'];
      size_wind = [1 50; 1 50; 1 50]; % Windows size
      defaultans = {num2str(DefaultCalibs(1)),num2str(DefaultCalibs(2)),...
         num2str(DefaultCalibs(3))};
      options.Resize = 'on';
      answer = inputdlg(prompt,dlg_title,size_wind, defaultans,options);
      Ksv=str2num(answer{1}); phi0=str2num(answer{2}); caldevi=str2num(answer{3});
      disp(['Manually chosen calibration parameters:'])
      disp(['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)])   
    case 'Read file'
      [filename_calib, pathname_calib] = uigetfile({'*.mat', ' .mat  file';},...
         'Pick a calibration file');
      load([pathname_calib,filename_calib]);
end

iseA1 = evalin( 'base', 'exist(''Ksv'',''var'') == 1' );
iseA2 = evalin( 'base', 'exist(''phi0'',''var'') == 1' );
iseA3 = evalin( 'base', 'exist(''caldevi'',''var'') == 1' );
if ~(iseA1 && iseA2 && iseA3)
   Calib_Info = 'Calibration parameters not found!!!! Using (default) parameters: ';
   Ksv=DefaultCalibs(1); phi0=DefaultCalibs(2); caldevi=DefaultCalibs(3);
   errorStruct_calib.message = 'Calibration variables not found.';
   errorStruct_calib.identifier = 'MyFunction:calibrationfileNotFound';
   warndlg(['Suitable calibration variables not found',10,...
      'Using default calibration parameters: ','Ksv: ',num2str(Ksv),', phi0: ',...
      num2str(phi0),', caldevi: ',num2str(caldevi),10,...
      'Press any keyboard key here to continue'],'Calibration Error'); 
   disp('Press any keyboard key here to continue')
   pause(),disp('Key pressed, continuing')
   % error(errorStruct_calib)
else
   Calib_Info = 'Used calibration parameters: ';
end
disp(Calib_Info)
disp( ['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
   ', caldevi: ',num2str(caldevi)]); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% II) Measurement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ask folder or file of measurement data
choice_measurement = questdlg(['Would you like to read measurement file',...
   ' or folder (including all measurement .mat files on folder)?'], ...
   'Measurement', 'Read file', 'Read folder', 'Read file');
% Handle response
switch choice_measurement
   case 'Read file'
      [filename{1}, meas_folder] = uigetfile({'*.mat', ' .mat  file';},...
         'Pick a measurement file');
      MeasDATA{pp} = load([meas_folder,filename{1}]);
   case 'Read folder' % Choose folder with data files
      meas_folder = [uigetdir(pwd,'Pick a Directory of data'),'\'];
      disp(['Folder: ',meas_folder])
      listdir = dir(meas_folder);
      filename=[];
      for ii = 1 : length(listdir)
          [~,name, ext] = fileparts(listdir(ii).name);
          if strcmp(ext, '.mat')
              filename{end+1,1} = fullfile(listdir(ii).name);
          end
      end
      if isempty(filename)
         errorStruct_calib.message = 'No data (*.mat) files found!';
         errorStruct_calib.identifier = 'MyFunction:datafileNotFound';
         errordlg(['No data (*.mat) files found!'],'Measurement Data Error'); 
         error('No data (*.mat) files found!')
      end
      disp([10,'%%%%%%%%%%%%%%%',10,'List of data files found:'])
      % https://se.mathworks.com/help/matlab/ref/disp.html
      for ii = 1 : length(filename)
          fprintf('Data#%d) %s\n',ii, filename{ii}) 
          MeasDATA{ii} = load([meas_folder,filename{ii}]);    
      end
      datanames=[];ii=1; temp=[num2str(ii),') ',filename{ii}]; 
      datanames=[datanames,temp];
      if length(filename) > 1
         for ii = 2 : length(filename)
             temp=[' %%% ',num2str(ii),')  ',filename{ii}];
             datanames=[datanames,temp];
         end
      end
end
for ii = 1 : length(filename)
   filenames_without_mat{ii} = filename{ii}(1:end-4);
end
%%  Measurement:  check data 
for pp = 1:length(MeasDATA)
%    iseRawData_time_phase = evalin( 'base',...
%       'exist(''Dat.RawData_time_phase_O2'',''var'') == 1' );
   ispresent_RawData_time_phase = isfield(MeasDATA{pp},'RawData_time_phase_O2');
   if ispresent_RawData_time_phase
      O2converted = SternVolmerC(Ksv,phi0,-MeasDATA{pp}.RawData_time_phase_O2(:,2),caldevi);
      if isrow(O2converted)
         O2converted = O2converted';
      end
      ispresent_Data_O2 = isfield(MeasDATA{pp},'Data_O2');
      if ispresent_Data_O2
         O2_data{pp} = [MeasDATA{pp}.Data_O2(:,1), O2converted];     
      else
         O2_data{pp} = [MeasDATA{pp}.RawData_time_phase_O2(:,1), O2converted];     
      end
   else
      ispresent_phiM_ = isfield(MeasDATA{pp},'phiM_');
      if ispresent_phiM_
         O2converted = SternVolmerC(Ksv,phi0,-MeasDATA{pp}.phiM_,caldevi);
         if isrow(O2converted)
            O2converted = O2converted';
         end
         ispresent_t_ = isfield(MeasDATA{pp},'t_');
         if ispresent_t_
            if isrow(MeasDATA{pp}.t_)
                  MeasDATA{pp}.t_ = MeasDATA{pp}.t_';
            end
            O2_data{pp} = [MeasDATA{pp}.t_, O2converted];
%          else
%             ispresent_t = isfield(MeasDATA{pp},'t');
%             if ispresent_t
%                O2_data{pp} = [MeasDATA{pp}.t_, O2converted];
%             end
         end              
      else
         ispresent_phiM = isfield(MeasDATA{pp},'phiM');
         if ispresent_phiM
            if isrow(MeasDATA{pp}.phiM)
               MeasDATA{pp}.phiM = MeasDATA{pp}.phiM';
            end
            O2converted = SternVolmerC(Ksv,phi0,-MeasDATA{pp}.phiM,caldevi);
            if isrow(O2converted)
               O2converted = O2converted';
            end
            ispresent_t = isfield(MeasDATA{pp},'t');
            if ispresent_t
               if isrow(MeasDATA{pp}.t)
                  MeasDATA{pp}.t = MeasDATA{pp}.t';
               end
               O2_data{pp} = [MeasDATA{pp}.t, O2converted];
%             else
%                ispresent_t = isfield(MeasDATA{pp},'t');
%                if ispresent_t
%                   O2_data{pp} = [MeasDATA{pp}.t, O2converted];
%                end
             end
         else
            errorStruct.message = 'Suitable measurement variables not found.';
            errorStruct.identifier = 'MyFunction:measurementfileNotFound';
            errordlg('Suitable measurement file(s)/variable(s) not found','File Error'); 
            error(errorStruct)
         end
      end
      
   end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% III) Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for pp = 1:length(O2_data)
   MaxTimes_sec(pp)=max(O2_data{pp}(:,1));
   MinO2s(pp)=min(O2_data{pp}(:,2));
	MaxO2s(pp)=max(O2_data{pp}(:,2));

end
MaxTime_sec = max(MaxTimes_sec);
if MaxTime_sec < 300
   xlabeling = ('Time (sec)'); maximum_x_level = MaxTime_sec;
elseif (MaxTime_sec >= 300 && MaxTime_sec < 60*60*3)
   xlabeling = ('Time (min)'); maximum_x_level = MaxTime_sec/60;
else
   xlabeling = ('Time (h)'); maximum_x_level = MaxTime_sec/(60*60);
end


MinO2=min(MinO2s); MaxO2=max(MaxO2s);
figure('Outerposition', [672   456   974   726])

hold all
for pp = 1:length(O2_data)
   if MaxTime_sec < 300 % seconds
      Meas_Timing = O2_data{pp}(:,1);
   elseif (MaxTime_sec >= 300 && MaxTime_sec < 60*60*3) % minutes
      Meas_Timing = O2_data{pp}(:,1)/60;
   else % hours
      Meas_Timing = O2_data{pp}(:,1)/(60*60);
   end
   plot(Meas_Timing, O2_data{pp}(:,2)) 
end
xlabel(xlabeling)
ylabel('O_2 (%)')
minimum_y_level = 0;
maximum_y_level = 22;
if MinO2 < 0
   minimum_y_level = 3*MinO2;
end
if MaxO2 > 25
   maximum_y_level = 25;
end
axis([0 maximum_x_level minimum_y_level maximum_y_level])
% axis('auto')
title(['Data from: ',10, meas_folder,10,Calib_Info,...
   'Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),', caldevi: ',...
   num2str(caldevi)],'interpreter','none')
hleg=legend(filenames_without_mat,'interpreter','none');
hleg.Location='best';

%% Getting initial and end values
HowManyValuesToCount = 20; % if 100 --> 100 first and last are used to calculate
% mean inital and end values
Mean_initial_end = zeros(length(O2_data),2);
for kk = 1:length(O2_data)
   if length(O2_data{kk}) > HowManyValuesToCount
      Mean_initial_end(kk,:) = [mean(O2_data{kk}(1:HowManyValuesToCount,2)),...
         mean(O2_data{kk}(end-HowManyValuesToCount+1:end,2))];
   else
      Mean_initial_end(kk,:) = [mean(O2_data{kk}(1:length(O2_data{kk})/3,2)),...
         mean(O2_data{kk}(end-length(O2_data{kk})/3:end,2))];
   end
end
T_mean_values=table(filenames_without_mat',Mean_initial_end(:,1),...
   Mean_initial_end(:,2),'VariableNames',{'Filename' 'Initial' 'End'})
disp(Calib_Info)
disp( ['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
   ', caldevi: ',num2str(caldevi)]); 
