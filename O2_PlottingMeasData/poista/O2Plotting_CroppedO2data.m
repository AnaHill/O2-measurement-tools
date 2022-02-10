%% Plotting O2 data
clear, close all, legendas=[];
plot_fig = 1;
kk=1;
ise = evalin( 'base', 'exist(''Data_O2'',''var'') == 1' );
if ise
   useFoundData = questdlg(['Use measurement variable on the workspace'], ...
   'Chosen ','Yes','No, load from file', 'Yes');
end
if ~(ise) || strcmp(useFoundData ,'No, load from file')
%    Loading data from a file 
   [loadfilename, loadpathname] = uigetfile({'*.mat', ' .mat file';},...
      'Choose measurement file');
   load([loadpathname,loadfilename]);
   iseA = evalin( 'base', 'exist(''Data_O2'',''var'') == 1' );
   % TÄHÄN TArkistusskriptiä yms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%
   
end
while plot_fig == 1
   if kk > 1
      [loadfilename, loadpathname] = uigetfile({'*.mat', ' .mat file';},...
         'Choose measurement file');
      load([loadpathname,loadfilename]);
      iseA = evalin( 'base', 'exist(''Data_O2'',''var'') == 1' );
         % TÄHÄN TArkistusskriptiä yms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         %%%%%
   end
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
   kk=kk+1;
   % ask more
   PlotMore = questdlg(['Plotting more data'], ...
      'Plotting','Yes','No, stop', 'Yes');
   if strcmp(PlotMore ,'No, stop')
      plot_fig = 0;
   end
end
legend(legendas,'Location','best','Interpreter','none')
%clear O2meas_figs
%%
