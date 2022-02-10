%%
%PDMS-lätkä testejä 2.9.2016
%Na2So3 sisään hetkellä 60 s
a=load('data_2.9.2016_14_08_02.txt'); %ei PDMS
t1=a(:,1);
p1=a(:,2);
a=load('data_2.9.2016_14_52_46.txt'); %120 µm PDMS
t2=a(:,1);
p2=a(:,2);
a=load('data_2.9.2016_15_21_32.txt'); %120 µm PDMS + 1 min plasmaus + mittaus heti
t3=a(:,1);
p3=a(:,2);
a=load('data_2.9.2016_15_43_38.txt'); %120 µm PDMS + 1 min plasmaus + PVP 10 min + mittaus 
t4=a(:,1);
p4=a(:,2);
a=load('data_2.9.2016_14_13_35.txt'); %120 µm PDMS + 1 min plasmaus + PVP 10 min + mittaus 
t5=a(:,1);
p5=a(:,2);
%PDMS-lätkä testejä 16.9.2016
%Na2So3 sisään hetkellä 60 s
a=load('data_16.9.2016_16_32_09.txt'); %120 µm PDMS + 1 min plasmaus + PVP 10 min + 2 vkoa 
t6=a(:,1);
p6=a(:,2);
%mittasu katkesti -välitön jatko
a=load('data_16.9.2016_16_33_58.txt'); %120 µm PDMS + 1 min plasmaus + PVP 10 min + 2 vkoa 
t7=a(:,1);
p7=a(:,2);
t6=[t6;t6(end)+t7];p6=[p6;p7];
a=load('data_29.9.2016_12_21_59.txt'); %20 µm Wacker whole well
t8=a(:,1);
p8=a(:,2);


figure(1)
clf
kk=20;
plot(t1,p1,'-b')
grid on
hold on
plot(t2,p2,'-r')
plot(t3,p3,'-g')
plot(t4,p4,'-k')
plot(t6,p6,'-c')
plot(t8,p8,'-m')
xlabel('time [s]')
ylabel('phase [deg]')
title('pO_2 sensor response for Na_2SO_3 when different PDMS coatings are applied')
legend('no PDMS', '120 µm PDMS','120 µm PDMS + plasma','120 µm PDMS + plasma + PVP','120 µm PDMS + plasma + PVP after 2 weeks','20 µm Wacker')
axis([0 1000 25 57])

Caldevi=22.4;%laitteen oma vaihe
p21=20.5; %lähtöhappi

figure(2)
clf
i=1000; %1000 ekaa ja viimeistä pistettä kustakin käyrästä käytettän kalibraatioon
kk=20; %liikkuva ka
phi0=mean(p1(end-i:end));
phi21=mean(p1(1:i));
Ksv=(phi0-phi21)/(phi21-Caldevi)/p21;
plot(t1,mave(SternVolmerC(Ksv,phi0,p1,Caldevi),kk),'-b');
grid on
hold on
phi0=mean(p2(end-i:end));phi21=mean(p2(1:i));Ksv=(phi0-phi21)/(phi21-Caldevi)/p21;
plot(t2,mave(SternVolmerC(Ksv,phi0,p2,Caldevi),kk),'-r')
phi0=mean(p3(end-i:end));phi21=mean(p3(1:i));Ksv=(phi0-phi21)/(phi21-Caldevi)/p21;
plot(t3,mave(SternVolmerC(Ksv,phi0,p3,Caldevi),kk),'-g')
phi0=mean(p4(end-i:end));phi21=mean(p4(1:i));Ksv=(phi0-phi21)/(phi21-Caldevi)/p21;
plot(t4,mave(SternVolmerC(Ksv,phi0,p4,Caldevi),kk),'-k')
%plot(t5,mave(p5,kk),'-m')
phi0=mean(p6(end-i:end));phi21=mean(p6(1:i));Ksv=(phi0-phi21)/(phi21-Caldevi)/p21;
plot(t6,mave(SternVolmerC(Ksv,phi0,p6,Caldevi),kk),'-c')
phi0=mean(p8(end-i:end));phi21=mean(p8(1:i));Ksv=(phi0-phi21)/(phi21-Caldevi)/p21;
plot(t8,mave(SternVolmerC(Ksv,phi0,p8,Caldevi),kk),'-m')
xlabel('time [s]')
ylabel('phase [deg]')
title('pO_2 sensor response for Na_2SO_3 when different PDMS coatings are applied')
legend('no PDMS', '120 µm PDMS','120 µm PDMS + plasma','120 µm PDMS + plasma + PVP','120 µm PDMS + plasma + PVP after 2 weeks','20 µm Wacker')
axis([0 1e3 -1 22])
