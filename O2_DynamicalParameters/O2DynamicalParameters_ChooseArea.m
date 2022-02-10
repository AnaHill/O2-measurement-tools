function [DataOut_MeasurementTime,start_time, end_time] = O2DynamicalParameters_ChooseArea(DataToCrop, CroppingMethod)
% O2DynamicalParameters_ChooseArea Choosing area from the measurement file
% CroppingMethod: 0 --> ask, 1 = manual, 2 = mouse
switch nargin
   case 2 % use croppingmethod
      CroppingMethodChosed = CroppingMethod;
   case 1 % no cropping method chosen previously --> ask
      CroppingMethodChosed = 0;
   otherwise
      errordlg('Input error')
 end
if CroppingMethodChosed == 2
   HowToChooseArea = 'Mouse';
elseif CroppingMethodChosed == 1
    HowToChooseArea = 'Set range manually';
else
  HowToChooseArea = questdlg(['Choose region by mouse or type range (e.g. 10 40)?'], ...
   'Choosing area','Mouse','Set range manually', 'Mouse');
end
if strcmp(HowToChooseArea,'Mouse') 
   title(['Choose the region of interest with a mouse'],...
      'FontSize', 16, 'Color', 'b')
   rect = getrect; 
   x_val=[(rect(1)) (rect(1))+(rect(3))];
   if x_val(1) < 0
      x_val(1) = 0;
   end
   if x_val(2) < 0
      x_val(2) = 1;
   end
   if x_val(1) >= max(DataToCrop(:,1))
      x_val(1) = DataToCrop(end-1,1);
   end
   if x_val(2) > max(DataToCrop(:,1))
     x_val(2) = max(DataToCrop(:,1));
   end
else % choosing manually range
   dlg_title = ['Choose range'];
   prompt = {['Insert time range (in sec), only values between 0 and max measurement time',10,...
      'E.g. Setting 100 200 results data between 100 sec and 200 sec']};
   num_lines = 1;
   defaultans = {''};
   answer_range = inputdlg(prompt,[dlg_title],num_lines,defaultans);    
   range = str2num(answer_range{:}); 
   x_val=[range(1) range(2)];x_val = sort(x_val);
   if x_val(1) < 0
      x_val(1) = 0; disp('Negative first value typed. Changing to 0.')
   end
   if x_val(2) < 0
      x_val(2) = 1; disp('Negative second value typed. Changing to 1.')
   end
   if x_val(1) >= max(DataToCrop(:,1))
      x_val(1) = DataToCrop(end-1,1); 
      disp('First typed value larger than maximum measurement time. Changing to max(measurement time) - 1.')
   end
   if x_val(2) > max(DataToCrop(:,1))
      x_val(2) = max(DataToCrop(:,1));
      disp('Second typed value larger than maximum measurement time. Changing to max(measurement time).')
   end
end
start_point = find((DataToCrop(:,1)) >= x_val(1),1);
start_time = DataToCrop(start_point,1);
end_point = find((DataToCrop(:,1)) >= x_val(2),1);
end_time = DataToCrop(end_point,1);

DataOut_MeasurementTime=[DataToCrop(start_point:end_point,1),...
   DataToCrop(start_point:end_point,2)];

fighandles = findall( allchild(0), 'type', 'figure');
if length(fighandles) > 1
   close(figure(fighandles(1)))
end
hfigChosen=figure('Name','Chosen region','units',...
   'normalized','outerposition',[0 0 1 1]);
plot(DataOut_MeasurementTime(:,1),DataOut_MeasurementTime(:,2)) 

