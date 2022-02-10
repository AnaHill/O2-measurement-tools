% O2DynamicalParameters_PlotParameters
% ver 1.01 
% Updates 
   % changing time constant (tau) y-level naming on the fig:
      %    if iseResponseInfo % step up
            % text('y(~63.2%)');
      %    else % step down: tau 63.2% change from initial 100% -> 100-63.2%
         % text('y(~36.8% (100%-63.2%))');
%% Defining parameters from the plot
   % Rise time tr: time it takes between 10% and 90%
   % Delay td: time that initial filtered data has changed DelayLevel 
      % Defined by variable DelayLevel (default: 0.1% change from starting
      % level)
   % Time constant tau: Two methods used:
      % time from td to ~63.2% (delay excluded)
      % 1st order fitting to data from td to end
%% Parameters to change   
   DelayLevel = 0.001; % 0.001 = 0.1 % from the dashed region up(or downn)
   filt_method = 3; % Choose Filter method 1-3, 
      % 1)  = mave, 2) = sgolay, 3) smooth loess
   Method_to_take_max_and_min_values = 1; % way to get 0% and 100% values
      % 1) = median, 2) = mean
   
%%%%%%%%%
Data_O2 = DataChosen; 
Data_O2(:,1) = Data_O2(:,1)-Data_O2(1,1);
legs={}; timeVector = Data_O2(:,1); close;
hparam=figure('Name','Calculating parameters','units',...
   'normalized','outerposition',[0 0 1 1]);
hmeas = plot(timeVector,Data_O2(:,2),'o','Markersize',4,...
   'color',[0.8 0.8 0.8]); hold all
legs{end+1} = 'Meas Data';
%%%%% Filtering: what is proper window size?
if length(timeVector) > 200
   Nmave=10;% window size
   Nsgolay = 19;
   coef_loess=0.01;
else
   Nmave=5; Nsgolay = 9; coef_loess=0.01; % coef_loess eri tässä?
   if Nmave > length(timeVector) 
      Nmave=1; Nsgolay = 3;
   end
end
% Method 1 using mave
% Method 2: matlab sqolay
% Method 2: smooth loess
disp('Filtering data: it might take for a while, please wait.')
htextfilt=text(max(timeVector)/3,min([Data_O2(:,2)]) + abs(max(Data_O2(:,2))- min(Data_O2(:,2)))/2,...
   'Filtering data: it might take for a while, please wait.',...
   'Color','red','FontWeight','bold','FontSize',14);
switch filt_method
   case 1 % own moving average mvave
      DataO2filtered_own = mave(Data_O2(:,2),Nmave);
      DataO2filtered = DataO2filtered_own;
      legs{end+1} = ['Meas Data, filtered (own, wind = ',num2str(Nmave),')'];
      used_filter_name = ['Own, moving average, window size: ',num2str(Nmave)];
   case 2 % sgolay
      DataO2filtered_smooth_sgolay = smooth(Data_O2(:,2),'sgolay'); % n = 5
      DataO2filtered = DataO2filtered_smooth_sgolay;
      legs{end+1} = ['Meas Data, filtered (smooth, sgolay: with span 5, degree 2)'];
      used_filter_name = ['Sqolay with span 5, degree 2'];
   case 3 % loess      
      DataO2filtered = smooth(timeVector,Data_O2(:,2),coef_loess,'loess');
      legs{end+1} = ['Meas Data, filtered (smooth, loess: ',num2str(coef_loess),')'];
      used_filter_name = ['Smooth loess: ',num2str(coef_loess) ];
end
disp('Filtering ready')
delete(htextfilt)
disp(['Used filter: ',used_filter_name])
% interpolating to 1 sec interval betweed data points in filtered data
disp('Interpolating data to 1 sec intervals and plotting interpolated&filtered data')
DataO2filteredORG=DataO2filtered; timeVectorORG = timeVector;
timeVector = [0:max(timeVector)]';
DataO2filtered = [interp1(timeVectorORG,DataO2filteredORG,timeVector,'pchip')]; 
hmeasfilt = plot(timeVector,DataO2filtered,'linewidth',3);%,'*')

% 0% and 100% dashed -- lines 
if length(timeVector) > 1000
   Nsamples=20;% how many samples to define start and stop
else
   Nsamples=10;
   if Nsamples > length(timeVector) 
      Nsamples=1;
   end
