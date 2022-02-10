function [ pO2 ] = SternVolmer(Ksv,phi0,phi)
% [ pO2 ] = SternVolmer(Ksv,phi0,phi)

pO2=1/Ksv*(phi0./phi-1);


end

