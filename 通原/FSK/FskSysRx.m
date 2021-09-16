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

%% �������������ʵ���������ջ�
% filter design
filter1 = design(fdesign.lowpass('N,F3dB',1,2*Rs,Fs),'butter');
filter2 = design(fdesign.lowpass('N,F3dB',1,4*Rs,Fs),'butter');
filter3 = design(fdesign.lowpass('N,F3dB',1,Rs,Fs),'butter');

% filtering of carrier1
t = (0:length(RecvSig)-1)/Fs;
cw1 = exp(1j*2*pi*t*Rs);
sig1 = filter(filter3, filter(filter1, RecvSig).* conj(cw1));

% filtering of carrier2
cw2 = exp(1j*2*pi*t*3*Rs);
sig2 = filter(filter3, filter(filter2, RecvSig) .* conj(cw2));

% FSK demodulation
RecvFskDemod = abs(sig1) - abs(sig2);

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
trel = poly2trellis(CoderConstraint, [171, 133]);
RecvBit = vitdec(-RecvSymbolSampled,trel,5*CoderConstraint,'term','unquant');
RecvBit = RecvBit(1:length(RecvBit)-6);

end
    