end
switch Method_to_take_max_and_min_values
   case 1 % median
      Values1 = median(DataO2filtered(1:Nsamples));
      Values2 = median(DataO2filtered(end-Nsamples+1:end));
   case 2 % mean
      Values1 = mean(DataO2filtered(1:Nsamples));
      Values2 = mean(DataO2filtered(end-Nsamples+1:end));
end
   
if Values1 < Values2
   ResponseInfo='Step up'
elseif Values1 > Values2
   ResponseInfo='Step down'
else 
   ResponseInfo='No step'
end   
hlin{1}=line([0 timeVector(end)], [Values1 Values1],...
   'color',[0.4 0.4 0.4], 'Linestyle','--','Linewidth',2);
hlin{2}=line([0 timeVector(end)], [Values2 Values2],...
   'color',[0.4 0.4 0.4], 'Linestyle','--','Linewidth',2);
% Additonal line to show value where delay is defined
iseResponseInfo = strcmp(ResponseInfo,'Step up');
if iseResponseInfo % step up
   TotRange = Values2 -  Values1; 
   %%%%%%% delay: time to reach Delaylevel amount of change   
   y_delay = DelayLevel*TotRange + min([Values1,Values2]); 
else % step down
   TotRange = Values1 - Values2;
   %%%%%%% delay: time to reach Delaylevel amount of change
   y_delay = (1-DelayLevel)*TotRange + min([Values1,Values2]);
end
extra_line = line([0 max(timeVector)], [y_delay y_delay],...
   'color',[0.85 0.85 0.85], 'Linestyle','--');    
   
   
chosen_Values = questdlg(['Are values (=',...
   num2str(Values1,4),' and ',num2str(Values2,4),...
   ') good for start and final values?'], ...
   'Chosen ','Yes','No, choose with a mouse','No, input range manually', 'Yes');
