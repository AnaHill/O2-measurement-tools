% DynamicalParameters_Load: loading measurement file
[loadfilename, loadpathname] = uigetfile({'*.mat;', ' .mat file';},...
   'Choose measurement file');
load([loadpathname,loadfilename]);
disp(['%%%',10,'Read measurement file:'])  
disp([loadfilename])
disp('From:')  
disp([loadpathname,10,'%%%'])
colours={'r',[0 0.5 0],'b'};

%% POSSIBLE To Do: also .txt file could be used when loading data
% [loadfilename, loadpathname] = uigetfile({'*.mat;*.txt;', ' .mat or .txt file';},...
%    'Choose measurement file');

% if loadfilename(end-2:end) == 'txt'
%    delimiter = '\t';startRow = 2;formatSpec = '%f%f%f%f%[^\n\r]';
%    fileID = fopen([loadpathname,loadfilename],'r');
%    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,...
%       'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
%    fclose(fileID);
%    t_ = dataArray{:, 1}; %time = t_;
%    phiM_ = dataArray{:, 2}; %phiM = phiM_;
%    ampM_ = dataArray{:, 3}; %ampM = ampM_;
%    pO2M_ = dataArray{:, 4}; %pO2M = pO2M_;
%    % Clear temporary variables
%    clearvars  delimiter startRow formatSpec fileID dataArray ans;
% else
%    load([loadpathname,loadfilename]);
% end