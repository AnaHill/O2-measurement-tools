%% MULTIPOINT CALIBRATION OF PO2-SENSOR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The script gives least-square estimates for the constant phase value for
   % PhiC (caldevi)   phase constant 
   % Ksv              Stern-Volmer constant
   % Typical calibration values: Ksv=0.185; phi0=53;caldevi=18; 
% developer: Hannu Välimäki
% developer (edited): Antti-Juhana Mäki
%%% Current updates (14-03-2018)
   % saving: values to .txt & .mat, and saving figures to .fig and .png
   % bugfixes: sortrows instead of sort
% Requires files: 
   % SV_fit.m
% Will save calibration values to and figures to the folder user's chooses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Choose method that is used to calculate phase from the chosen area
% Currently, two methods available to calculate the phase: 1) mean, 2) median  
CHOSEN_METHOD=2; 

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Following mainly for testing purposes
% UseKalibTestData=1; % set 1 to use TestKalibData (mainly for testing)
% if exist('UseKalibTestData', 'var') && UseKalibTestData ==1
%    if exist('TestKalibData.mat', 'file')
%       load('TestKalibData')
%    end
% end
% TestKalibData has following saturated values (manually checked)
% % O2%	Phase
% % 0	52.53
% % 1 46.36
% % 5	34.44
% % 10	28.53
% % 19	23.81
%% Get measurement file: requiring 'phiM', 'ampM','pO2M' + time variable
% checking  that you have following variables on your MATLAB workspace:
% Calibration measurement should be so that different O2 values are feeded 
   % (and you know where they are in the measurement data)
% You can 
   % A) run RunO2sensor.m and measure different O2% concentrations or 
   % B) load calibration data from a file
   % C) (manually) modify our own data  
      % If manual modification of data is needed, here are some commands to help
      % I) rename variables, e.g.: time=t; time=t_;phiM=phiM_;ampM=ampM_;pO2M=pO2M_;
      % II) if variables includes a lot of zeros -> remove from the end
         % phiM=nonzeros(phiM);ampM=nonzeros(ampM);pO2M=nonzeros(pO2M);time=[0;nonzeros(time)]; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ise = evalin( 'base', 'exist(''phiM'',''var'') == 1' );
ise2 = evalin( 'base', 'exist(''ampM'',''var'') == 1' );
ise3 = evalin( 'base', 'exist(''pO2M'',''var'') == 1' );
if ise && ise2 && ise3
   useFoundData = questdlg(['Required variables found; use them?'], ...
   'Chosen ','Yes','No, load from file', 'Yes');
   if strcmp(useFoundData ,'No, load from file')
      [FileName,PathName,FilterIndex] = uigetfile('*.mat','Pick a (.mat) calibration file.');
      load([PathName,FileName]);
   end
else
   [FileName,PathName,FilterIndex] = uigetfile('*.mat','Pick a (.mat) calibration file.');
   load([PathName,FileName]);
end
if~exist('time','var')
   if exist('t','var')
      time=t;
   elseif exist('t_','var')
      time=t_;
   else
      %error('No time variable (time, t or t_) found')
      time=0:length(pO2M)-1; artificial_time=1;
      disp('No time variable (time, t or t_) found, created one using 0:length(pO2M)-1.')
      disp('This is probably incorrect as time between points in not 1 sec.')
      disp('But it does NOT affect on calibration (only on the following subplot)')
   end
end

%% Plot measurement: phi,amp, and pO2, in one subplot 
   % O2% values here might be with older (unprober) calibration
ise = evalin( 'base', 'exist(''phiM'',''var'') == 1' );
ise2 = evalin( 'base', 'exist(''ampM'',''var'') == 1' );
ise3 = evalin( 'base', 'exist(''pO2M'',''var'') == 1' );
ise4 = evalin( 'base', 'exist(''time'',''var'') == 1' );
if ~(ise && ise2 && ise3 && ise4)
   error('Error. No required variable(s) (phiM, ampM, pO2M and/or time) found!')
end
Data_={phiM, ampM, pO2M}; colours={'r',[0 0.5 0],'b'};
MaxTime_sec=max(time);
if MaxTime_sec < 300
   time_ = time; xlabeling = ('Time (sec)');
elseif (MaxTime_sec >= 300 && MaxTime_sec < 60*60*3)
   time_ = time/60; xlabeling = ('Time (min)');
else
   time_ = time/(60*60); xlabeling = ('Time (h)');
