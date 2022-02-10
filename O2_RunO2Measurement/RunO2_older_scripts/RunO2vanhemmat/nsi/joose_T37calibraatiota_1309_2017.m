clear all
Ksv=0.2;  % 0.215
phi0=55.00; %55.84
caldevi=18.00; % 18

[t1,phi1,amp1]=loadpO2('HappiData_muista_tallentaa.mat');
%[t2,phi2,amp2]=loadpO2('2017_09_08_1pros37C.mat');
%[t3,phi3,amp3]=loadpO2('2017_09_10_1pros37C.mat');
%[t4,phi4,amp4]=loadpO2('2017_09_10_1pros37C_V2.mat');
%[t5,phi5,amp5]=loadpO2('2017_09_12_1pros37C.mat');
% p1=SternVolmerC(Ksv,phi0,-phi1,caldevi);
% p2=SternVolmerC(Ksv,phi0,-phi2,caldevi);
p3r=SternVolmerC(Ksv,phi0,-phi3,caldevi);
p4=SternVolmerC(Ksv,phi0,-phi4,caldevi);
p5=SternVolmerC(Ksv,phi0,-phi5,caldevi);

figure(2)
clf
plot(t1/3600,p1,'b')
hold on; grid on
plot(t2/3600,p2,'r')
plot(t3/3600,p3,'g')
plot(t4/3600,p4,'k')
plot(t5/3600,p5,'m')
legend('1','2','3','4','5')
axis([0 20 0 22])
xlabel('time [h]')
ylabel('pO_2 [kPa]')


