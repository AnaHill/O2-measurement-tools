function pO2=phase2po2(phi,phi0,phi_air,pO2_air)
%
%pO2=phase2po2(phi,phi0,phi_air,pO2air)
%
%Calculates pO2 values based on phase difference and calibration values
%
%Input phi  (can be vector)    phase values (deg)
%      phi0                    phase when no oxygen
%      phi_air                 phase in air (def 100% humidity) i.e. 20.30%
%      pO2_air  optional       pO2 in when measuring phi_air
%
%H Välimäki 24.3.2016
%

if nargin<4
    pO2_air=20.30;
end

%Calculating Ksv
p=polyfit([0 pO2_air],[1 phi0/phi_air],1);
Ksv=p(1);

%Calculating pO2
pO2=SternVolmer(Ksv,phi0,phi);