% O2DynamicalParameters_PlotParameters
% Defining parameters from the plot
   % Rise time: time it takes between 10% and 90%
   % Time constant: time from 0 (0.1) % to ~63.2% (delay excluded)
   % Delay: time that initial filtered data has reached 0.5% ?
   DelayLevel = 0.005; % 
Data_O2 = DataChosen; Data_O2(:,1) = Data_O2(:,1)-Data_O2(1,1);
legs={}; timeVector = Data_O2(:,1); close;
hparam=figure('Name','Calculating parameters','units',...
   'normalized','outerposition',[0 0 1 1]);
hmeas = plot(timeVector,Data_O2(:,2),'o','Markersize',4); hold all
legs{end+1} = 'Meas Data';
% mave
if length(timeVector) > 200
   Nmave=10;% window size
else
   Nmave=5;
   if Nmave > length(timeVector) 
      Nmave=1;
   end
end
legs{end+1} = 'Filtered Meas Data';
DataO2filtered = mave(Data_O2(:,2),Nmave);
hmeasfilt = plot(timeVector,DataO2filtered,'linewidth',3);%,'*')
% up and down dashed -- lines 
if length(timeVector) > 1000
   Nsamples=20;% how many samples to define start and stop
else
   Nsamples=10;
   if Nsamples > length(timeVector) 
      Nsamples=1;
   end
end
Values1 = median(DataO2filtered(1:Nsamples));
Values2 = median(DataO2filtered(end-Nsamples+1:end));
if Values1 < Values2
   ResponseInfo='Step up'
elseif Values1 > Values2
   ResponseInfo='Step down'
else 
   ResponseInfo='No step'
end   
hlin{1}=line([0 timeVector(end)], [Values1 Values1],...
   'color',[0.4 0.4 0.4], 'Linestyle','--');
hlin{2}=line([0 timeVector(end)], [Values2 Values2],...
   'color',[0.4 0.4 0.4], 'Linestyle','--');
chosen_Values = questdlg(['Are values (=',...
   num2str(Values1,4),' and ',num2str(Values2,4),...
   ') good for start and final values?'], ...
   'Chosen ','Yes','No', 'Yes');
% if not --> choose by mouse
while strcmp(chosen_Values ,'No') 
   if exist('hlin','var')
      delete(hlin{1}), delete(hlin{2})
   end
   title(['Taking median',10,'Use mouse to choose area for the \color{red}first value'])
   rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
   if x_val(1) < 0
      x_val(1) = 0;
   end
   if x_val(2) < 0
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
   hlin{1}=line([0 timeVector(end)], [Values1 Values1],...
      'color',[0.4 0.4 0.4], 'Linestyle','--','Linewidth',2); 
   title(['Taking median',10,'Use mouse to choose area for the \color{blue}second value'])
   rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
   if x_val(1) < 0
      x_val(1) = 0;
   end
   if x_val(2) < 0
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
   hlin{2}=line([0 timeVector(end)], [Values2 Values2],...
      'color',[0.4 0.4 0.4], 'Linestyle','--','Linewidth',2);   
   
   chosen_Values = questdlg(['Are values (=',...
      num2str(Values1,4),' and ',num2str(Values2,4),...
      ') good for start and final values?'], ...
      'Chosen ','Yes','No', 'Yes');
end

iseResponseInfo = strcmp(ResponseInfo,'Step up');
if iseResponseInfo % step up
   TotRange = Values2 - Values1; 
   y10 = 0.1*TotRange + min([Values1,Values2]);
   y90 = 0.9*TotRange + min([Values1,Values2]);
   t10 = timeVector(find(DataO2filtered >= y10,1));
   t90 = timeVector(find(DataO2filtered >= y90,1));
   y_delay = DelayLevel*TotRange + min([Values1,Values2]);
   Delay_time = timeVector(find(DataO2filtered >= y_delay ,1));
   yStep = (1-1/exp(1))*TotRange + min([Values1,Values2]);
   tStep = timeVector(find(DataO2filtered >= yStep,1));
else % step down
   TotRange = Values1 - Values2;
   y10 = 0.1*TotRange + min([Values1,Values2]);
   y90 = 0.9*TotRange + min([Values1,Values2]);
   t10 = timeVector(find(DataO2filtered >= y10));t10=t10(end);
   t90 = timeVector(find(DataO2filtered >= y90));t90=t90(end);
   y_delay = (1-DelayLevel)*TotRange + min([Values1,Values2]);
   Delay_time = timeVector(find(DataO2filtered <= y_delay ,1));
   yStep = max([Values1,Values2])-(1-1/exp(1))*TotRange;
   tStep = timeVector(find(DataO2filtered <= yStep,1));
