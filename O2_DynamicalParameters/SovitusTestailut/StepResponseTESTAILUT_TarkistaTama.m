init_sys = idtf(NaN(1,2),[1, NaN(1,3)],'IODelay',NaN);
init_sys.Structure(1).IODelay.Free = true;
init_sys.Structure(1).IODelay.Maximum = 7;

% init_sys is an idtf model describing the structure of the transfer function from one input to the output. The transfer function consists of one zero, three poles and a transport delay. NaN indicates unknown coefficients.
% 
% init_sys.Structure(1).IODelay.Free = true indicates that the transport delay is not fixed.
% 
% init_sys.Structure(1).IODelay.Maximum = 7 sets the upper bound for the transport delay to 7 seconds.
% 
% Specify the transfer function from both inputs to the output.

init_sys = [init_sys,init_sys];

% Load time-domain system response data and detrend the data.

load co2data;
Ts = 0.5; 
data = iddata(Output_exp1,Input_exp1,Ts);
T = getTrend(data);
T.InputOffset = [170,50];
T.OutputOffset = mean(data.y(1:75));
data = detrend(data, T);
% Identify a transfer function model for the measured data using the specified delay constraints.
sys = tfest(data,init_sys);
% sys is an idtf model containing the identified transfer function. 
compare(sys, data)


data2 = iddata(Output_exp1,Input_exp1,Ts);
T = getTrend(data2);
% T.InputOffset = [170,50];
% T.OutputOffset = mean(data.y(1:75));
% data = detrend(data, T);
% Identify a transfer function model for the measured data using the specified delay constraints.
sys2 = tfest(data2,init_sys);
% sys is an idtf model containing the identified transfer function. 
compare(sys2, data2)