%clear, close all, 
O2Plotting_LoadData
colours={'r',[0 0.5 0],'b'};
hsubplotting=figure('units','normalized','outerposition',[0 0 1 1]);
for pp = 1:3
   subplot(3,1,pp), plot(time_,DataToPlot{pp},'color',colours{pp}),grid on;
   xlabel(xlabeling), hold all
   switch pp
      case 1
         ylabel('Phase (deg)');
      case 2
         ylabel('Amplitude ()');   
      case 3 
         ylabel('O_2 (%)')% ('pO_2 (kPa)');
   end   
end
%uiwait(gcf)
wantToSaveFig = questdlg(['Want to save figure'],...
   'Saving ','Yes','No','Yes');
if strcmp(wantToSaveFig ,'Yes') 
   savepathname = uigetdir(pwd,'Choose saving folder');
   disp('% Saving %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
   disp(['Saving location: ',10,savepathname])
   fname = ['AllMeasData_',filename(1:end-4)];
   saveas(gcf,[savepathname,'\',fname],'fig')
   disp('Figure saved to:')  
   disp([savepathname,10,'Figure name: ',fname,'.fig',10,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
else
   disp('No saving')
end



% if strcmp(wantToSaveFig ,'Yes') 
%    [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement');
%    fname=[SaveDataname];
%    disp('% Saving %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
%    disp(['Saving location: ',10,savepathname])
%    saveas(gcf,[savepathname,fname(1:end-4),'_AllMeasData_',filename(1:end-4)],'fig')
%    disp('Measurement saved to:')  
%    disp([savepathname,10,fname,10,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
% else
%    disp('No saving')
% end