end
figure('Name','Subplot');
for pp = 1:3
   subplot(3,1,pp), plot(time_,Data_{pp},'color',colours{pp}),
   xlabel(xlabeling)
   switch pp
      case 1
         ylabel('Phase (deg)');
         iseTime = evalin( 'base', 'exist(''artificial_time'',''var'') == 1' );
         if iseTime
            title(['Notice: time on x-axis is probly incorrect',10,...
               '(as time variable was not found originally)!'])
         end
      case 2
         ylabel('Amp (µV)');   
      case 3 % pO2 calibrated with dry gas in a certain O2% -> given in O2%
         ylabel('O_2 (%)')% ('pO_2 (kPa)');
   end   

end
%% Plot only phase to choose calibration times
close, figure('units','normalized','outerposition',[0 0 1 1],'Name','Phase');
pp = 1; plot(time_,Data_{pp},'color',colours{pp}),xlim([1 max(time_)])
xlabel(xlabeling), ylabel('Phase (deg)'); 
% title('Data: keep this figure open so that you can zoom to see if the chosen value is good')
title(['Calibration file plotted. Now in pause mode: you can zoom to see the proper values etc.',10,...
   '\color{red}Press any keyboard key to continue'])
disp('Press any keyboard key here to continue')
pause(), close
disp('Key pressed, continuing to calibration')
%% Choosing proper values 
disp('Plotting calibration data')
disp('Choose at least 2 measurement points.')
% 1) Ask user to set O2% value + choose measured phase in that p_O2
   % 1B) Plot -- line to show the value (mean/median)
   % 1C) Ask if good --> if yes, save to Calib_meas_values and go to next
      % otherwise ask to choose area again 
   % At least two points are required!
% 2) After 2 points: ask if more --> Choose again if wanted
% 3) When enough (='No') --> get p_O2 and phases
% CHOSEN_METHOD=2; % 1) mean, 2) median
Calibration_values=[]; hlin={};
% chosen_Area = 'No'; 
kk=1; 
MeasurementPoint1= inputdlg(['Calibration point #',num2str(kk), ': Insert O2% (e.g. 5)']);
Calibration_values(1,1)= str2num(MeasurementPoint1{:});
pp=1; %figure();
hfig_calib=figure('Name','Choosing phases for calibration','units',...
   'normalized','outerposition',[0 0 1 1]);
plot(Data_{pp},'color',colours{pp}),xlim([1 length(Data_{1})])
ylabel('Phase (deg)');hold all, 
title(['Choose the region of interest with a mouse',10,...
   'Calibration point #',num2str(kk),': Choose area for O2 = ',...
   num2str(Calibration_values(kk,1),2),'%'],...
   'FontSize', 16, 'Color', 'b')
rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
te=Data_{pp}(x_val(1):x_val(2)); 
te2=[mean(te), median(te)]; 

hlin{kk}=line([0 length(Data_{pp})], [te(CHOSEN_METHOD) te(CHOSEN_METHOD)],...
   'color',[0.4 0.4 0.4], 'Linestyle','--');
chosen_Area = questdlg(['Was the value (=',...
   num2str(te(CHOSEN_METHOD),4),' ) good for O2 = ',...
   num2str(num2str(Calibration_values(kk,1),2)),'%?'], ...
   'Chosen ','Yes','No', 'Yes');

while strcmp(chosen_Area ,'No') 
   title(['Draw again',10,'Calibration point #',num2str(kk),...
      ': Choose area for O2 = ',...
      num2str(Calibration_values(kk,1),2),'%'],'color','r')
   if exist('hlin','var')
      delete(hlin{kk})
   end
   rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
   te=Data_{pp}(x_val(1):x_val(2)); 
   te2=[mean(te), median(te)]; 
   hlin{kk}=line([0 length(Data_{pp})], [te2(CHOSEN_METHOD) te2(CHOSEN_METHOD)],...
      'color',[0.4 0.4 0.4], 'Linestyle','--');
   chosen_Area = questdlg(['Was the value (=',...
      num2str(te(CHOSEN_METHOD),4),' ) good for O2 = ',...
      num2str(num2str(Calibration_values(kk,1),2)),'%?'], ...
      'Chosen ','Yes','No', 'Yes');
