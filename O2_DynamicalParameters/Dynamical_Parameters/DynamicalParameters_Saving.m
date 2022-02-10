%% %%%%% Saving figure and information
wantToSaveFig = questdlg(['Want to save defined data?'],...
   'Saving ','Yes','No', options);
if strcmp(wantToSaveFig ,'Yes') 
   if exist('savepathname', 'var')
      [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement',savepathname);
   else
      [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement');
   end
   if exist('loadfilename','var')
      fname=[SaveDataname(1:end-4),'_Data_',loadfilename];
   else
      fname=[SaveDataname];
   end
   disp(['%%%',10,'Measurement file name: ',10,fname(1:end-4)])
   disp(['Saving location: ',10,savepathname])
   save([savepathname,fname],'Data_To_Analyzed','Datafiltered','timeVector','fname',...
      't10','t90','Rise_time_own','Rise_time','Delay_time','tStep','Time_Constant',...
      'Time_Constant2','X0','Y','StepInformation','Rise_time')   
%     save([savepathname,fname],'Data_To_Analyzed','Datafiltered','timeVector','fname',...
%         't10','t90','Rise_time_own','Rise_time','Delay_time','tStep','Time_Constant',...
%         'Time_Constant2','X0','Y','StepInformation','Rise_time')  
   disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
 else
   disp('Data not saved')  
end
wantToSaveFig = questdlg(['Want to save figure?'],...
   'Saving ','Yes','No', options);
if strcmp(wantToSaveFig ,'Yes') 
   saveas(hparam,[savepathname,fname(1:end-4)],'fig')
   if length(fname) > 62
      saveas(hparam,[savepathname,fname(1:62)],'m')
   else
      saveas(hparam,[savepathname,fname(1:end-4)],'m')
   end
   saveas(hparam,[savepathname,fname(1:end-4)],'png')
   disp('Fig saved to:')  
   disp([savepathname,10,'Names: ',fname(1:end-4),10,'%%%%%%%%%%%%%%'])
else
   disp('No saving')
end