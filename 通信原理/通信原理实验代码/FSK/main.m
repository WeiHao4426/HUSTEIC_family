close all

run_type = 0;           % ���滹���豸����

%% ϵͳ����
Fs = 200e3;           % ϵͳ������
Rs = 10e3;                 % ��Ԫ����
SFile = 'C:\Users\wuyesai\Desktop\FSK\SendBit.mat'; %��ȡ�����ļ�
SigLen = 200e3;        % �źŲ�����������Ӧʱ�䳤��Ϊ1��

%% �ŵ�����
Amax = 1;               % ����źŷ���
Pmax = pi;              % �����λƫ��
Fmax = 512/4;           % ���Ƶƫ����λHz
Tmax = 0.005;           % ���ʱƫ����λ��
SNR = -3;                % �����

%% �����
[SendBit,SendSig,MsgLen]  = FskSysTx(Fs, Rs, SFile, SigLen);


%% �ŵ�
if run_type==0
    [RecvSig, ChannelParameter ] = FskSysChannel(SendSig,Fs,Amax,Pmax,Fmax,Tmax,SNR);
else
    [RecvSig] = XSRP_RFLoopback(SendSig);
end

%% ���ջ�
[RecvFskDemod,RecvCorr,RecvSymbolSampled,RecvBit] = FskSysRx(Fs,Rs,MsgLen,RecvSig);


%% ����ͳ��
ErrNum = sum(xor(SendBit(1,1:end-1),RecvBit(1,1:end-1)));

%% ���δ�ӡ
% �������ݻ��ߴ�ӡ���߻�����
figure;plot(SendBit);title('SendBit������Դ����');
figure;plot(phasez(SendSig));title('phase(SendSig)��FSK�����ź���λ');
figure;plot(real(RecvSig));title('real(RecvSig)��FSK�����ź�');
figure;plot(real(RecvFskDemod));title('real(RecvFskDemod)��FSK������ź�');
figure;plot(RecvCorr);title('RecvCorr��preamble��ؽ��');
figure;plot(real(RecvSymbolSampled));title('real(RecvSymbolSampled)��������Ԫ');
figure;plot(RecvBit);title('RecvBit���������');
figure;plot(abs(RecvBit-SendBit));title('abs(RecvBit-SendBit)�����շ��ͱ��ش���');

ChannelParameter  % ��ӡ�ŵ�����
ErrNum  % ��ӡ���������



