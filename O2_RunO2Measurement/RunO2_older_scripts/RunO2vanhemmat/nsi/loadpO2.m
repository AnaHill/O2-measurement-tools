function [t,phi,amp]=loadpO2(fname)
load(fname)
t=nonzeros(t);
t=[0;t];
phi=nonzeros(phiM);
amp=nonzeros(ampM);