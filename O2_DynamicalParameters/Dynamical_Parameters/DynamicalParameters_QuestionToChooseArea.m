CroppingMethodChosed = 0; % 0 => no cropping, asking next
wantToCropORG = questdlg(['Want to crop the data?'], ...
   'Cropping ','Yes, with a mouse', 'Yes, manually','No','Yes, with a mouse');
if ~strcmp(wantToCropORG,'No')
   if strcmp(wantToCropORG,'Yes, with a mouse')
      CroppingMethodChosed=2;
   else % set manually
      CroppingMethodChosed=1;
   end
   [DataChosen, meas_start_time, meas_end_time] = ...
      DynamicalParameters_ChooseArea(Data, CroppingMethodChosed);
   % Asking is the cropped area good
   IsAreaGood = questdlg(['Is the cropped area good?'], ...
   'Cropping   ','Yes', 'No, crop more from the cropped area',...
   'No, choose another region', options);
else % no cropping
   DataChosen = Data;
   meas_start_time = 0; 
   meas_end_time = Data(end,1);
   IsAreaGood = 'Yes';
end
% Cropping more if necessary
DynamicalParameters_CroppingMore