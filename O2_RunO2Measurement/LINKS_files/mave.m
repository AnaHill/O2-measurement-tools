function xm=mave(x,n)
%backward moving average
%xm=mave(x,n)
%
%Calculates backward moving average of n points along the vector x

if length(x)<n
    error('n exceedes the length of vector')
end
if n<2
    xm=x;
else
    m=length(x);
    xm=zeros(size(x));
    xm(1)=x(1);
    k=2;
    while k<n
        xm(k)=mean(x(1:k));
        k=k+1;
    end
    while k<m+1
        xm(k)=mean(x(k-n+1:k));
        k=k+1;
    end
end
end


