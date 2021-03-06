function [t_,phiM_,ampM_,pO2M_, fname] = O2_import_measurement_data_from_text_file(startRow, endRow)
%O2_IMPORT_MEASUREMENT_DATA_FROM_TEXT_FILE
   % Import numeric data from a text file as column vectors.
% Run: without start & end Rows
% [t_,phiM_,ampM_,pO2M_, fname] = O2_import_measurement_data_from_text_file()
% with specific start & end rows
% [t_,phiM_,ampM_,pO2M_, fname] = O2_import_measurement_data_from_text_file(startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [T_,PHIM_,AMPM_,PO2M_] = O2_import_measurement_data_from_text_file(FILENAME) Reads data from text file
%   FILENAME for the default selection.
%
%   [T_,PHIM_,AMPM_,PO2M_] = O2_import_measurement_data_from_text_file(STARTROW, ENDROW) Reads data
%   from rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   [t_,phiM_,ampM_,pO2M_] = O2_import_measurement_data_from_text_file(1, 2444);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2018/08/14 14:43:10

% Ask file if filename 
[filename, pathname] = uigetfile({'*.txt', ' .txt  file';},...
   'Pick a file');

%% Initialize variables.
delimiter = {'\t',' '};
if nargin<=2
   startRow = 1;
   endRow = inf;
end

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen([pathname,filename],'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this code. If
% an error occurs for a different file, try regenerating the code from the
% Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1), ...
   'Delimiter', delimiter, 'MultipleDelimsAsOne', true, ...
   'HeaderLines', startRow(1), 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
   frewind(fileID);
   dataArrayBlock = textscan(fileID, formatSpec, ...
      endRow(block)-startRow(block)+1, 'Delimiter', delimiter,...
      'MultipleDelimsAsOne', true, 'HeaderLines', startRow(block)-1,...
      'ReturnOnError', false, 'EndOfLine', '\r\n');
   for col=1:length(dataArray)
      dataArray{col} = [dataArray{col};dataArrayBlock{col}];
   end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
   raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4]
   % Converts text in the input cell array to numbers. Replaced non-numeric text
   % with NaN.
   rawData = dataArray{col};
   for row=1:size(rawData, 1);
      % Create a regular expression to detect and remove non-numeric prefixes and
      % suffixes.
      regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
      try
         result = regexp(rawData{row}, regexstr, 'names');
         numbers = result.numbers;
         
         % Detected commas in non-thousand locations.
         invalidThousandsSeparator = false;
         if any(numbers==',');
            thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
            if isempty(regexp(numbers, thousandsRegExp, 'once'));
               numbers = NaN;
               invalidThousandsSeparator = true;
            end
         end
         % Convert numeric text to numbers.
         if ~invalidThousandsSeparator;
            numbers = textscan(strrep(numbers, ',', ''), '%f');
            numericData(row, col) = numbers{1};
            raw{row, col} = numbers{1};
         end
      catch me
      end
   end
end


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
t_ = cell2mat(raw(:, 1));
phiM_ = cell2mat(raw(:, 2));
ampM_ = cell2mat(raw(:, 3));
pO2M_ = cell2mat(raw(:, 4));


