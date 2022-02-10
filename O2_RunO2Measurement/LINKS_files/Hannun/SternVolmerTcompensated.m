function [ pO2 ] = SternVolmerTcompensated(Ksv,phi0,phi,phiC,T)
% [ pO2 ] = SternVolmer(Ksv,phi0,phi)

phi=phi-phiC;
Ksv=8.61e-3*T+2.93e-3;
phi0=57.8-0.068*T;
phi0=phi0-phiC;
pO2=1./Ksv*(phi0./phi-1);


end

