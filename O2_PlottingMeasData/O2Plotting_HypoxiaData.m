%% Plotting different measurement O2 data
clear, close all, 
colours={'r',[0 0.5 0],'b'};
O2Plotting_LoadData
legendas=[];
plot_fig = 1;
disp(['%%%',10,'Plotting O2% from file:'])  
disp([filename]),disp('From:'),disp([pathname,10,'%%%'])

figure('units','normalized','outerposition',[0 0 1 1]);
plot(t0/3600,Oxy0pros), hold all, xlabel(xlabeling),ylabel('O_2 (%)')
plot(t1/3600,Oxy1pros), plot(t5/3600,Oxy5pros),
%%
%legendas{1} = [filename(1:end-4)];

NextMeasurement = questdlg(['Plot another measurement'], ...
         'Plotting','Yes','No, stop', 'Yes');
if strcmp(NextMeasurement ,'Yes')
   O2Plotting_LoadData
else
   plot_fig = 0;
end
while plot_fig == 1
   %legendas{end+1} = [filename(1:end-4)];
   %time=t_; %colours={'r',[0 0.5 0],'b'};
   plot(time_,DataToPlot{3}), %xlabel(xlabeling),ylabel('O_2 (%)')
   NextMeasurement = questdlg(['Plot another measurement'], ...
         'Plotting','Yes','No, stop', 'Yes');
   if strcmp(NextMeasurement ,'Yes')
      O2Plotting_LoadData
   else
      plot_fig = 0;
   end
end
%legend(legendas,'Location','best','Interpreter','none')
