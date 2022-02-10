%%
%MULTIPOINT CALIBRATION OF PO2-SENSOR
%
%The script gives least-square estimates for the constant phase value for
%PhiC    phase constant 
%Ksv     Stern-Volmer constant
%

%Give here the oxygen values 
po2=[0 1 5 10 19];
%And the corresponding phase values
phi=[56.67 51.62 41.55 35.85 30.32];
%
%Then we make the fit...
x=lsqcurvefit(@SV_fit,sqrt([22,.2]),phi,po2);x=x.^2;
PhiC=x(1)
Ksv=x(2)

%we substract PhiC form all phase values:
phi=phi-PhiC
%and make the SternVolmer plot

figure(1)
clf
plot(po2,phi(1)./phi,'o')
grid on;
p1=polyfit(po2,phi(1)./phi,1);
hold on
po2e1=polyval(p1,po2);
plot(po2,po2e1,'b')
xlabel('pO_2 [%]')
ylabel('\phi_0/\phi')
title('Stern_Volmer plot + the least square estimates')
text(20,1.9,strcat('\phi_C= ',num2str(PhiC))) 
text(20,1.6,strcat('K_S_V= ',num2str(Ksv)))

%Finally, let's calcultae the po2 values with Ksv abnd PhiC
disp('pO2           estimate')
disp([po2' 1./Ksv*(po2e1-1)'])