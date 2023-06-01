%
%  Engineer:       Devin
%  Email:          balddevin@outlook.com
%  Description:    Matlab code for the fixed point simulation of cordic_log
%  Additional:     - You can use a multiplier to impelement the logarithm of any base.
%                    L(base m) = L(module output) * (2%log(m))
%                  - The error goes abnormal when the input is 2 and 9, but
%                    partly acceptable.
%

clear,clc

zi = [atanh(1-2.^(-7:-2)),atanh(2.^-(1:16))];
zi = fi(zi,1,32,24);
t = 1:100;  % Verification stimulation.
nblk = length(t);

FL = 32;    % Fraction length of input.
WL = FL+32;
FL2 = 24;   % Fraction length of log value.
WL2 = FL2+8;

ln = zeros(nblk,1);
lnref = zeros(nblk,1);
for idx = 1:nblk
    x = t(idx)+1;
    y = t(idx)-1;
    z = 0;
    x = fi(x,1,WL,FL);
    y = fi(y,1,WL,FL);
    z = fi(z,1,WL2,FL2);
    for i = -5:0
        if (y<0)
            x1 = x + y - bitsra(y,2-i);
            y1 = y + x - bitsra(x,2-i);
            z1 = z - zi(i+6);
        else
            x1 = x - y + bitsra(y,2-i);
            y1 = y - x + bitsra(x,2-i);
            z1 = z + zi(i+6);
        end
        x = fi(x1,1,WL,FL);
        y = fi(y1,1,WL,FL);
        z = fi(z1,1,WL2,FL2);
    end
    
    for i = 1:16
        if (y<0)
            x1 = x + bitsra(y,i);
            y1 = y + bitsra(x,i);
            z1 = z - zi(i+6);
        else
            x1 = x - bitsra(y,i);
            y1 = y - bitsra(x,i);
            z1 = z + zi(i+6);
        end
        x = fi(x1,1,WL,FL);
        y = fi(y1,1,WL,FL);
        z = fi(z1,1,WL2,FL2);
    end
    ln(idx) = 2*z;
    lnref(idx) = fi(log(t(idx)),1,WL2,FL2);
end

plot(abs(ln-lnref));