end
Calibration_values(kk,2)= te2(CHOSEN_METHOD);
% Choose 2nd point
kk=2; % 'Calibration point #',num2str(kk),': 
MeasurementPoint2= inputdlg(['Calibration point #',num2str(kk), ': Insert O2% (e.g. 5)']);
Calibration_values(2,1)= str2num(MeasurementPoint2{:});
title(['Choose the region of interest with a mouse',10,...
   'Calibration point #',num2str(kk),': Choose area for O2 = ',...
   num2str(Calibration_values(kk,1),2),'%'],...
   'FontSize', 16, 'Color', 'b')
rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
te=Data_{pp}(x_val(1):x_val(2)); 
te2=[mean(te), median(te)]; 
hlin{kk}=line([0 length(Data_{pp})], [te(CHOSEN_METHOD) te(CHOSEN_METHOD)],...
   'color',[0.4 0.4 0.4], 'Linestyle','--');
chosen_Area = questdlg(['Was the value (=',...
   num2str(te(CHOSEN_METHOD),4),' ) good for O2 = ',...
   num2str(num2str(Calibration_values(kk,1),2)),'%?'], ...
   'Chosen ','Yes','No', 'Yes');
while strcmp(chosen_Area ,'No') 
   title(['Draw again',10,'Calibration point #',num2str(kk),...
      ': Choose area for O2 = ',...
      num2str(Calibration_values(kk,1),2),'%'],'color','r')
   if exist('hlin','var')
      delete(hlin{kk})
   end
   rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
   te=Data_{pp}(x_val(1):x_val(2)); 
   te2=[mean(te), median(te)]; 
   hlin{kk}=line([0 length(Data_{pp})], [te2(CHOSEN_METHOD) te2(CHOSEN_METHOD)],...
      'color',[0.4 0.4 0.4], 'Linestyle','--');
   chosen_Area = questdlg(['Was the value (=',...
      num2str(te(CHOSEN_METHOD),4),' ) good for O2 = ',...
      num2str(num2str(Calibration_values(kk,1),2)),'%?'], ...
      'Chosen ','Yes','No', 'Yes');
end
title(['Chosen values drawn with dashed -- lines'],'Color','k') 
Calibration_values(kk,2)= te2(CHOSEN_METHOD);
%% ask more points
choose_more_points = questdlg(['Want to define more values'], ...
   'Values','Yes','No', 'Yes');
kk=2;
while strcmp(choose_more_points ,'Yes')
   kk=kk+1;
   MeasurementPoints= inputdlg(['Calibration point #',num2str(kk), ': Insert O2%']);
   Calibration_values(kk,1)= str2num(MeasurementPoints{:});
   title(['Choose the region of interest with a mouse',10,...
      'Calibration point #',num2str(kk), ': Choose area for O2 = ',...
      num2str(Calibration_values(kk,1),2),'%'],'FontSize', 16, 'Color', 'b')
   rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
   te=Data_{pp}(x_val(1):x_val(2)); 
   te2=[mean(te), median(te)]; 
   hlin{kk}=line([0 length(Data_{pp})], [te(CHOSEN_METHOD) te(CHOSEN_METHOD)],...
      'color',[0.4 0.4 0.4], 'Linestyle','--');
   chosen_Area = questdlg(['Was the value (=',...
      num2str(te(CHOSEN_METHOD),4),' ) good for O2 = ',...
      num2str(num2str(Calibration_values(kk,1),2)),'%?'], ...
      'Chosen ','Yes','No', 'Yes');
   while strcmp(chosen_Area ,'No') 
      title(['Draw again',10,'Calibration point #',num2str(kk),...
         ': Choose area for O2 = ',...
         num2str(Calibration_values(kk,1),2),'%'],'color','r')
      if exist('hlin','var')
         delete(hlin{kk})
      end
      rect = getrect; x_val=[round(rect(1)) round(rect(1))+round(rect(3))];
      te=Data_{pp}(x_val(1):x_val(2)); 
      te2=[mean(te), median(te)]; 
      hlin{kk}=line([0 length(Data_{pp})], [te2(CHOSEN_METHOD) te2(CHOSEN_METHOD)],...
         'color',[0.4 0.4 0.4], 'Linestyle','--');
      chosen_Area = questdlg(['Was the value (=',...
         num2str(te(CHOSEN_METHOD),4),' ) good for O2 = ',...
         num2str(num2str(Calibration_values(kk,1),2)),'%?'], ...
         'Chosen ','Yes','No', 'Yes');
   end
   Calibration_values(kk,2)= te2(CHOSEN_METHOD);
   choose_more_points = questdlg(['Want to define more values'], ...
      'Values','Yes','No', 'Yes');
