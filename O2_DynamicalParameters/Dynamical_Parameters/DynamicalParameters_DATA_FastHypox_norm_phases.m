%%% 
%%
% Using_Manual_kk = 1;
% Manual_kk_number  = 5;
Is_Manual_kk = evalin( 'base', 'exist(''Using_Manual_kk'',''var'') == 1' );

if Is_Manual_kk
   Manual_kk_number = evalin( 'base', 'exist(''Manual_kk_number '',''var'') == 1' );
   if Manual_kk_number
       kk=Manual_kk_number;
   else
       kk=1;
   end
   disp(['Loaded manually kk=',num2str(kk)])
else % "for loop"
    load('kk_temp.mat')
    disp(['loaded kk=',num2str(kk),' from kk_temp.mat'])
end
    
x=vars(kk).time;
name_file=vars(kk).name;
y = vars(kk).phase_n;
disp(['Data: ',name_file])

if ~Is_Manual_kk
    if kk < length(vars)
        kk=kk+1;
        save('kk_temp','kk')
    else
        kk=1;
        save('kk_temp','kk')
    end
    disp(['Saved kk=',num2str(kk),' to kk_temp.mat'])
end
%%
% kk=1;
% get kk from temp file
% x=vars(kk).time;
% name_file=vars(kk).name;
% y = vars(kk).phase_n;
% disp(['Data: ',name_file])
% 
% if kk < length(vars)
%     kk=kk+1;
%     save('kk_temp','kk')
% else
%     kk=1;
%     save('kk_temp','kk')
% end
% Data = [x,y];
