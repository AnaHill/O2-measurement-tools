% Defining parameters from the plot
% ANNA data: Data_O2 pitää sisältää aika (sek) ja O2 arvot
% Data_O2 = DataChosen; 
load('C:\Local\maki9\Data\COMSOL\O2\O2Models_2018\Kokomittaus_Hypoxia_0,1,5pros\Hypoxia_0_1_5pros.mat')
for kk = 2% 1:3
   if kk == 1
      Data_ = [t0,Oxy0pros]; %Data_ = [t1(1:1e3),Oxy1pros(1:1e3)]; 
      TiedostoNimi='O2pros0';
   elseif kk == 2
      Data_ = [t1,Oxy1pros]; 
      TiedostoNimi='O2pros1'; 
   else
      Data_ = [t5,Oxy5pros]; 
      TiedostoNimi='O2pros5';
   end
% Cropped
figure('units','normalized','outerposition',[0 0 1 1]);
plot(Data_(:,1), Data_(:,2))
[Data_O2,start_time, end_time] = ...
   O2DynamicalParameters_ChooseArea(Data_ );
   % Rise time tr: time it takes between 10% and 90%
   % Delay td: time that initial filtered data has changed DelayLevel % (0.1%?)
      % Defined by variable DelayLevel
   % Time constant: Two methods used:
      % time from td to ~63.2% (delay excluded)
      % 1st order fitting to data from td to end
% Parameters to change   
   DelayLevel = 0.001; % 0.001 = 0.1 % from the dashed region up(or downn)
   filt_method = 2; % Choose Filter method, 1 = mave, 2 = sgolay
   Method_to_take_max_and_min_values = 1; % way to get 0% and 100% values
       % 1) = median, 2) = mean
   
%%%%%%%%%
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
else
   Nmave=5; Nsgolay = 9;
   if Nmave > length(timeVector) 
      Nmave=1; Nsgolay = 3;
   end
end
% Method 1 using mave
DataO2filtered_own = mave(Data_O2(:,2),Nmave);
% Method 2: matlab sqolay
DataO2filtered_sgolay = sgolayfilt(Data_O2(:,2),1,19); % 

switch filt_method
   case 1 % own moving average mvave
      DataO2filtered =DataO2filtered_own;
      legs{end+1} = 'Meas Data, filtered (own)';
   case 2 % sgolay
      DataO2filtered =DataO2filtered_sgolay;
      legs{end+1} = 'Meas Data, filtered (sgolay)';
end
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
   htext=text(max(timeVector)/3,min([Values1,Values2])+abs(Values2 - Values1)/2,...
   'Use mouse to choose area for the \color{red}first value',...
   'Color','red','FontWeight','bold','FontSize',14);
   rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
   delete(htext)
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
   htext=text(max(timeVector)/3,min([Values1,Values2])+abs(Values2 - Values1)/2,...
   'Use mouse to choose area for the second value',...
   'Color','blue','FontWeight','bold','FontSize',14);
   rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
	delete(htext)
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
   %%%%%%% delay: time to reach Delaylevel amount of change   
   y_delay = DelayLevel*TotRange + min([Values1,Values2]);
%    DatTempo = mave(DataO2filtered ,5);Delay_time = timeVector(find(DatTempo >= y_delay ,1));
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
%    DatTempo = mave(DataO2filtered ,5);Delay_time = timeVector(find(DatTempo <= y_delay ,1));
   Delay_time = timeVector(find(DataO2filtered <= y_delay ,1));
   delay_point = find(timeVector >=  Delay_time,1);
   yStep = max([Values1,Values2])-(1-1/exp(1))*TotRange;
   tStep = timeVector(find(DataO2filtered <= yStep,1));
end
%%%%%%% rise time: time between 10%-90%
Rise_time = abs(t90-t10);
%%%% Time constant of the response
% Method 1) time constant: DelayLevel% to ~63.2% (= 1-1/exp(1))
Time_Constant= tStep-Delay_time;  % time to reach 63.2% reduced by delay time   
% Method 2) Time constant with fminsearch % MITÄ ARVOA KÄYTETÄÄN, mittaus vai
% filtteröity?
% Dat_= Data_O2(delay_point:end,2);
Dat_= DataO2filtered(delay_point:end);
tim_=timeVector(delay_point:end);
tim_=tim_-tim_(1);
% intial values for 1st order fit: 
A = TotRange; % = abs(Values1;Values2)
tau_ = Rise_time/2;% initial guess as 0.5 * Rise time
D = min([Values1;Values2]);
X0=[A,tau_,D];
options_sol = optimset('MaxFunEvals',300*length(tim_),...
   'TolFun',1e-5,'TolX',1e-5);
% if iseResponseInfo % step up: y = A*exp^(-t/tau) + D
% %    Y=fminsearch(@(X)sum( (Dat_-(X(1)*exp(-tim_/X(2))+X(3))).^2), X0,options_sol );
%    Y=fminsearch(@(X)sum( (Dat_-(X(1)*exp(-tim_/X(2))+X(3))).^2), X0);
%    fit_plot=plot(timeVector+timeVector(delay_point),...
%       Y(1)*exp(-timeVector/Y(2))+Y(3),'-.','color',[0 0.5 0],'linewidth',2);
% else % step down: y = A*(1-exp^(-t/tau)) + D
% %    Y=fminsearch(@(X)sum( (Dat_-(X(1)*(1-exp(-tim_/X(2)))+X(3))).^2), X0,options_sol );
%    Y=fminsearch(@(X)sum( (Dat_-(X(1)*(1-exp(-tim_/X(2)))+X(3))).^2), X0);
%    fit_plot=plot(timeVector+timeVector(delay_point),...
%       Y(1)*(1-exp(-timeVector/Y(2)))+Y(3),'-.','color',[0 0.5 0],'linewidth',2);
% end
if iseResponseInfo % step up: y = A*(1-exp^(-t/tau)) + D
%    Y=fminsearch(@(X)sum( (Dat_-(X(1)*(1-exp(-tim_/X(2)))+X(3))).^2), X0,options_sol );
   Y=fminsearch(@(X)sum( (Dat_-(X(1)*(1-exp(-tim_/X(2)))+X(3))).^2), X0);
   fit_plot=plot(timeVector+timeVector(delay_point),...
      Y(1)*(1-exp(-timeVector/Y(2)))+Y(3),'-.','color',[0 0.5 0],'linewidth',2);
else % step down: y = A*exp^(-t/tau) + D
%    Y=fminsearch(@(X)sum( (Dat_-(X(1)*exp(-tim_/X(2))+X(3))).^2), X0,options_sol );
   Y=fminsearch(@(X)sum( (Dat_-(X(1)*exp(-tim_/X(2))+X(3))).^2), X0);
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
   text((t90-t10)/2+t10*0.7,yStep,'y(~63.2%)','FontSize',11);

   text((t10)*0.99,y10*0.15,'t(10%)','FontSize',10);
   text((t90)*0.99,y10*0.15,'t(90%)','FontSize',10);
   text((Delay_time)*0.99,y90*0.45,'t_{d}','FontSize',10);
   text(tStep*0.99,yStep*0.45,'\tau (~63.2%)','FontSize',10);

legend([hmeas, hmeasfilt, fit_plot],legs)
disp(['Different parameters are (in sec): ',num2str([Time_Constant Time_Constant2],4)])
title([TiedostoNimi,' Parameters (in sec)',10,'Rise time (t(10%)-t(90%)) / Time constants "tau" (x 2) / Delay',10,...
   num2str([Rise_time, Time_Constant, Time_Constant2, Delay_time],4)],...
   'Interpreter','none')
%%
htext=text(max(timeVector)/3,min([Values1,Values2])+TotRange/2,...
   'Paused: figure can be zoomed etc. Press any keyboard key to continue',...
   'Color','red','FontWeight','bold','FontSize',14);
disp('Press any keyboard key here to continue')
pause(),disp('Key pressed, continuing'), delete(htext)
axis('auto')

title([TiedostoNimi,10,'Rise time (10-90%) / Time constants (x2) / Delay (in sec)',...
   10, num2str([Rise_time],4),' / ', num2str([Time_Constant, Time_Constant2],4),...
   ' / ', num2str([Delay_time],4)], 'Interpreter','none')
%% %%%%% Saving figure and information
wantToSaveFigsAndTimes = questdlg(['Want to save the figure and defined times'],...
   'Saving ','Yes','No', 'Yes');
if strcmp(wantToSaveFigsAndTimes ,'Yes') 
   if exist('savepathname', 'var')
      [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement',savepathname);
   else
      [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement');
   end
   fname=[SaveDataname(1:end-4),'_DynamicalParameters_FromDATA_',TiedostoNimi];
   disp(['%%%',10,'Measurement file name: ',10,fname(1:end-4)])
   disp(['Saving location: ',10,savepathname])
   save([savepathname,fname],'Data_O2','DataO2filtered','timeVector','fname',...
      't10','t90','Rise_time','Delay_time','tStep','Time_Constant',...
      'Time_Constant2','X0','Y')   
   disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
   disp('Measurement saved to:')  
   disp([savepathname,10,fname,10,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
   saveas(hparam,[savepathname,fname],'fig')
   saveas(hparam,[savepathname,fname],'png')
else
   disp('No saving')
end




end