end
title(['Chosen values drawn with dashed -- lines'],'Color','k') 
%%
Calibration = abs(sortrows((Calibration_values)));
disp(['Chosen calibration values are: '])
disp([num2str(Calibration,4)])
% Oxygen values And the corresponding phase values
po2=Calibration(:,1); 
phi=Calibration(:,2);
% find phi0 from
if any(Calibration(:,1) == 0)
   phi0=Calibration(find(Calibration(:,1) == 0),2);
else % if no 0% in calibration measurement (not recommend!)
   phi0 = 53; % set phi0 to XX (clever guess)
end
%
%Then we make the fit...
x=lsqcurvefit(@SV_fit,sqrt([22,.2]),phi,po2);x=x.^2;
PhiC=x(1);Ksv=x(2);
%we substract PhiC form all phase values:
phi=phi-PhiC;
% fitting
p1=polyfit(po2,phi(1)./phi,1);
po2e1=polyval(p1,po2);
%and make the Stern-Volmer plot
hfig_stern=figure();clf,
plot(po2,phi(1)./phi,'.','Markersize',20), grid on; 
hold all;  plot(po2,po2e1)
xlabel('O_2 (%)')
ylabel('\phi_0/\phi')
title(['Stern-Volmer plot + the least square estimates',10,...
   '\phi_C = ',num2str(PhiC),10,'K_S_V = ',num2str(Ksv),10,...
   '\phi_0 = ',num2str(phi0)])

%Finally, let's calculate the po2 values with Ksv abnd PhiC
disp('pO2           estimate')
disp([po2 1./Ksv*(po2e1-1)])
caldevi=PhiC;
disp('Ksv, phi0 and caldevi are following:')
Defined_values_From_Calibration = [Ksv; phi0; caldevi];
disp([num2str(Defined_values_From_Calibration,4)])
% Saving
options.Resize = 'on';
options.Interpreter = 'tex';
options.Default = 'Yes';
wantToSaveFigsAndValues = questdlg(['Want to save figures and calibration values'],...
   'Saving ','Yes','No', options);
if strcmp(wantToSaveFigsAndValues ,'Yes') 
   figure(hfig_calib);
   title(['Calibration points from ',FileName(1:end-4)],'interpreter','none')
   figure(hfig_stern);
   set(hfig_stern,'units','normalized','outerposition', [0 0 1 1]);
%    title(['Stern-Volmer plot + the least square estimates for data',10,...
%       FileName(1:end-4),10,'\phi_C = ',num2str(PhiC),10,'K_S_V = ',num2str(Ksv),10,...
%       '\phi_0 = ',num2str(phi0)])
   iseSavePath = evalin( 'base', 'exist(''savepathname'',''var'') == 1' );
   if iseSavePath
      iseSavePath = ~evalin( 'base', 'savepathname == 0' );
   end
   if iseSavePath
      [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement',savepathname);
   else
      [SaveDataname, savepathname] = uiputfile({'*.mat';'*.*'}, 'Saving measurement');
   end
   if exist('FileName','var')
      fname=[SaveDataname(1:end-4),'_CalibrationFrom_',FileName];
   else
      fname=[SaveDataname];
   end
   disp(['%%%',10,'Measurement file name: ',10,FileName(1:end-4)])
   disp(['Saving location: ',10,savepathname])
   fileID = fopen([savepathname,fname(1:end-4),'.txt'],'w');
   fprintf(fileID,'%6.8f\n',Defined_values_From_Calibration);
   fclose(fileID);
   disp(['Values saved to ',fname(1:end-4),'.txt',' in ',10,savepathname])
   Ksv=Defined_values_From_Calibration(1);
   phi0=Defined_values_From_Calibration(2);
   caldevi=Defined_values_From_Calibration(3);
   save([savepathname,fname],'Defined_values_From_Calibration','Ksv','phi0',...
      'caldevi')   
   disp('% Saving %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
   saveas(hfig_calib,[savepathname,fname(1:end-4),'_Calib'],'fig')
   saveas(hfig_calib,[savepathname,fname(1:end-4),'_Calib'],'png')
   saveas(hfig_stern,[savepathname,fname(1:end-4),'_Stern'],'fig')
   saveas(hfig_stern,[savepathname,fname(1:end-4),'_Stern'],'png')
   disp('Measurement saved to:')  
   disp([savepathname,10,fname,10,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
else
   disp('No saving')
end




