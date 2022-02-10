function [ pO2 ] = SternVolmerC(Ksv,phi0,phi,phiC)
%
% [ pO2 ] = SternVolmerC(Ksv,phi0,phi,phiC)
%
% SternVolmer model that takes into account the constant phase shift that is
% always presenst (depends on the amplifier circuit)
%
%Input: Ksv   SternVolmer constant
%       phi0  phase on N2
%       phi   phase in the sample
%       phiC  the constant phase shift
%Output pO2   the 

phi0=phi0-phiC;
phi=phi-phiC;
pO2=1/Ksv*(phi0./phi-1);


end

