%% Choose and save part of O2 measurement
% load and plot measurement
iseBack = evalin( 'base', 'exist(''BackToMainFigure'',''var'') == 1' );
if iseBack
   clear, BackToMainFigure = 1;
else
   clear
end
close all
%cd 'C:\Local\maki9\Data\MATLAB\O2\O2_CroppingMeasData'
O2Cropping_Load % .m
close, pp=3;
disp('Plotting measurement data (O2%)')
hfig1=figure('Name','Choosing values','units',...
   'normalized','outerposition',[0 0 1 1]);
plot(t_,Data_{pp}),%xlim([1 length(Data_{pp})])
title([pathname,filename],'Interpreter', 'none'), 
% xlabel('Measurement number (not time)')
xlabel('Measurement time (s)')
ylabel('Measured O2 (%)'), 
if isrow(t_)
   t_=t_';
end
if isrow(Data_{pp})
   Data_{pp}=Data_{pp}';
end
DataO2=[t_ Data_{pp}];
%% Choosing area
[DataChosen, meas_start_time]=O2Cropping_ChooseArea(DataO2);
%% Asking to save / Stop / Crop more
wantToSave = questdlg(['Want to save this?'], ...
   'Saving ','Yes','Crop more from this','No, stop or choose another', 'Yes');
O2Cropping_CropAndSave
%% Asking to continue (choosing different region from the loaded data)
wantToChooseMore = questdlg(['Want to choose another region from the data?'], ...
   'Choosing More','Yes','No, stop', 'Yes');
while strcmp(wantToChooseMore ,'Yes') 
   fighandles = findall( allchild(0), 'type', 'figure');
   if length(fighandles) > 1
      close(figure(fighandles(1)))
   end
   [DataChosen,meas_start_time]=O2Cropping_ChooseArea(DataO2);
   wantToSave = questdlg(['Want to save this?'], ...
   'Saving ','Yes','Crop more from this','No, stop or choose another', 'Yes');
   O2Cropping_CropAndSave
   wantToChooseMore = questdlg(['Want to choose another region from the data?'], ...
      'Choosing More','Yes','No', 'Yes');
end
disp(['%%%',10,'Stopped'])
wantToChooseAnotherData = questdlg(['Want to choose another data?'], ...
      'Choosing Another Data','Yes','No, stop and close', 'Yes');
if strcmp(wantToChooseAnotherData ,'Yes')
   O2Cropping_MAIN
else
   disp('Closing figure'),
   close all
end
% % If ran from the main figure --> returning
% iseBack = evalin( 'base', 'exist(''BackToMainFigure'',''var'') == 1' );
% if iseBack
%    cd .. 
%    O2_MAIN_ChoosingWhatToDo
% end

