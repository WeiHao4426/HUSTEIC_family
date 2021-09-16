clear ;close all;
[y,Fs]=audioread('SunshineSquare.wav');Y=fft(y);
len=length(y);l=0:len-1;f=(2*pi/len)*l;t=l/Fs;H=ones(1,119071);
figure(1);
subplot(2,1,1);plot(t,y);title('time');
subplot(2,1,2);plot(f/pi,20*log10(abs(Y)));title('frequency');
%��ư�����˹�����˲���
ff=[0.2857 0.5714 0.8571];
for i=1:3
    wp=[ff(i)-0.02 ff(i)+0.02];
    ws=[ff(i)-0.01 ff(i)+0.01];
    [n,wc]=buttord(wp,ws,0.1,10);
    [b,a]=butter(n,wc,'stop');
    y=filter(b,a,y);
    y=filter(b,a,y);
    [H1,~]=freqz(b,a,f);
    H=H.*H1;
end
%��ư�����˹��ͨ�˲���
wp =0.01;   
ws =0.02;
[n,wc] = buttord(wp,ws,0.1,10);
[b,a]=butter(n,wc,'high');
y=filter(b,a,y);
y=filter(b,a,y);
[H1,~]=freqz(b,a,f);
 H=H.*H1;
%�����˲����ͼ��
figure(2);
subplot(2,1,1);plot(t,y);title('time_new');
subplot(2,1,2);plot(f/pi,20*log10(abs(fft(y))));title('frequency_new');
%�����˲�����ͼ��
figure(3);
plot(f/pi,abs(H));title("fliter");
soundsc(y,Fs);