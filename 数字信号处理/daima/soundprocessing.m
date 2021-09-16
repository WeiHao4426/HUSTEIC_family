clear ;close all;
[y,Fs]=audioread('SunshineSquare.wav');
sigLength=length(y);
Y = fft(y);
t=(0:sigLength-1)/Fs;
figure(1);plot(t,y);xlabel('Time(s)');%����ʱ�����ͼ

l=0:sigLength-1;
w=(pi/floor(sigLength/2))*l;
figure(2);plot(w/pi,abs(Y));xlabel('frequency')%������ɢ����Ҷ�任ͼ

%�˳�0.2857��0.8571
f1=0.2857*pi;f2=0.8571*pi;f=0.99;a=[1 f f^2 f^3 f^4];
b1=[1 -2*(cos(f1)+cos(f2)) 2+4*cos(f1)*cos(f2) -2*(cos(f1)+cos(f2)) 1];
a1=b1.*a;
[H,W0]=freqz(b1,a1,w);
figure(4);plot(w/pi,abs(H));
%�˳�0��0.5714
f3=0;f4=0.5714*pi;
b2=[1 -2*(cos(f3)+cos(f4)) 2+4*cos(f3)*cos(f4) -2*(cos(f3)+cos(f4)) 1];
a2=b2.*a;
[H2,W1]=freqz(b2,a2,w);
figure(5);plot(w/pi,abs(H2));

Ydtft=Y.'.*H.*H.*H2.*H2;%�����������������
figure(6);plot(w/pi,abs(Ydtft));

y2=ifft(Ydtft);
figure(7);plot(t,real(y2));
soundsc(real(y2),Fs);
audiowrite('SunshineSquare_New.wav',real(y2),Fs);