h = gcf; %current figure handle
% The data that is plotted is usually a 'child' of the Axes object. 
% The axes objects are themselves children of the figure. 
% You can go down their hierarchy as follows:
axesObjs = get(h, 'Children');  %axes handles
dataObjs = get(axesObjs, 'Children'); %handles to low-level graphics objects in axes

% Extract values from the dataObjs of your choice. 
% You can check their type by typing:
% objTypes = get(dataObjs, 'Type');  %type of low-level graphics object
% NOTE : Different objects like 'Line' and 'Surface' will store data differently. Based on the 'Type', you can search the documentation for how each type stores its data.

% Lines of code similar to the following would be required to 
% bring the data to MATLAB Workspace:
% xdata = get(dataObjs, 'XData');  %data from low-level grahics objects
% ydata = get(dataObjs, 'YData');
% zdata = get(dataObjs, 'ZData');
for kk = 1:length(dataObjs)
   dataType{kk} = get(dataObjs{kk}, 'Type');
   if any(strcmp(dataType{kk}(:), 'line'))
      Line_number = kk;
   end
end

%% Choose parameters you want to change
dataObjs{Line_number}(:) % see list of data

% data_to_change = [1:3]; % which data
data_to_change = [1:3]; % which data

data_to_change = [length(dataObjs{Line_number}(:)):-1:length(dataObjs{Line_number}(:))-5+1]

%%
for kk = 1:length(data_to_change)
   dataObjs{Line_number}(data_to_change(kk)).LineStyle = '-';
   dataObjs{Line_number}(data_to_change(kk)).Marker= 'none';
   dataObjs{Line_number}(data_to_change(kk)).MarkerSize= 10;
end


%% From end
montako = 5;
data_to_change = [length(dataObjs{Line_number}(:)):-1:length(dataObjs{Line_number}(:))-5+1]
%%
for kk = 1:length(data_to_change)
   dataObjs{Line_number}(data_to_change(kk)).LineStyle = 'none';
   dataObjs{Line_number}(data_to_change(kk)).Marker= '.';
   dataObjs{Line_number}(data_to_change(kk)).MarkerSize= 10;
end
