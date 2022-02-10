DataO2filtered_sgolay5 = sgolayfilt(Data_O2(:,2),1,5); % 
DataO2filtered_sgolay19 = sgolayfilt(Data_O2(:,2),1,19); % 
DataO2filtered_sgolay41 = sgolayfilt(Data_O2(:,2),1,41); % 
% smooth
DataO2filtered_smooth_sgolay = smooth(Data_O2(:,2),'sgolay');
coef_loess=0.01;
DataO2filtered_smooth_rloess001 = smooth(timeVector,Data_O2(:,2),coef_loess,'loess');

%%
% legu={};
% figure('units','normalized','outerposition',[0 0 1 1]);
% plot(timeVector,Data_O2(:,2),'o','color',[0.8 0.8 0.8]), hold all, 
% hown=plot(timeVector,DataO2filtered_own,'--b');legu{1}=['own, wind = ',num2str(Nmave)];
% hsgo41 = plot(timeVector,DataO2filtered_sgolay41,':k');legu{end+1}='sgo41';
% 
% hsgo19=plot(timeVector,DataO2filtered_sgolay19);legu{end+1}='sgo19';
% hsgo5=plot(timeVector,DataO2filtered_sgolay5);legu{end+1}='sgo5';
% 
% % smooth
% 
% 
% legend([hown,hsgo41, hsgo19,hsgo5],legu)
% title([loadfilename],'interpreter','none')
figure('units','normalized','outerposition',[0 0 1 1]);
legu={};hfigu={};
plot(timeVector,Data_O2(:,2),'x','color',[0.4 0.4 0.4]), hold all, 
% hfigu{end+1}=plot(timeVector,DataO2filtered_own,'--b');legu{end+1}=['own, wind = ',num2str(Nmave)];
% hfigu{end+1} = plot(timeVector,DataO2filtered_sgolay41,':k');legu{end+1}='sgo41';
% hfigu{end+1} = plot(timeVector,DataO2filtered_sgolay19);legu{end+1}='sgo19';
hfigu{end+1} = plot(timeVector,DataO2filtered_sgolay5);legu{end+1}='sgo5';

% smooth
hfigu{end+1} = plot(timeVector,DataO2filtered_smooth_sgolay);legu{end+1}='smooth_sgo';

hfigu{end+1} = plot(timeVector,DataO2filtered_smooth_rloess001);legu{end+1}='smooth_loess001';


legend([hfigu{:}],legu)
title([loadfilename],'interpreter','none')

%% Info
ST = 0.005; % threshold for settling time ST
s = lsiminfo(DataO2filtered_smooth_rloess001,timeVector,...
   'SettlingTimeThreshold',ST)%,DataO2filtered_smooth_rloess001(end))
S2 = stepinfo(DataO2filtered_smooth_rloess001,timeVector,...
'SettlingTimeThreshold',ST)
Rise_and_Settling_times_in_min=([S2.RiseTime;S2.SettlingTime-Delay_time])/60; % delay excluded 
% Tangent
temp_diff=diff(DataO2filtered_smooth_rloess001);
figure, plot(timeVector(1:end-1),temp_diff)
%% Sovitus
% A = TotRange; tau_ = Rise_time/2;D = min([Values1;Values2]);X0=[A,tau_,D];
% options_sol = optimset('MaxFunEvals',300*length(tim_),...
%    'TolFun',1e-5,'TolX',1e-5);
% % Dat_= Data_O2(delay_point:end,2);
% Dat_= DataO2filtered_sgolay19(delay_point:end);
% tim_=timeVector(delay_point:end);
% tim_=tim_-tim_(1);
% 
% 
% if ~iseResponseInfo % step up: y = A*exp^(-t/tau) + D
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