% if not --> choose by mouse OR manually
while ~strcmp(chosen_Values ,'Yes') 
   % PAUSE for zooming
   htext=text(max(timeVector)/3,min([Values1,Values2]) + abs(Values2 - Values1)/2,...
   'Paused before choosing start and final values: figure can be zoomed etc. Press any keyboard key to continue',...
   'Color','red','FontWeight','bold','FontSize',14);
   disp('Press any keyboard key here to continue')
   pause(),disp('Key pressed, continuing'), delete(htext)
   axis('auto')
   % CHOOSE that with mouse or manually setting
      % 'No, choose with a mouse'
   if strcmp(chosen_Values ,'No, choose with a mouse') 
      title(['Taking median',10,'Use mouse to choose area for the \color{red}first value'])
      htext=text(max(timeVector)/3,min([Values1,Values2])+abs(Values2 - Values1)/2,...
      'Use mouse to choose area for the \color{red}first value',...
      'Color','red','FontWeight','bold','FontSize',14);
      rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
      delete(htext)
      if x_val(1) < 0
         x_val(1) = 0;
      end
      if x_val(2) <= 0
         x_val(2) = 1;
      end
      if x_val(1) >= max(timeVector(:,1))
         x_val(1) = timeVector(end-1,1);
      end
      if x_val(2) > max(timeVector(:,1))
        x_val(2) = max(timeVector(:,1));
      end      
      start_point = find((timeVector(:,1)) >= x_val(1),1);
      end_point = find((timeVector(:,1)) >= x_val(2),1);
      Values1=median(DataO2filtered(start_point:end_point)); 
      if exist('hlin','var')
         delete(hlin{1}), %delete(hlin{2})
      end
      hlin{1}=line([0 timeVector(end)], [Values1 Values1],...
         'color',[0.4 0.4 0.4], 'Linestyle','--','Linewidth',2); 
      title(['Taking median',10,'Use mouse to choose area for the \color{blue}second value'])
      htext=text(max(timeVector)/3,min([Values1,Values2])+abs(Values2 - Values1)/2,...
      'Use mouse to choose area for the second value',...
      'Color','blue','FontWeight','bold','FontSize',14);
      rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
      delete(htext)
      if x_val(1) < 0
         x_val(1) = 0;
      end
      if x_val(2) <= 0
         x_val(2) = 1;
      end
      if x_val(1) >= max(timeVector(:,1))
         x_val(1) = timeVector(end-1,1);
      end
      if x_val(2) > max(timeVector(:,1))
        x_val(2) = max(timeVector(:,1));
      end
      start_point = find((timeVector(:,1)) >= x_val(1),1);
      end_point = find((timeVector(:,1)) >= x_val(2),1);
      Values2=median(DataO2filtered(start_point:end_point));
      if exist('hlin','var')
         delete(hlin{2}), %delete(hlin{1})
      end
      hlin{2}=line([0 timeVector(end)], [Values2 Values2],...
         'color',[0.4 0.4 0.4], 'Linestyle','--','Linewidth',2);   
   else % setting values manually
      prompt = {'Starting value:','Final value:'};
      dlg_title = ['Set starting and final values (represent 0 and 100% lines)'];
      size_wind = [1 50; 1 50]; % Windows size
      defaultans = {num2str(Values1),num2str(Values2)};
      options.Resize = 'on';
      answer = inputdlg(prompt,dlg_title,size_wind, defaultans,options);
      Values1=str2num(answer{1}); Values2=str2num(answer{2});
      disp(['Manually chosen starting and final values:'])
      disp(['Starting value: ',num2str(Values1)...
         ,10,'Final value: ',num2str(Values2)])
      if exist('hlin','var')
         delete(hlin{1}), delete(hlin{2})
      end
      hlin{1}=line([0 timeVector(end)], [Values1 Values1],...
         'color',[0.4 0.4 0.4], 'Linestyle','--','Linewidth',2);
      hlin{2}=line([0 timeVector(end)], [Values2 Values2],...
         'color',[0.4 0.4 0.4], 'Linestyle','--','Linewidth',2);
   end
   % Additonal line to show value where delay is defined
   iseResponseInfo = strcmp(ResponseInfo,'Step up');
   if iseResponseInfo % step up
      TotRange = Values2 - Values1; 
      %%%%%%% delay: time to reach Delaylevel amount of change   
      y_delay = DelayLevel*TotRange + min([Values1,Values2]); 
   else % step down
      TotRange = Values1 - Values2;
      %%%%%%% delay: time to reach Delaylevel amount of change
      y_delay = (1-DelayLevel)*TotRange + min([Values1,Values2]);
   end
   if exist('extra_line','var')
      delete(extra_line)
   end
   extra_line = line([0 max(timeVector)], [y_delay y_delay],...
   'color',[0.85 0.85 0.85], 'Linestyle','--'); 

   chosen_Values = questdlg(['Are values (=',...
      num2str(Values1,4),' and ',num2str(Values2,4),...
      ') good for start and final values?'], ...
      'Chosen ','Yes','No, choose with a mouse','No, input range manually', 'Yes');
end

iseResponseInfo = strcmp(ResponseInfo,'Step up');
if iseResponseInfo % step up
   TotRange = Values2 - Values1; 
   y10 = 0.1*TotRange + min([Values1,Values2]);
   y90 = 0.9*TotRange + min([Values1,Values2]);
   t10 = timeVector(find(DataO2filtered >= y10,1));
   t90 = timeVector(find(DataO2filtered >= y90,1));
   %%%%%%% delay: time to reach Delaylevel amount of change   
   y_delay = DelayLevel*TotRange + min([Values1,Values2]);
   Delay_time = timeVector(find(DataO2filtered >= y_delay ,1));
   delay_point = find(timeVector >=  Delay_time,1);
   yStep = (1-1/exp(1))*TotRange + min([Values1,Values2]);
   tStep = timeVector(find(DataO2filtered >= yStep,1));
else % step down
   TotRange = Values1 - Values2;
   y10 = 0.1*TotRange + min([Values1,Values2]);
   y90 = 0.9*TotRange + min([Values1,Values2]);
   t10 = timeVector(find(DataO2filtered >= y10));t10=t10(end);
   t90 = timeVector(find(DataO2filtered >= y90));t90=t90(end);
   %%%%%%% delay: time to reach Delaylevel amount of change
   y_delay = (1-DelayLevel)*TotRange + min([Values1,Values2]);
   Delay_time = timeVector(find(DataO2filtered <= y_delay ,1));
   delay_point = find(timeVector >=  Delay_time,1);
   yStep = max([Values1,Values2])-(1-1/exp(1))*TotRange;
   tStep = timeVector(find(DataO2filtered <= yStep,1));
