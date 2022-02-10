clear all
Ksv=0.185;  % 0.215
phi0=53; %55.84 , 53.3 viimeiin kalibrointi
caldevi=18.; % 18, 25,2 viimeisin kalibrointi

%[t1,phi1,amp1]=loadpO2('2017_10_01_1pros_5pros_37C.mat');
%[t2,phi2,amp2]=loadpO2('2017_10_03_Air-Zero.mat');
%[t3,phi3,amp3]=loadpO2('2017_10_04_1pros_5_pros_37C.mat');
[t4,phi4,amp4]=loadpO2('2017_10_31_0pros calib_moving_chamber_37C.mat');
%[t5,phi5,amp5]=loadpO2('2017_10_25_0pros_37C.mat');
%[t6,phi6,amp6]=loadpO2('2017_10_22_5pros_37C.mat');
%[t7,phi7,amp7]=loadpO2('2017_10_20_1pros_5minPipeOff_37C.mat');
%[t8,phi8,amp8]=loadpO2('2017_10_18_1pros_5minPipeOff_37C.mat');
%p1=SternVolmerC(Ksv,phi0,-phi1,caldevi);
%p2=SternVolmerC(Ksv,phi0,-phi2,caldevi);
%p3=SternVolmerC(Ksv,phi0,-phi3,caldevi);
p4=SternVolmerC(Ksv,phi0,-phi4,caldevi);
%p5=SternVolmerC(Ksv,phi0,-phi5,caldevi);
%p6=SternVolmerC(Ksv,phi0,-phi6,caldevi);
%p7=SternVolmerC(Ksv,phi0,-phi7,caldevi);
%p8=SternVolmerC(Ksv,phi0,-phi8,caldevi);

figure(9)
clf
%plot(t1/3600,p1,'b')
hold on; grid on
%plot(t2/3600,p2,'r')
%plot(t3/3600,p3,'g')
plot(t4/3600,p4,'k')
%plot(t5/3600,p5,'m')
%plot(t6/3600,p6,'y')
%plot(t7/3600,p7,'c')
%plot(t8/3600,p8,'k')
%legend('1','2','3','4','5')
axis([0 10 -1 23])
xlabel('time [h]')
ylabel('pO_2 [kPa]')


