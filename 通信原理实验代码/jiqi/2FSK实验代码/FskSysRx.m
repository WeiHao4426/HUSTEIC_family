%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName:            FskSysRx.m
%  Description:         FSKϵͳ���ջ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Parameter List:       
%       Output Parameter
%           RecvFskDemod        FSK����ź�
%           RecvCorr            ͬ������ؽ��
%           RecvSymbolSampled   ��Ԫ����
%           RecvBit             ���յ��ı���
%       Input Parameter
%           Fs          ������
%           Rs          ��Ԫ����
%           MsgLen      ��������Դ����
%           RecvSig     �����ź�

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [RecvFskDemod,RecvCorr,RecvSymbolSampled,RecvBit] = FskSysRx(Fs,Rs,MsgLen,RecvSig)
UpSampleRate=Fs/Rs;
Ts=UpSampleRate; % symbol period
SymbolLen = (MsgLen+6)*2;
CoderConstraint = 7;%  Լ������ 
Preamble=[1 1 1 1 0 1 0 1 1 0 0 1 0 0 0 0];
PreambleSig=[-1 -1 -1 -1 +1 -1 +1 -1 -1 +1 +1 -1 +1 +1 +1 +1];
PreambleLen = 16;

RecvFskDemod = 0;
RecvCorr = 0;
RecvSymbolSampled = 0;
RecvBit = 0;

%% �������������ʵ���������ջ�
% filter design
fd1 = fdesign.bandpass('N,F3dB1,F3dB2',10,1,2*Rs,Fs);
filter1 = design(fd1,'butter');
fd2 = fdesign.bandpass('N,F3dB1,F3dB2',10,2*Rs,4*Rs,Fs);
filter2 = design(fd2,'butter');
fd3 = fdesign.lowpass('N,F3dB',10,Rs,Fs);
filter3 = design(fd3,'butter');

t = (0:length(RecvSig)-1)/Fs;

% filtering of carrier1
coss1 = exp(1j*2*pi*t*Rs);
signal1 = filter(filter1, RecvSig);
signal1 = signal1 .* conj(coss1);
signal1 = filter(filter3, signal1);

% filtering of carrier2
coss2 = exp(1j*2*pi*t*3*Rs);
signal2 = filter(filter2, RecvSig);
signal2 = signal2 .* conj(coss2);
signal2 = filter(filter3, signal2);

% FSK demodulation
RecvFskDemod = abs(signal1) - abs(signal2);%ȡ����

% preamble search
RecvCorr = zeros(1,floor(length(RecvFskDemod)/3));
for k=1:length(RecvFskDemod)/3 
    RecvCorr(k) = sum(RecvFskDemod(k:Ts:k+PreambleLen*Ts-1).*PreambleSig);
end
RecvCorr = abs(RecvCorr);

% sampled symbol
[peak, pos] = max(RecvCorr);
RecvSymbolSampled = RecvFskDemod(pos:Ts:pos+(PreambleLen+SymbolLen)*Ts-1);
RecvSymbolSampled = real(sign(RecvSymbolSampled(PreambleLen+1:end)));

% convolutoinal decoding
sampled_code = round(max(RecvSymbolSampled,0));%round((1-RecvSymbolSampled)/2);
t = poly2trellis(CoderConstraint, [171, 133]);
tb = 2;
decoded = vitdec(sampled_code,t,tb,'trunc','hard');
RecvBit = decoded(1:end-6);

end
    