end
%%%%%%% rise time: time between 10%-90%
Rise_time_own = abs(t90-t10);
%%%% Time constant of the response
% Method 1) time constant: DelayLevel% to ~63.2% (= 1-1/exp(1))
Time_Constant= tStep-Delay_time;  % time to reach 63.2% reduced by delay time   
% Method 2) Time constant with fminsearch 
Dat_= DataO2filtered(delay_point:end);
tim_=timeVector(delay_point:end);
tim_=tim_-tim_(1);

% intial values for 1st order fit: 
 A = TotRange; % = abs(Values1;Values2)
tau_ = Rise_time_own/2;% initial guess as 0.5 * Rise time
D = min([Values1;Values2]); % "offset"
X0=[A,tau_,D];
options_sol = optimset('MaxFunEvals',300*length(tim_),...
   'TolFun',1e-5,'TolX',1e-5);
if iseResponseInfo % step up: y = A*(1-exp^(-t/tau)) + D
   Y=fminsearch(@(X)sum( (Dat_-(X(1)*(1-exp(-tim_/X(2)))+X(3))).^2), X0,options_sol );
%    Y=fminsearch(@(X)sum( (Dat_-(X(1)*(1-exp(-tim_/X(2)))+X(3))).^2), X0);
   fit_plot=plot(timeVector+timeVector(delay_point),...
      Y(1)*(1-exp(-timeVector/Y(2)))+Y(3),'-.','color',[0 0.5 0],'linewidth',2);
else % step down: y = A*exp^(-t/tau) + D
   Y=fminsearch(@(X)sum( (Dat_-(X(1)*exp(-tim_/X(2))+X(3))).^2), X0,options_sol );
%    Y=fminsearch(@(X)sum( (Dat_-(X(1)*exp(-tim_/X(2))+X(3))).^2), X0);
   fit_plot=plot(timeVector+timeVector(delay_point),...
      Y(1)*exp(-timeVector/Y(2))+Y(3),'-.','color',[0 0.5 0],'linewidth',2);
end

legs{end+1} = 'Fitted (1st order system)';
Time_Constant2 = Y(2); % time constant 2 
% Lines to mark certain parameters %%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%% rise times: t10,t90 and y10 y90
   hlin_param{1}=line([0 max(timeVector)], [y10 y10],'color',[0.65 0.65 0.65], 'Linestyle','--'); 
   hlin_param{end+1}=line([0 max(timeVector)], [y90 y90],'color',[0.65 0.65 0.65], 'Linestyle','--'); 
   hlin_param{end+1}=line([t10 t10], [min([Values1,Values2]) y10],'color',[0.65 0.65 0.65], 'Linestyle','--'); 
   hlin_param{end+1}=line([t90 t90], [min([Values1,Values2]) y90],'color',[0.65 0.65 0.65], 'Linestyle','--'); 
   %%%%%%% delay: time to reach Delaylevel amount of change
	if exist('extra_line','var') % removing extra line of Delaylevel
      delete(extra_line)
   end
   hlin_delay{1}=line([0 max(timeVector)], [y_delay y_delay],'color',[0.85 0.85 0.85], 'Linestyle','--'); 
   hlin_delay{end+1}=line([Delay_time Delay_time], ...
      [min([Values1,Values2]) max([Values1,Values2])],...
      'color',[0.85 0.85 0.85], 'Linestyle','--'); 
   %%%% Time constant of the response
   hlin_step{1}=line([0 max(timeVector)], [yStep yStep],'color',[0.65 0.65 0.65], 'Linestyle','--'); 
   hlin_step{end+1}=line([tStep tStep], [min([Values1,Values2]) yStep],'color',[0.65 0.65 0.65], 'Linestyle','--'); 

% Texts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   text((t90-t10)/2+t10*0.7,max([Values1,Values2]),'y(100%)','FontSize',12);
   text((t90-t10)/2+t10*0.7,min([Values1,Values2]),'y(0%)','FontSize',12);

   text((t90-t10)/2+t10*0.7,y10,'y(10%)','FontSize',11);
   text((t90-t10)/2+t10*0.7,y90,'y(90%)','FontSize',11);
   if iseResponseInfo % step up
      text((t90-t10)/2+t10*0.7,yStep,'y(~63.2%)','FontSize',11);
   else % step down: tau 63.2% change from initial 100% -> 100-63.2%
      text((t90-t10)/2+t10*0.7,yStep,'y(~36.8% (100%-63.2%))','FontSize',11);
   end

   text((t10)*0.99,y10*0.15,'t(10%)','FontSize',10);
   text((t90)*0.99,y10*0.15,'t(90%)','FontSize',10);
   text((Delay_time)*0.99,y90*0.45,'t_{d}','FontSize',10);
   text(tStep*0.99,yStep*0.45,'\tau (~63.2% change)','FontSize',10);
      

