%% Plotting different measurement O2 data
clear, close all, 
colours={'r',[0 0.5 0],'b'};
O2Plotting_LoadData
legendas=[];
plot_fig = 1;
disp(['%%%',10,'Plotting O2% from file:'])  
disp([filename]),disp('From:'),disp([pathname,10,'%%%'])

figure('units','normalized','outerposition',[0 0 1 1]);
if ~strcmp(filename,'Hypoxia_0_1_5pros.mat')
   plot(time_,DataToPlot{3}), 
else % if hypoxia measurement 
   plot(time_,Oxy0pros), 
end
hold all, xlabel(xlabeling),ylabel('O_2 (%)')

iseA1 = evalin( 'base', 'exist(''Ksv'',''var'') == 1' );
iseA2 = evalin( 'base', 'exist(''phi0'',''var'') == 1' );
iseA3 = evalin( 'base', 'exist(''caldevi'',''var'') == 1' );

legendas{1} = [filename(1:end-4)];
legend(legendas,'Location','best','Interpreter','none')
NextMeasurement = questdlg(['Plot another measurement'], ...
         'Plotting','Yes','No, stop', 'Yes');
if strcmp(NextMeasurement ,'Yes')
   O2Plotting_LoadData
else
   plot_fig = 0;
end
while plot_fig == 1
   %time=t_; %colours={'r',[0 0.5 0],'b'};
   plot(time_,DataToPlot{3}), xlabel(xlabeling),ylabel('O_2 (%)')
   legendas{end+1} = [filename(1:end-4)];
   legend(legendas,'Location','best','Interpreter','none')
   NextMeasurement = questdlg(['Plot another measurement'], ...
         'Plotting','Yes','No, stop', 'Yes');
   if strcmp(NextMeasurement ,'Yes')
      O2Plotting_LoadData
   else
      plot_fig = 0;
   end
end
legend(legendas,'Location','best','Interpreter','none')
