init_sys = idtf(NaN(1,2),[1,NaN(1,3)],'IODelay',NaN);
init_sys.Structure(1).IODelay.Free = true;
init_sys.Structure(1).IODelay.Maximum = 7;

% init_sys is an idtf model describing the structure of the transfer function from one input to the output. The transfer function consists of one zero, three poles and a transport delay. The use of NaN indicates unknown coefficients.
% 
% init_sys.Structure(1).IODelay.Free = true indicates that the transport delay is not fixed.
% 
% init_sys.Structure(1).IODelay.Maximum = 7 sets the upper bound for the transport delay to 7 seconds.
% 
% Specify the transfer function from both inputs to the output.

init_sys = [init_sys,init_sys];

load co2data;
Ts = 0.5; 
data = iddata(Output_exp1,Input_exp1,Ts);
opt = tfestOptions('Display','on','SearchMethod','gna');
opt.InputOffset = [170;50];
opt.OutputOffset = mean(data.y(1:75));
opt.SearchOption.MaxIter = 50;
sys = tfest(data,init_sys,opt);

%%
TotRange = Values2 - Values1; 
t=timeVector;y=Data_O2(:,2);
offset =  min([Values1;Values2]);

% init_sys = % [init_sys,init_sys];
t=timeVector;y=Data_O2(:,2);

% init_sys = idtf(k_dc,[Time_Constant2,NaN(1,1)],'IODelay',NaN);


init_sys = idtf(TotRange,[Time_Constant2,1],'IODelay',NaN);
init_sys.Structure(1).IODelay.Free = true;

data = iddata(y,t);
opt = tfestOptions('Display','on','SearchMethod','gna');
opt.InputOffset = -offset;% mean(data.y(1:75));
% opt.OutputOffset = mean(data.y(1:75));
opt.SearchOption.MaxIter = 50;
sys = tfest(data,init_sys,opt);
figure, compare(data,sys)

%% 
TotRange = abs(Values2 - Values1);
t=timeVector;y=Data_O2(:,2);
offset =  min([Values1;Values2]);

init_sys = idtf(NaN(1),[1,NaN(1)],'IODelay',NaN);
init_sys.Structure(1).IODelay.Free = true;

data = iddata(y,t);
opt = tfestOptions('Display','on','SearchMethod','gna');
opt.InitialCondition = 'auto';
opt.InputOffset = offset/TotRange;% mean(data.y(1:75));
opt.OutputOffset = opt.InputOffset;%mean(data.y(1:75));
opt.SearchOption.MaxIter = 50;
sys = tfest(data,init_sys,opt);
figure, compare(data,sys)


%% tf without delay: tf(1st order) + OFFSET
TotRange = abs(Values2 - Values1); 
t=timeVector;y=Data_O2(:,2);
offset =  min([Values1;Values2]);
s = tf('s');
%  G = TotRange/(Time_Constant2*s+1); opt = stepDataOptions('InputOffset',offset/TotRange);
% G = TotRange/(Time_Constant2*s+1); opt = stepDataOptions('InputOffset',-offset);
G = TotRange/(Time_Constant2*s+1) + offset;opt = stepDataOptions('InputOffset',0);
[ys,tss] = step(G,opt); figure, step(G,opt)
%% tf with delay: tf(1st order)
t=timeVector;y_full=Data_O2(:,2); % 
figure(10), subplot(331), plot(t,y_full)
offset =  min([Values1;Values2]);
y=y_full-offset %  
figure(10), subplot(332), plot(t,y)
TotRange = abs(Values2 - Values1); 
kk = 3;
tc_init = mean([Time_Constant,Time_Constant2]);
init_sys = idtf(NaN(1),[tc_init,1],'IODelay',NaN);
init_sys.Structure.IODelay.Free = true;
% data = iddata(y,t);% figure, plot(t,y)
t2=0:max(t);y2 = interp1(t,y,t2,'pchip');
figure(10), subplot(3,3,kk), plot(t2,y2), kk=kk+1
data = iddata(y2',t2');% figure, plot(t,y)


opt = tfestOptions('Display','on','SearchMethod','gna');
opt.InitialCondition = 'auto';
opt.InputOffset = offset/TotRange;% mean(data.y(1:75));
% opt.OutputOffset = opt.InputOffset;%mean(data.y(1:75));
opt.SearchOption.MaxIter = 50;
sys = tfest(data,init_sys,opt);
figure(10),subplot(3,3,kk), compare(data,sys),kk=kk+1

%% Process model estimation using the app: Identification -> process models
% For nonuniformly sampled data, Ts is [], and the value of the SamplingInstants property is a column vector containing individual time values. For example:
TotRange = abs(Values2 - Values1); 
t=timeVector;y=Data_O2(:,2);
offset =  min([Values1;Values2]);
t=timeVector;y_full=Data_O2(:,2); % 
% figure(10), subplot(331), plot(t,y_full)
offset =  min([Values1;Values2]);
y=y_full-offset; %  
t2=0:max(t);t2=t2';y2 = interp1(t,y,t2,'pchip');
y2_full = interp1(t,y_full,t2,'pchip');
u=[0,ones(1,length(y2)-1)]';
data = iddata(y2,u,1)
% data = iddata(y,u,[],'SamplingInstants',TimeVector)
%%% Improved data
data2A = iddata(y2,u,1,'InterSample','foh')
data2 = iddata(y2,u,1,'InterSample','foh')
% data2 = detrend(data2A)
%% SIMULINK
t_delay_init = 1500
Tau = 3700
unit_step_input = timeVector >= 0;
