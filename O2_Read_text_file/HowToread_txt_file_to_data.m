%% How to read O2 data from text file, if e.g. crashed without saving to .mat file 
% Kuinka lukea O2 data jos se tekstiedostossa (esim jos kaatunut, jolloin ei .mat)

%% Reading data: 
% without start & end Rows
clear, [t_,phiM_,ampM_,pO2M_] = O2_import_measurement_data_from_text_file();
% with specific start & end rows
% [t_,phiM_,ampM_,pO2M_] = O2_import_measurement_data_from_text_file(startRow, endRow)

%% Asking saving folder and name
if exist('savepathname', 'var')
   [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement',savepathname);
else
   [SaveDataname, savepathname] = uiputfile({'*.mat';'*.txt';'*.*'}, 'Saving measurement');
end
if SaveDataname == 0 % if cancel is pressed
   error('Cancelled')
end
%% Saving data to .mat file
save([savepathname,SaveDataname],'t_','phiM_','ampM_','pO2M_')









