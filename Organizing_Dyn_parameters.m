%% Analyysit O2 saaduista dynaamisista parametreista
% 1) Get data folder and Load data
% 2) change negative values to zero
% 3) find peaks -> RULES?
% 4) calculate resistance-> AVG of x samples? 
% 5) 
%% 1)Get data folder and load data
clear,clc,
% Voltage = 0.5;
% onedrive='C:\Local\maki9\Programs\OneDrive - TUNI.fi\Demo3.1\MicroscopyVideos';
% external_drive='E:\Demo3.1\microscopyVideos';
verkkolevy = 'S:\71301_Zeiss_Scope\Anne\Antille\MatLab analyysiin_Antille\';
%%%
folder_to_read =  pwd;
folder_to_read =  onedrive;
folder_to_read = external_drive;
folder_to_read = verkkolevy;
%%%
vid_folder = [uigetdir(folder_to_read,'Pick a Directory of Videos'),'\'];

disp(['Folder: ',vid_folder])
listdir = dir(vid_folder);
filename=[];
for ii = 1 : length(listdir)
    [~,name, ext] = fileparts(listdir(ii).name);
    if strcmp(ext, '.xlsx')
        filename{end+1,1} = fullfile(listdir(ii).name);
    end
end
if isempty(filename)
    disp('No data found!')
    return
end
disp([10,'%%%%%%%%%%%%%%%',10,'List of data found:'])
for ii = 1 : length(filename)
    fprintf('Data#%d) %s\n',ii, filename{ii})   
end
datalist=[]; Data={};
ii=1; temp=[num2str(ii),') ',filename{ii}]; 
datalist=[datalist, temp];
datanames{ii,1} = filename{ii};
Data{ii}.listname = temp;
Data{ii}.filename = filename{ii};
Data{ii}.title= filename{ii}(1:end-5);
Data{ii}.id = str2double(filename{ii}(end-5-3:end-5));

if length(filename) > 1
   for ii = 2 : length(filename)
       temp=[' %%% ',num2str(ii),')  ',filename{ii}];
       datalist=[datalist, temp];
       datanames{ii,1} = filename{ii};
       Data{ii,1}.listname = temp;
       Data{ii,1}.filename = filename{ii};
       Data{ii,1}.title= filename{ii}(1:end-5);
       Data{ii,1}.id = str2double(filename{ii}(end-5-3:end-5));
   end
end

% opts.VariableNames = ["t_s", "I_uA"];
% read and load data
% folder_to_read = verkkolevy;
for ii = 1 : length(filename)
   file_to_read = filename{ii};
   Read_Resistance;
   Data{ii,1}.I = temp_data;
   Data{ii,1}.time = Data{ii,1}.I.t_s;
end