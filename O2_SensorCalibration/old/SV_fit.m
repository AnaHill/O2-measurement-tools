function F=SV_fit(x,xdata)

xc=x(1).^2;
ksv=x(2).^2;

xdata=xdata-xc;
F=(xdata(1)./xdata-1)/ksv;