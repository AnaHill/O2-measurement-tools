% O2Plotting_LoadData: Loading data from a file for plotting
disp('Plotting O2 data from a file')
ise = evalin( 'base', 'exist(''DataToPlot'',''var'') == 1' );
if ise
   clear DataToPlot
end
ise = evalin( 'base', 'exist(''RawData_time_phase_O2'',''var'') == 1' );
if ise
   clear RawData_time_phase_O2
end
ise = evalin( 'base', 'exist(''phiM_'',''var'') == 1' );
ise2 = evalin( 'base', 'exist(''ampM_'',''var'') == 1' );
ise3 = evalin( 'base', 'exist(''pO2M_'',''var'') == 1' );
ise4 = evalin( 'base', 'exist(''t_'',''var'') == 1' );
if ise && ise2 && ise3 && ise4
   clear phiM_ ampM_ pO2M_ t_
end
ise = evalin( 'base', 'exist(''phiM'',''var'') == 1' );
ise2 = evalin( 'base', 'exist(''ampM'',''var'') == 1' );
ise3 = evalin( 'base', 'exist(''pO2M'',''var'') == 1' );
ise4 = evalin( 'base', 'exist(''t'',''var'') == 1' );
if ise && ise2 && ise3 && ise4
   clear phiM ampM pO2M t
end

[filename, pathname] = uigetfile({'*.mat', ' .mat  file';},...
   'Pick a file');
load([pathname,filename]);
disp('Read files from')  
disp([pathname,filename])
iseRaw = evalin( 'base', 'exist(''RawData_time_phase_O2'',''var'') == 1' );
if iseRaw
   t_=RawData_time_phase_O2(:,1)-RawData_time_phase_O2(1,1);
   phiM_ = RawData_time_phase_O2(:,2);
   ampM_ = rand(1,length(t_)); % no Amp was saved in cropped data
   DataToPlot{1}=RawData_time_phase_O2(:,2);
   DataToPlot{2}=zeros(1,length(ampM_));
   DataToPlot{3}=RawData_time_phase_O2(:,3);
   pO2M_ = RawData_time_phase_O2(:,3);
   time = t_; disp('RawData_time_phase_O2 found, using time vector from first column.')
else
   % Check if phiM or phiM_ (and other) exist
   ise = evalin( 'base', 'exist(''phiM_'',''var'') == 1' );
   ise2 = evalin( 'base', 'exist(''ampM_'',''var'') == 1' );
   ise3 = evalin( 'base', 'exist(''pO2M_'',''var'') == 1' );
   if ise && ise2 && ise3
      DataToPlot={phiM_, ampM_, pO2M_};
      disp('phiM_, ampM_, and pO2M_ found.')
   else
      iseB = evalin( 'base', 'exist(''phiM'',''var'') == 1' );
      iseB2 = evalin( 'base', 'exist(''ampM'',''var'') == 1' );
      iseB3 = evalin( 'base', 'exist(''pO2M'',''var'') == 1' );
      if iseB && iseB2 && iseB3
         DataToPlot={phiM, ampM, pO2M};
         disp('phiM, ampM, and pO2M found.')
      end
   end
   ise4 = evalin( 'base', 'exist(''t_'',''var'') == 1' );
   ise5 = evalin( 'base', 'exist(''t'',''var'') == 1' );
   if ise4
      time=t_; disp('t_ found, using that as time vector.')
   elseif ise5 
      time = t; disp('t found, using that as time vector.')
   else
      time=0:length(DataToPlot{1})-1; 
      disp('No time vector found, creating with 0:length(DataToPlot{1})-1')
      disp('This is probably incorrect time vector!!!')
   end
end
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


Data_={phiM_, ampM_, pO2M_};% time=t_;
colours={'r',[0 0.5 0],'b'};
ise = evalin( 'base', 'exist(''time_unit'',''var'') == 1' );
if ~ise % create max_time in not exist
   MaxTime_sec=max(time);
   if MaxTime_sec < 300
      time_ = time; xlabeling = ('Time (sec)'); time_unit=1;
   elseif (MaxTime_sec >= 300 && MaxTime_sec < 60*60*3)
      time_ = time/60; xlabeling = ('Time (min)');time_unit=2;
   else
      time_ = time/(60*60); xlabeling = ('Time (h)'); time_unit=3;
   end
else
   switch time_unit
      case 1   
         time_ = time;
      case 2
         time_ = time/60; 
      case 3
         time_ = time/(60*60);
   end
end