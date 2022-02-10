%% Plotting O2 data with different calibration values
clear, close all, legendas=[];
plot_fig = 1;
[loadfilename, loadpathname] = uigetfile({'*.mat', ' .mat file';},...
   'Choose measurement file');
load([loadpathname,loadfilename]);
iseA = evalin( 'base', 'exist(''phiM_'',''var'') == 1' );
iseA2 = evalin( 'base', 'exist(''ampM_'',''var'') == 1' );
iseA3 = evalin( 'base', 'exist(''pO2M_'',''var'') == 1' );
iseA4 = evalin( 'base', 'exist(''t_'',''var'') == 1' );
if ~(iseA && iseA2 && iseA3 && iseA4)
   iseB = evalin( 'base', 'exist(''phiM'',''var'') == 1' );
   iseB2 = evalin( 'base', 'exist(''ampM'',''var'') == 1' );
   iseB3 = evalin( 'base', 'exist(''pO2M'',''var'') == 1' );
   iseB4 = evalin( 'base', 'exist(''t'',''var'') == 1' );
   if iseB
      phiM_ = phiM;
   end
   if iseB2
      ampM_ = ampM;
   end
   if iseB3
      pO2M_ = pO2M;
   end
   if iseB4
      t_ = t;
   end
end
% Clear temporary variables
disp(['%%%',10,'Read measurement file:'])  
disp([loadfilename]),disp('From:'),disp([loadpathname,10,'%%%'])
time=t_; %colours={'r',[0 0.5 0],'b'};
MaxTime_sec=max(time);
if MaxTime_sec < 300
   time_ = time; xlabeling = ('Time (sec)');
elseif (MaxTime_sec >= 300 && MaxTime_sec < 60*60*3)
   time_ = time/60; xlabeling = ('Time (min)');
else
   time_ = time/(60*60); xlabeling = ('Time (h)');
end
plot(time_,pO2M_), hold all, xlabel(xlabeling),ylabel('O_2 (%)')

iseA1 = evalin( 'base', 'exist(''Ksv'',''var'') == 1' );
iseA2 = evalin( 'base', 'exist(''phi0'',''var'') == 1' );
iseA3 = evalin( 'base', 'exist(''caldevi'',''var'') == 1' );
if ~(iseA1 && iseA2 && iseA3)
   OrgCalibInfo = 'MAYBE Ksv: 0.185, phi0: 53, caldevi: 18'; 
else
   OrgCalibInfo = ['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
   ', caldevi: ',num2str(caldevi)]; 
end

legendas{1} = ['Org (',num2str(OrgCalibInfo),')'];
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
else
   plot_fig = 0;
end
% kk=1;  
while plot_fig == 1
   pO2new = SternVolmerC(Ksv,phi0,-phiM_,caldevi);
   legendas{end+1} = ['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)];
   plot(time_, pO2new)
   ChangeCalibration = questdlg(['Change calibration values'], ...
         'Changing calibration','Yes','No, stop', 'Yes');
   if strcmp(ChangeCalibration ,'Yes')
      prompt = {'Ksv:','phi0:','caldevi:'};
      dlg_title = 'Set calibration values';
      num_lines = 1;
      defaultans = {num2str(Ksv),num2str(phi0),num2str(caldevi)};
      % defaultans = {'0.185','53','18'};
      answer = inputdlg(prompt,dlg_title,num_lines,defaultans); 
      Ksv=str2num(answer{1}); phi0=str2num(answer{2}); caldevi=str2num(answer{3});
      disp(['Manually chosen calibration parameters:'])
      disp(['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
      ', caldevi: ',num2str(caldevi)])   
%       legendas{end+1} = ['Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
%       ', caldevi: ',num2str(caldevi)];
   else
      plot_fig = 0;
   end
end
title(loadfilename)
legend(legendas,'Location','best','Interpreter','none')





































while plot_fig == 1
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
