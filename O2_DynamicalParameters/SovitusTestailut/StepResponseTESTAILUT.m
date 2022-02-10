%% run O2DynamicalParameters_PlotParameters.m first
offset =  min([Values1;Values2]); k_dc = TotRange;
y = (DataO2filtered-offset)';
t = timeVector'; % figure, plot(t,y)

zeros_amount=4;
uin=[zeros(1,zeros_amount),ones(1,length(y)-zeros_amount)]'; 
type = 'P1D';
data = iddata(y,uin,1,'InterSample','foh');
sysP1D = procest(data,type);
figure, subplot(221), compare(data,sysP1D)
subplot(222),lsim(sysP1D,uin,t) , hold all, plot(t,y,'r.')
% with meas data, interp1 so that Ts = 1
ymORG = (Data_O2(:,2)-offset);
tmORG = Data_O2(:,1);
tm = [0:max(tmORG)]';
ym = [interp1(tmORG,ymORG,tm,'pchip')]; 

uinm=[zeros(1,zeros_amount),ones(1,length(ym)-zeros_amount)]'; 
datam = iddata(ym,uinm,1,'InterSample','foh');
sysP1Dm = procest(datam,type);
subplot(223), compare(datam,sysP1Dm)
subplot(224),lsim(sysP1Dm,uinm,tm) , hold all, plot(tm,ym,'r.')
%% sys = idproc(type)
type = 'P1D';
sys_ = idproc(type);
% initial values
sys_.Kp = TotRange; % Gain
sys_.Tp1 = Time_Constant2; % time constant
sys_.Td = Delay_time/2; % delay
% sys_.InputDelay = Delay_time
sys_.initial = 'zero';
init_sys = sys_;
sys_proc = procest(data,init_sys)
figure, compare(data,sys_proc)
%% yllä, mutta input delay erikseen 1.krt luvun systeemiin
type = 'P1';
sys_ = idproc(type);
% initial values
sys_.Kp = TotRange; % Gain
sys_.Tp1 = Time_Constant2; % time constant
sys_.InputDelay = Delay_time
sys_.initial = 'zero';
init_sys = sys_;
sys_proc = procest(data,init_sys)
figure, compare(data,sys_proc)

%% MUUT VANHAT
%%
% opt.OutputOffset = offset;
opt.Display = 'on';
% opt.InitialCondition = 'zero'
sysP1D_2 = procest(data,'p1d',opt)
compare(data,sysP1D,sysP1D_2)


%% Estimate a first-order plus dead time process model.

t=timeVector;y_full=Data_O2(:,2); 
k_dc = TotRange;
offset =  min([Values1;Values2]); y = y_full-offset;

% interpolointi
t2=[0:max(t)]';
y2_full = interp1(t,y_full,t2,'pchip'); 
zeros_amount=4;
uin=[zeros(1,zeros_amount),ones(1,length(y2_full)-zeros_amount)]'; 
data = iddata(y2_full,uin,1,'InterSample','foh');
type = 'P1D';
sysP1D = procest(data,type);
compare(data,sysP1D)
lsim(sysP1D,uin,t2)
lsim(sys,u,t) , hold all, plot(t2,y2_full)

opt.OutputOffset = offset;
opt.Display = 'on';
sysP1D_2 = procest(data,'p1d',opt)
compare(data,sysP1D,sysP1D_2)

%% sys = procest(data,type,'InputDelay',InputDelay)
type2='P1';
sysP1delayed = procest(data,type2,'InputDelay',NaN)
compare(data,sysP1delayed)

%%
%       1. Create an idtf model structure SYS using this constructor.
%       2. Configure properties of SYS. Use SYS.Structure to modify the
%          parameter constraints.
%       3. Estimate parameters of SYS using TFEST:
%          SYS = TFEST(DATA, SYS, OPTIONS);
% T = getTrend(data);
% T.InputOffset = [170,50];
% T.OutputOffset = mean(data.y(1:75));
% data = detrend(data, T);
% Identify a transfer function model for the measured data using the specified delay constraints.
init_sys = idtf(NaN(1),[1, NaN(1)],'IODelay',NaN);
init_sys.Structure(1).IODelay.Free = true;
init_sys.Structure(1).IODelay.Maximum = max(timeVector)/10;
init_sys.Structure(1).IODelay.Minimum = 700;

sys2 = tfest(data,init_sys);
% sys is an idtf model containing the identified transfer function. 
compare(sys2, data) 



%%



offset = 1

% sys = procest(data,type,'InputDelay',InputDelay)
% [sys,offset] = procest(___)

%%
init_sys = idtf(NaN(1),[NaN(2)],'IODelay',NaN);
init_sys.Structure(1).IODelay.Free = true;
% init_sys.Structure(1).IODelay.Maximum = 7;




%%
%  TotRange = Values2 - Values1; 
k_dc = TotRange;
t=timeVector;y=Data_O2(:,2);
offset =  min([Values1;Values2]);

G.n

step(u*G)1


%% Load time-domain system response data and use it to estimate a transfer function.
t=timeVector;y=Data_O2(:,2);

data = iddata(y,t);
opt = tfestOptions('Display','on','SearchMethod','gna');
opt.InputOffset = [170;50];
opt.OutputOffset = mean(data.y(1:75));
opt.SearchOptions.MaxIterations = 50;
sys = tfest(data,init_sys,opt);