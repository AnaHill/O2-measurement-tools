%% Kuinka lukea O2 data jos se tekstiedostossa (esim kaatunut, jolloin ei .mat)

%% Luetaan data: without start & end Rows
clear, [t_,phiM_,ampM_,pO2M_] = O2_import_measurement_data_from_text_file();
% with specific start & end rows
% [t_,phiM_,ampM_,pO2M_] = O2_import_measurement_data_from_text_file(startRow, endRow)

%% Kysyt‰‰n tallennuspaikka ja nimi
if exist('savepathname', 'var')
   [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement',savepathname);
else
   [SaveDataname, savepathname] = uiputfile({'*.mat';'*.txt';'*.*'}, 'Saving measurement');
end
if SaveDataname == 0 % if cancel is pressed
   error('Cancelled')
end
%% Tallennetaan datat .mat tiedostoon
save([savepathname,SaveDataname],'t_','phiM_','ampM_','pO2M_')









