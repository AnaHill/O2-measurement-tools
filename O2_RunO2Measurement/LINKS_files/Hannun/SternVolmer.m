function [ pO2 ] = SternVolmerCorrected(Ksv,phi0,phi,phiC)
% [ pO2 ] = SternVolmer(Ksv,phi0,phi,phiC)
%Input  Ksv
%       phi0 phase at zero [O2]
%       phi  phase at unknown [O2]
%       phiC constant phase due to electronics
%Output [pO2] oxygen knonsetration

phi0=phi0-phiC;
phi=phi-phiC;
pO2=1/Ksv*(phi0./phi-1);


end