end
% rise time
Rise_time = abs(t90-t10);
hlin_param{1}=line([0 max(timeVector)], [y10 y10],'color',[0.65 0.65 0.65], 'Linestyle','--'); 
hlin_param{end+1}=line([0 max(timeVector)], [y90 y90],'color',[0.65 0.65 0.65], 'Linestyle','--'); 
hlin_param{end+1}=line([t10 t10], [min([Values1,Values2]) y10],'color',[0.65 0.65 0.65], 'Linestyle','--'); 
hlin_param{end+1}=line([t90 t90], [min([Values1,Values2]) y90],'color',[0.65 0.65 0.65], 'Linestyle','--'); 


% delay
hlin_delay{1}=line([0 Delay_time], [y_delay y_delay ],'color',[0.85 0.85 0.85], 'Linestyle','--'); 
hlin_delay{end+1}=line([Delay_time Delay_time], [min([Values1,Values2]) y_delay ],'color',[0.85 0.85 0.85], 'Linestyle','--'); 

% Define step response, for time constant reducing delay time
% Method 1) time constant: 0.1% to ~63.2% (= 1-1/exp(1))
hlin_step{1}=line([0 tStep], [yStep yStep],'color',[0.65 0.65 0.65], 'Linestyle','--'); 
hlin_step{end+1}=line([tStep tStep], [min([Values1,Values2]) yStep],'color',[0.65 0.65 0.65], 'Linestyle','--'); 
Time_Constant= tStep-Delay_time;   

% title([loadfilename,10,'Rise time (10-90%) / Time constant / Delay (in sec)',10,...
%    num2str([Rise_time, Time_Constant, Delay_time],4)],'Interpreter','none')
% Method 2) Time constant with fminsearch: cropping initial time away
if iseResponseInfo % step up
   delay_point=find(DataO2filtered >= y_delay ,1);
else % step down
   delay_point=find(DataO2filtered <= y_delay ,1);
end
Dat_=DataO2filtered(delay_point:end);
% tim_=timeVector(1:length(Dat_));
tim_=timeVector(delay_point:end);
%%% 2
X0=sort([Values1;Values2]); % Oxygen range roughly
Y=fminsearch(@(X)sum( (Dat_-(X(1)*exp(-tim_/X(2)))).^2), X0);
legs{end+1} = 'Fitting plot to calculate time constant';
fit_plot=plot(timeVector,Y(1)*exp(-timeVector/Y(2)),'--k');
Time_Constant2 = Y(2);

% Texts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
text((t90-t10)/2+t10*0.7,max([Values1,Values2]),'y(100%)','FontSize',12);
text((t90-t10)/2+t10*0.7,min([Values1,Values2]),'y(0%)','FontSize',12);

text((t90-t10)/2+t10*0.7,y10,'y(10%)','FontSize',11);
text((t90-t10)/2+t10*0.7,y90,'y(90%)','FontSize',11);
text((t90-t10)/2+t10*0.7,yStep,'y(~63.2%)','FontSize',11);

text((t10)*0.99,y10*0.15,'t(10%)','FontSize',10);
text((t90)*0.99,y10*0.15,'t(90%)','FontSize',10);
text((Delay_time)*0.99,y10*0.15,'t_{d}','FontSize',10);
text(tStep*0.99,y10*0.15,'\tau (~63.2%)','FontSize',10);

legend([hmeas, hmeasfilt, fit_plot],legs)
disp(['Different parameters are (in sec): ',num2str([Time_Constant Time_Constant2],4)])
title([loadfilename,' Parameters (in sec)',10,'Rise time (t(10%)-t(90%)) / Time constants "tau" (x 2) / Delay',10,...
   num2str([Rise_time, Time_Constant, Time_Constant2, Delay_time],4)],...
   'Interpreter','none')
%%
htext=text(max(timeVector)/3,min([Values1,Values2])+TotRange/2,...
   'Paused: figure can be zoomed etc. Press any keyboard key to continue',...
   'Color','red','FontWeight','bold','FontSize',14);
disp('Press any keyboard key here to continue')
% pause(),
disp('Key pressed, continuing'), delete(htext)
axis('auto')

title([loadfilename,10,'Rise time (10-90%) / Time constants (x2) / Delay (in sec)',...
   10, num2str([Rise_time],4),' / ', num2str([Time_Constant, Time_Constant2],4),...
   ' / ', num2str([Delay_time],4)], 'Interpreter','none')

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
      't10','t90','Rise_time','Delay_time','tStep','Time_Constant','Time_Constant2')   
   disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
   disp('Measurement saved to:')  
   disp([savepathname,10,fname,10,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
   saveas(hparam,[savepathname,fname(1:end-4)],'fig')
   if length(fname) > 63
      saveas(hparam,[savepathname,fname(1:63)],'m')
   else
      saveas(hparam,[savepathname,fname(1:end-4)],'m')
   end
   saveas(hparam,[savepathname,fname(1:end-4)],'png')
   disp('Key pressed, continuing')
else
   disp('No saving')
end






