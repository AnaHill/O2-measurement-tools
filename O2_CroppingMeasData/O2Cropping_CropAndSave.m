% O2Cropping_CropAndSave
while ~strcmp(wantToSave ,'Yes') 
   if strcmp(wantToSave ,'Crop more from this')
      [DataChosen, meas_start_time]=O2Cropping_ChooseArea(DataChosen);   
   else
      disp('No saving, stopping')
      NoSavingThis=0;
      break
   end
   wantToSave = questdlg(['Want to save this?'], ...
      'Saving ','Yes','Crop more from this','No, stop or choose another data', 'Yes');
end
iseNotSave = evalin( 'base', 'exist(''NoSavingThis'',''var'') == 0' );
if iseNotSave
   % Convert measurement time to start from 0
   % meas_start_time=DataChosen(x_val(1),1);
   Data_O2 = [DataChosen(:,1)-meas_start_time,DataChosen(:,2)];
   % Saving also raw data to mat file (time, phase, and O2)
   index = find(t_ == meas_start_time,1);
   index2 = index+length(Data_O2)-1;
   if ~isrow(t_)
      t_row=t_';
   else
      t_row=t_;
   end
   if ~isrow(Data_{1})
      Data_O2_row1=Data_{1}';
   else
      Data_O2_row1=Data_{1};
   end
   if ~isrow(Data_{3})
      Data_O2_row=Data_{3}';
   else
      Data_O2_row=Data_{3};
   end
   RawData_time_phase_O2 = [t_row(index:index2);Data_O2_row1(index:index2);...
      Data_O2_row(index:index2)]';

   % asking file name (starting time is added) and folder,
   disp('Set folder where data is saved.')
   % data_folder_to_save = [uigetdir(pwd,' Choose a Directory where data is saved'),'\'];
   % https://se.mathworks.com/help/matlab/ref/uiputfile.html
   if exist('savepathname', 'var')
      [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement',savepathname);
   else
      [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement');
   end
   if SaveDataname == 0 % if cancel is pressed
      error('Cancelled')
   end
   if exist('filename','var')
      fname=[SaveDataname(1:end-4),'_FromDATA_',filename];
      fnametxt=[fname(1:end-3),'txt'];
   else
      fname=[SaveDataname];fnametxt=[fname(1:end-3),'txt'];
   end
   disp(['%%%',10,'Measurement file name: ',10,fname(1:end-4)])
   % disp(['Saving location: ',10,data_folder_to_save])
   disp(['Saving location: ',10,savepathname])
   % save to .mat file
   save([savepathname,fname],'Data_O2','meas_start_time','fname','RawData_time_phase_O2')
   save([savepathname,fnametxt],'Data_O2','-ascii')
   get(gcf),title(fname,'interpreter','none')
   saveas(gcf,[savepathname,fname(1:end-4),'_cropped'],'fig')
   disp('Measurement saved (.txt and .mat files + figure) to')  
   disp([savepathname,fname(1:end-4),10,'%%%'])
   
else
   clear NoSavingThis
end