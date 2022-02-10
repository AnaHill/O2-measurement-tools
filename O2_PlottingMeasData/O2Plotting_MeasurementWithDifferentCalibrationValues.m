%% Plotting O2 data with different calibration files
clear, close all, 
legendas=[];
plot_fig = 1;kk=1;
O2Plotting_LoadData
iseA1 = evalin( 'base', 'exist(''Ksv'',''var'') == 1' );
iseA2 = evalin( 'base', 'exist(''phi0'',''var'') == 1' );
iseA3 = evalin( 'base', 'exist(''caldevi'',''var'') == 1' );
if ~(iseA1 && iseA2 && iseA3)
%    OrgCalibInfo = 'Unknown, but MAYBE Ksv: 0.185, phi0: 53, caldevi: 18'; 
   DefaultCalibs=[0.12999545, 50.29295, 16.04606150]; % Ksv, phi0, caldevi
   Ksv=DefaultCalibs(1); phi0=DefaultCalibs(2); caldevi=DefaultCalibs(3);
   Calib_Info = ['Parameters not found!!!! Using following',...
      ' (default) parameters: Ksv = 0.13, phi0 = 50.29, caldevi = 16.05'];
   errorStruct_calib.message = 'Calibration variables not found.';
   warndlg(['Suitable calibration variables not found',10,...
      'Using default calibration parameters: ','Ksv: ',num2str(Ksv),', phi0: ',...
      num2str(phi0),', caldevi: ',num2str(caldevi)],'Calibration Error'); 
   disp(Calib_Info) 
   OrgCalibInfo = Calib_Info;
else
   OrgCalibInfo = ['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
   ', caldevi: ',num2str(caldevi)]; 
end

legendas{end+1} = [filename(1:end-4)];
while plot_fig == 1
   if kk == 1
      legendas{1} = ['Org (',num2str(OrgCalibInfo),')'];
      O2meas_figs = figure('units','normalized','outerposition',[0 0 1 1]);
      hold all
      plot(time_,DataToPlot{3}), xlabel(xlabeling),ylabel('O_2 (%)')
   else
      plot(time_,pO2_changed), 
      legendas{end+1} = ['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)];
   end
   % ask more
   ChangeCalibration = questdlg(['Do you want to change calibration values?',10,...
      'Current values are: ','Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)], ...
      'Changing calibration','Yes','No, stop', 'Yes');
   if strcmp(ChangeCalibration ,'Yes')
      prompt = {'Ksv:','phi0:','caldevi:'};
      dlg_title = ['Set calibration values'];
      size_wind = [1 50; 1 50; 1 50]; % Windows size
      defaultans = {num2str(Ksv),num2str(phi0),num2str(caldevi)};
      options.Resize = 'on';
      answer = inputdlg(prompt,dlg_title,size_wind, defaultans,options);
      Ksv=str2num(answer{1}); phi0=str2num(answer{2}); caldevi=str2num(answer{3});
      disp(['Manually chosen calibration parameters:'])
      disp(['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)])   
      pO2_changed = SternVolmerC(Ksv,phi0,-DataToPlot{1},caldevi);
      kk=kk+1;
   else
      plot_fig = 0;
   end   
end
title(filename(1:end-4),'Interpreter','none')
legend(legendas,'Location','best','Interpreter','none')
wantToSaveFig = questdlg(['Want to save figure'],...
   'Saving ','Yes','No','Yes');
if strcmp(wantToSaveFig ,'Yes') 
   savepathname = uigetdir(pwd,'Choose saving folder');
   disp('% Saving %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
   disp(['Saving location: ',10,savepathname])
   fname = ['CalibValuesComparison_',filename(1:end-4)];
   saveas(gcf,[savepathname,'\',fname],'fig')
   disp('Figure saved to:')  
   disp([savepathname,10,'Figure name: ',fname,'.fig',10,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
else
   disp('No saving')
end