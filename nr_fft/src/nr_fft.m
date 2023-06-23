%
%  Engineer:       Devin
%  Email:          balddevin@outlook.com
%  Description:    Matlab code for the architecture verification of nr_fft
%  Additional:     
%  References:     Xie Y K, Fu B. Design and implementation of high through
%                    -put FFT processor[J]. Journal of Computer Research an
%                    -d Development, 2004, 41(6): 1022-1029.
%

clear,clc

WL = 16;    % Word Length.
FL = 12;    % Fraction Length.

%% stimulation

rng(0);
b = randi([0,3],3072,1);
c = pskmod(b,4,pi/4);
c = [zeros(512,1);c;zeros(512,1)];
d = ifft(c,4096).*2^6;
% d = c;
d = fi(d,1,WL,FL);
din = reshape(d,4,[]);
st0 = fft_stage(din,0);
st1 = fft_stage(st0,1);
st2 = fft_stage(st1,2);
st3 = fft_stage(st2,3);
st4 = fft_stage(st3,4);
st5 = fft_stage(st4,5);
y = fft_rev(st5);

figure(1);
plot(abs(fft(double(d))));
figure(2);
plot(abs(y(:)))

%%
function [dout] = fft_stage(din,stage)
    cnt = 0:1:1023;
    cnt_bin = dec2bin(cnt);
    for i = 1:1024
        switch(stage)
            case 0
                addr1(i) = cnt(i);
                addr2(i) = cnt(i);
                addr3(i) = cnt(i);
                addr4(i) = cnt(i);
            case 1
                addr1(i) = bin2dec(['00',cnt_bin(i,1:8)]);
                addr2(i) = bin2dec(['01',cnt_bin(i,1:8)]);
                addr3(i) = bin2dec(['10',cnt_bin(i,1:8)]);
                addr4(i) = bin2dec(['11',cnt_bin(i,1:8)]);
            case 2
                addr1(i) = bin2dec([cnt_bin(i,1:2),'00',cnt_bin(i,3:8)]);
                addr2(i) = bin2dec([cnt_bin(i,1:2),'01',cnt_bin(i,3:8)]);
                addr3(i) = bin2dec([cnt_bin(i,1:2),'10',cnt_bin(i,3:8)]);
                addr4(i) = bin2dec([cnt_bin(i,1:2),'11',cnt_bin(i,3:8)]);
            case 3
                addr1(i) = bin2dec([cnt_bin(i,1:4),'00',cnt_bin(i,5:8)]);
                addr2(i) = bin2dec([cnt_bin(i,1:4),'01',cnt_bin(i,5:8)]);
                addr3(i) = bin2dec([cnt_bin(i,1:4),'10',cnt_bin(i,5:8)]);
                addr4(i) = bin2dec([cnt_bin(i,1:4),'11',cnt_bin(i,5:8)]);
            case 4
                addr1(i) = bin2dec([cnt_bin(i,1:6),'00',cnt_bin(i,7:8)]);
                addr2(i) = bin2dec([cnt_bin(i,1:6),'01',cnt_bin(i,7:8)]);
                addr3(i) = bin2dec([cnt_bin(i,1:6),'10',cnt_bin(i,7:8)]);
                addr4(i) = bin2dec([cnt_bin(i,1:6),'11',cnt_bin(i,7:8)]);
            case 5
                addr1(i) = bin2dec([cnt_bin(i,1:8),'00']);
                addr2(i) = bin2dec([cnt_bin(i,1:8),'01']);
                addr3(i) = bin2dec([cnt_bin(i,1:8),'10']);
                addr4(i) = bin2dec([cnt_bin(i,1:8),'11']);
        end
    end
    addr1 = addr1+1;
    addr2 = addr2+1;
    addr3 = addr3+1;
    addr4 = addr4+1;
    b = mod(bin2dec(cnt_bin(:,1:2))+bin2dec(cnt_bin(:,3:4))+bin2dec(cnt_bin(:,5:6))+...
        bin2dec(cnt_bin(:,7:8))+bin2dec(cnt_bin(:,9:10)),4);
    ram = zeros(4,1024);
    for i = 1:1024
        switch(b(i))
            case 0
                ram(1,addr1(i)) = din(1,i);
                ram(2,addr2(i)) = din(2,i);
                ram(3,addr3(i)) = din(3,i);
                ram(4,addr4(i)) = din(4,i);
            case 1
                ram(1,addr4(i)) = din(4,i);
                ram(2,addr1(i)) = din(1,i);
                ram(3,addr2(i)) = din(2,i);
                ram(4,addr3(i)) = din(3,i);
            case 2
                ram(1,addr3(i)) = din(3,i);
                ram(2,addr4(i)) = din(4,i);
                ram(3,addr1(i)) = din(1,i);
                ram(4,addr2(i)) = din(2,i);
            case 3
                ram(1,addr2(i)) = din(2,i);
                ram(2,addr3(i)) = din(3,i);
                ram(3,addr4(i)) = din(4,i);
                ram(4,addr1(i)) = din(1,i);
        end
    end

    % retrieve
    for i = 1:1024
        switch(stage)
            case 0
                addr1(i) = bin2dec(['00',cnt_bin(i,1:8)]);
                addr2(i) = bin2dec(['01',cnt_bin(i,1:8)]);
                addr3(i) = bin2dec(['10',cnt_bin(i,1:8)]);
                addr4(i) = bin2dec(['11',cnt_bin(i,1:8)]);
            case 1
                addr1(i) = bin2dec([cnt_bin(i,1:2),'00',cnt_bin(i,3:8)]);
                addr2(i) = bin2dec([cnt_bin(i,1:2),'01',cnt_bin(i,3:8)]);
                addr3(i) = bin2dec([cnt_bin(i,1:2),'10',cnt_bin(i,3:8)]);
                addr4(i) = bin2dec([cnt_bin(i,1:2),'11',cnt_bin(i,3:8)]);
            case 2
                addr1(i) = bin2dec([cnt_bin(i,1:4),'00',cnt_bin(i,5:8)]);
                addr2(i) = bin2dec([cnt_bin(i,1:4),'01',cnt_bin(i,5:8)]);
                addr3(i) = bin2dec([cnt_bin(i,1:4),'10',cnt_bin(i,5:8)]);
                addr4(i) = bin2dec([cnt_bin(i,1:4),'11',cnt_bin(i,5:8)]);
            case 3
                addr1(i) = bin2dec([cnt_bin(i,1:6),'00',cnt_bin(i,7:8)]);
                addr2(i) = bin2dec([cnt_bin(i,1:6),'01',cnt_bin(i,7:8)]);
                addr3(i) = bin2dec([cnt_bin(i,1:6),'10',cnt_bin(i,7:8)]);
                addr4(i) = bin2dec([cnt_bin(i,1:6),'11',cnt_bin(i,7:8)]);
            case 4
                addr1(i) = bin2dec([cnt_bin(i,1:8),'00']);
                addr2(i) = bin2dec([cnt_bin(i,1:8),'01']);
                addr3(i) = bin2dec([cnt_bin(i,1:8),'10']);
                addr4(i) = bin2dec([cnt_bin(i,1:8),'11']);
            case 5
                addr1(i) = cnt(i);
                addr2(i) = cnt(i);
                addr3(i) = cnt(i);
                addr4(i) = cnt(i);
        end
    end
    addr1 = addr1+1;
    addr2 = addr2+1;
    addr3 = addr3+1;
    addr4 = addr4+1;
    btf_din = zeros(4,1024);
    for i = 1:1024
        switch(b(i))
            case 0
                btf_din(1,i) = ram(1,addr1(i));
                btf_din(2,i) = ram(2,addr2(i));
                btf_din(3,i) = ram(3,addr3(i));
                btf_din(4,i) = ram(4,addr4(i));
            case 1
                btf_din(1,i) = ram(2,addr1(i));
                btf_din(2,i) = ram(3,addr2(i));
                btf_din(3,i) = ram(4,addr3(i));
                btf_din(4,i) = ram(1,addr4(i));
            case 2
                btf_din(1,i) = ram(3,addr1(i));
                btf_din(2,i) = ram(4,addr2(i));
                btf_din(3,i) = ram(1,addr3(i));
                btf_din(4,i) = ram(2,addr4(i));
            case 3
                btf_din(1,i) = ram(4,addr1(i));
                btf_din(2,i) = ram(1,addr2(i));
                btf_din(3,i) = ram(2,addr3(i));
                btf_din(4,i) = ram(3,addr4(i));
        end
    end
    
    % butterfly
    tw_addr = zeros(1,1024);
    switch(stage)
        case 0
            for i = 1:1024
                tw_addr(i) = cnt(i);
            end
        case 1
            for i = 1:1024
                tw_addr(i) = bin2dec([cnt_bin(i,3:10),'00']);
            end
        case 2
            for i = 1:1024
                tw_addr(i) = bin2dec([cnt_bin(i,5:10),'0000']);
            end
        case 3
            for i = 1:1024
                tw_addr(i) = bin2dec([cnt_bin(i,7:10),'000000']);
            end
        case 4
            for i = 1:1024
                tw_addr(i) = bin2dec([cnt_bin(i,9:10),'00000000']);
            end
        case 5
            for i = 1:1024
                tw_addr(i) = 0;
            end
    end
    tw2_addr = tw_addr*1;
    tw3_addr = tw_addr*2;
    tw4_addr = tw_addr*3;
    tw2 = tw_rom(tw2_addr);
    tw3 = tw_rom(tw3_addr);
    tw4 = tw_rom(tw4_addr);
    btf_din1 = btf_din(1,:);
    btf_din2 = btf_din(2,:);
    btf_din3 = btf_din(3,:);
    btf_din4 = btf_din(4,:);

    btf1 = btf_din1+btf_din2+btf_din3+btf_din4;
    btf2 = (btf_din1-1i*btf_din2-btf_din3+1i*btf_din4).*tw2;
    btf3 = (btf_din1-btf_din2+btf_din3-btf_din4).*tw3;
    btf4 = (btf_din1+1i*btf_din2-btf_din3-1i*btf_din4).*tw4;

    dout = [btf1;btf2;btf3;btf4];
