% O2RunMeas_ChangingCalibrationAndPausing.m
% To change Calibration values or pause time during O2 measurement
disp('Changing calibration and/or pause time values')
Ksv = str2num(get(H3calibValues_Ksv_button,'String'));
if isempty(Ksv)
   set(Ksv,'string','0');
   warndlg('Ksv must be numerical');
end
phi0 = str2num(get(H3calibValues_phi0_button,'String'));
if isempty(phi0)
   set(phi0,'string','0');
   warndlg('phi0 must be numerical');
end
caldevi = str2num(get(H3calibValues_caldevi_button,'String'));
if isempty(caldevi)
   set(caldevi,'string','0');
   warndlg('caldevi must be numerical');
end
calib = ['calib. param.: Ksv: ',num2str(Ksv),', phi0: ',num2str(phi0),...
   ', caldevi: ',num2str(caldevi)]; % disp(calib)
clear change_calibration
disp('New calibration values are:')
disp(calib)
pause_time = str2num(get(pause_time_button,'String'));
if isempty(pause_time)
   set(pause_time,'string','0');
   warndlg('Pause time must be numerical');
elseif pause_time < 0
   set(pause_time,'string','0');
   warndlg('Pause time must be non-negative');
end