legend([hmeas, hmeasfilt, fit_plot],legs)
% disp(['Different parameters are (in sec): ',num2str([Time_Constant Time_Constant2],4)])
%%% More precise info, directly using matlab
ST = 0.01; % threshold for settling time ST -> 0.01 = 1%
StepInformation = stepinfo(DataO2filtered,timeVector,...
   'SettlingTimeThreshold',ST)
Rise_and_Settling_times_in_min=([StepInformation.RiseTime;...
   StepInformation.SettlingTime-Delay_time])/60; % delay excluded 
Rise_time=StepInformation.RiseTime;
if iseResponseInfo % step up
   htit=title([loadfilename,10,'Step up: Rise time t(10%-90%): ',...
      num2str([Rise_time],4),' s',10,...
      'Two time constants t(0.1%->63.2%) & tau from the fitted plot: ',...
      num2str([Time_Constant],4),' & ',num2str([Time_Constant2],4),' s',10,...
      'Delay t_d (time when output raise above 0.1%): ' num2str([Delay_time],4),' s'],...
      'Interpreter','none');
else
   htit=title([loadfilename,10,'Step down: Fall time t(90%-10%): ',...
      num2str([Rise_time],4),' s',10,...
      'Two time constants t(99.9%->36.2%%) & tau from the fitted plot: ',...
      num2str([Time_Constant],4),' & ',num2str([Time_Constant2],4),' s',10,...
      'Delay t_d (time when output drops below 99.9%): ' num2str([Delay_time],4),' s'],...
      'Interpreter','none');  
end

%%
htext=text(max(timeVector)/3,min([Values1,Values2])+TotRange/2,...
   'Paused: figure can be zoomed etc. Press any keyboard key to continue',...
   'Color','red','FontWeight','bold','FontSize',14);
disp('Press any keyboard key here to continue')
pause(),disp('Key pressed, continuing'), delete(htext)
axis('auto')
% title([loadfilename,10,'Rise time t(10%-90%): ',...
%    num2str([Rise_time],4),' s',10,...
%    'Time constants x2: t(0.1%-63.2%) & tau from the fitted plot ',...
%    num2str([Time_Constant],4),' & ',num2str([Time_Constant2],4),' s',10,...
%    'Delay t_d (time when output changed 0.1% from initial): ' num2str([Delay_time],4),' s'],...
%    'Interpreter','none')
%% %%%%% Saving figure and information
wantToSaveFigsAndTimes = questdlg(['Want to save the figure and defined times'],...
   'Saving ','Yes','No', options);
if strcmp(wantToSaveFigsAndTimes ,'Yes') 
   if exist('savepathname', 'var')
      [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement',savepathname);
   else
      [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement');
   end
   if exist('loadfilename','var')
      fname=[SaveDataname(1:end-4),'_DynamicalParameters_FromDATA_',loadfilename];
   else
      fname=[SaveDataname];
   end
   disp(['%%%',10,'Measurement file name: ',10,fname(1:end-4)])
   disp(['Saving location: ',10,savepathname])
   save([savepathname,fname],'Data_O2','DataO2filtered','timeVector','fname',...
      't10','t90','Rise_time_own','Rise_time','Delay_time','tStep','Time_Constant',...
      'Time_Constant2','X0','Y','StepInformation','Rise_time')   
   disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
   saveas(hparam,[savepathname,fname(1:end-4)],'fig')
   if length(fname) > 62
      saveas(hparam,[savepathname,fname(1:62)],'m')
   else
      saveas(hparam,[savepathname,fname(1:end-4)],'m')
   end
   saveas(hparam,[savepathname,fname(1:end-4)],'png')
   disp('Measurement saved to:')  
   disp([savepathname,10,'Names: ',fname(1:end-4),10,...
      '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
else
   disp('No saving')
end






