% O2DynamicalParameters_CroppingMore
while strcmp(wantToCrop,'No, crop more from the cropped area')
   Dtemp = DataChosen; % temp file
   clear DataChosen;
   [DataChosen, meas_start_time, meas_end_time]=O2DynamicalParameters_ChooseArea(Dtemp);
   wantToCrop= questdlg(['Is the cropped area good?'], ...
   'Cropping   ','Yes', 'No, crop more from the cropped area',...
   'No, choose another region', options);
end
if strcmp(wantToCrop,'No, choose another region')
   clear DataChosen,close
   [DataChosen, meas_start_time, meas_end_time]=O2DynamicalParameters_ChooseArea(DataO2);
   wantToCrop= questdlg(['Is the cropped area good?'], 'Cropping   ',...
      'Yes', 'No, crop more from the cropped area','No, choose another region', options);
   if strcmp(wantToCrop,'No, crop more from the cropped area')
      Crop_More=1;
   end
end
iseCropAgain = evalin( 'base', 'exist(''Crop_More'',''var'') == 1' );
if iseCropAgain
   clear Crop_More;
   O2DynamicalParameters_CroppingMore
end
