%% Plotting O2 data with different calibration files
clear, close all, legendas=[];
plot_fig = 1;kk=1;
[loadfilename, loadpathname] = uigetfile({'*.mat', ' .mat file';},...
   'Choose measurement file');
load([loadpathname,loadfilename]);
iseA = evalin( 'base', 'exist(''Data_O2'',''var'') == 1' );
while plot_fig == 1
   % TÄHÄN TArkistusskriptiä yms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%
   if kk == 1
      ise = evalin( 'base', 'exist(''fname'',''var'') == 1' );
      if ise
         idx = strfind(fname,'_FromDATA');
         if isempty(idx)
            legendas{end+1} = fname;
         else
            legendas{end+1} = fname(1:idx-1);
         end
      else % if no fname variable -> ask name
         prompt = {'Name'};
         dlg_title = 'Insert name';
         num_lines = 1;   defaultans = {''};
         answer = inputdlg(prompt,dlg_title,num_lines,defaultans); 
         legendas{kk}=(answer{1});
      end
      isefig = evalin( 'base', 'exist(''O2meas_figs'',''var'') == 1' );
      if ~isefig
         O2meas_figs = figure('units','normalized','outerposition',[0.2 0.4 0.6 0.6]);
         hold all
      end
      hO2{kk}=plot(Data_O2(:,1), Data_O2(:,2)); 
   end
   kk=kk+1;
   % ask more
   ChangeCalibration = questdlg(['Change calibration values'], ...
      'Changing calibration','Yes','No, stop', 'Yes');
   if strcmp(ChangeCalibration ,'Yes')
      prompt = {'Ksv:','phi0:','caldevi:'};
      dlg_title = 'Set calibration values';
      num_lines = 1;
      defaultans = {'0.185','53','18'};
      answer = inputdlg(prompt,dlg_title,num_lines,defaultans); 
      Ksv=str2num(answer{1}); phi0=str2num(answer{2}); caldevi=str2num(answer{3});
      disp(['Manually chosen calibration parameters:'])
      disp(['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)])   
% %       % plotting with new calibration files
% %       
% %       pO2 = SternVolmerC(Ksv,phi0,-phi,caldevi);
% %       phi=mean(angle(Measurement-StopCal)/pi*180);
      time=RawData_time_phase_O2(:,1)-RawData_time_phase_O2(1,1);
      phi = RawData_time_phase_O2(:,2);
      pO2 = SternVolmerC(Ksv,phi0,-phi,caldevi);
      plot(time, pO2)
   else
      plot_fig = 0;
   end
end
legend(legendas,'Location','best','Interpreter','none')
%clear O2meas_figs
%%
