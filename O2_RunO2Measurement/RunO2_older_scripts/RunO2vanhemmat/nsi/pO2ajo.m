fname=[strcat('data_',datestr(now,30)),'.mat'] % format: yyyy mm dd Thh mm ss
mm=5;
m=1e6;
phiM=zeros(m,1);
ampM=phiM;

t=phiM;
hh = figure('KeyPressFcn','keep=0'); keep = 1; % ESC [used to Stop measurement
figure(1)
clf
h1 = animatedline('Marker','o','Color','b'); % for drawing 
figure(2)
clf
h2 = animatedline('Marker','o','Color','b'); % for drawing 

% Reading data and plotting
x=1;
dt=1; %sample interval. Estimated illumination time 4s -> dt=26 + 4 lead to ~30s interval
while 2<3 % Running till the end of the worldt
    y=dos('pdamp.exe -p7 -t30 -i40 -mp -f2000 -d50 -cz koe1.mat');
    % p?-> COM port, t?-> time?, i?-> ??, ...
    load koe1.mat
    phi=mean(angle(Measurement-StopCal)/pi*180)
    amp=mean(abs(Measurement-StopCal)/pi*180)
    if x<2
        tic
        tnow=0;
        t(x)=0;
    else
        tnow=toc;
        t(x)=tnow;
    end
    phiM(x)=phi;
    ampM(x)=amp;
	addpoints(h1,tnow,phi);drawnow;
    addpoints(h2,tnow,amp);drawnow;
    %if x>mm
    %    mave(phiM(x-mm+1:x),mm)
    %end
    if x<2
        figure(1)
        grid on;
        xlabel('time [s]')
        ylabel('phase [deg]')
        figure(2)
        grid on;
        xlabel('time [s]')
        ylabel('amp [µV]')
    end
    save HappiData_muista_tallentaa t phiM ampM % MUUTA fname haluamaksesi tiedostonimeksi
    pause (dt)
    x=x+1;
    %A_phi(x,k)=phi;
 
end
%%
phiM1=nonzeros(phiM);
ampM1=nonzeros(ampM);
t1=[0;nonzeros(t)]; % save Nimi t1 

%%
figure(1)
clf
A_phi1=A_phi(1:55,:);
plot(A_phi1)
legend('0.8%','0.4%','0.2%','0.1%','0.05%','0.025%')
ylabel('phase [deg]')
xlabel('time [s]')
title('sensor performance with different PtOEPK/PS ratios')
grid

%calculations of noise
a_noise_air1=std(A_phi1(1:19,:))
a_noise_air2=std(A_phi1(38:53,:))

figure(2)
clf
plot([0.8 0.4 0.2 0.1 0.05 0.025],a_noise_air1,'o')
grid on
xlabel('PtOEPK/PS [%]')
ylabel('rms noise in air [deg]')