function F=phi0estimation(x,xdata)
% Estimated_fit=lsqcurvefit(@phi0estimation,sqrt([22,.2 55]),phi,po2)
   % x(1) = xc
   % x(2) = Ksv
   % x(3) = phi0
xc=x(1).^2;
ksv=x(2).^2;
phi0=x(3).^2;

xdata=xdata-xc;
F = ((phi0-xc)./xdata-1)/ksv;