end

function [dout] = tw_rom(addr)
    dout = exp(-1i*2*pi*addr/4096);
end

function [dout] = fft_rev(din)
    cnt = 0:1:1023;
    cnt_bin = dec2bin(cnt);
    for i = 1:1024
        addr1(i) = cnt(i)+1;
        addr2(i) = cnt(i)+1;
        addr3(i) = cnt(i)+1;
        addr4(i) = cnt(i)+1;
    end
    b = mod(bin2dec(cnt_bin(:,1:2))+bin2dec(cnt_bin(:,3:4))+bin2dec(cnt_bin(:,5:6))+...
        bin2dec(cnt_bin(:,7:8))+bin2dec(cnt_bin(:,9:10)),4);
    ram = zeros(4,1024);
    for i = 1:1024
        switch(b(i))
            case 0
                ram(1,addr1(i)) = din(1,i);
                ram(2,addr2(i)) = din(2,i);
                ram(3,addr3(i)) = din(3,i);
                ram(4,addr4(i)) = din(4,i);
            case 1
                ram(1,addr4(i)) = din(4,i);
                ram(2,addr1(i)) = din(1,i);
                ram(3,addr2(i)) = din(2,i);
                ram(4,addr3(i)) = din(3,i);
            case 2
                ram(1,addr3(i)) = din(3,i);
                ram(2,addr4(i)) = din(4,i);
                ram(3,addr1(i)) = din(1,i);
                ram(4,addr2(i)) = din(2,i);
            case 3
                ram(1,addr2(i)) = din(2,i);
                ram(2,addr3(i)) = din(3,i);
                ram(3,addr4(i)) = din(4,i);
                ram(4,addr1(i)) = din(1,i);
        end
    end

    % retrieve
    for i = 1:1024
        addr1(i) = bin2dec(['00',cnt_bin(i,9:10),cnt_bin(i,7:8),cnt_bin(i,5:6),cnt_bin(i,3:4)]);
        addr2(i) = bin2dec(['01',cnt_bin(i,9:10),cnt_bin(i,7:8),cnt_bin(i,5:6),cnt_bin(i,3:4)]);
        addr3(i) = bin2dec(['10',cnt_bin(i,9:10),cnt_bin(i,7:8),cnt_bin(i,5:6),cnt_bin(i,3:4)]);
        addr4(i) = bin2dec(['11',cnt_bin(i,9:10),cnt_bin(i,7:8),cnt_bin(i,5:6),cnt_bin(i,3:4)]);
    end
    addr1 = addr1+1;
    addr2 = addr2+1;
    addr3 = addr3+1;
    addr4 = addr4+1;
    btf_din = zeros(4,1024);
    for i = 1:1024
        switch(b(i))
            case 0
                btf_din(1,i) = ram(1,addr1(i));
                btf_din(2,i) = ram(2,addr2(i));
                btf_din(3,i) = ram(3,addr3(i));
                btf_din(4,i) = ram(4,addr4(i));
            case 1
                btf_din(1,i) = ram(2,addr1(i));
                btf_din(2,i) = ram(3,addr2(i));
                btf_din(3,i) = ram(4,addr3(i));
                btf_din(4,i) = ram(1,addr4(i));
            case 2
                btf_din(1,i) = ram(3,addr1(i));
                btf_din(2,i) = ram(4,addr2(i));
                btf_din(3,i) = ram(1,addr3(i));
                btf_din(4,i) = ram(2,addr4(i));
            case 3
                btf_din(1,i) = ram(4,addr1(i));
                btf_din(2,i) = ram(1,addr2(i));
                btf_din(3,i) = ram(2,addr3(i));
                btf_din(4,i) = ram(3,addr4(i));
        end
    end
    dout = btf_din;
end