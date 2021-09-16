%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName:            DpskSysRx.m
%  Description:         DPSKϵͳ���ջ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Parameter List:       
%       Output Parameter
%           RecvSigFiltered     �����ź��˲�
%           RecvDpskDemod       DPSK����ź�
%           RecvCorr            ͬ������ؽ��
%           RecvSymbolSampled   ��Ԫ����
%           RecvBit             ���յ��ı���
%       Input Parameter
%           Fs          ������
%           Rs          ��Ԫ����
%           MsgLen      ��������Դ����
%           RecvSig     �����ź�

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [RecvSigFiltered,RecvDpskDemod,RecvCorr,RecvSymbolSampled,RecvBit] = DpskSysRx(Fs,Rs,MsgLen,RecvSig)
UpSampleRate=Fs/Rs;
Ts=UpSampleRate; % symbol period
SymbolLen = (MsgLen+6)*2;
CoderConstraint = 7;%  Լ������ 
Rolloff=1;
Preamble=[1 1 1 1 0 1 0 1 1 0 0 1 0 0 0 0];
PreambleSig=[-1 -1 -1 -1 +1 -1 +1 -1 -1 +1 +1 -1 +1 +1 +1 +1];
PreambleLen = 16;
FilterSymbolLen = 6;

% �������������ʵ���������ջ�
% RRC filtering
filterDef=fdesign.pulseshaping(UpSampleRate,'Square Root Raised Cosine','Nsym,Beta',FilterSymbolLen,Rolloff);
myFilter = design(filterDef);
myFilter.Numerator=myFilter.Numerator*UpSampleRate;
RecvSigFiltered = conv(myFilter.Numerator,RecvSig);

% differential decoding
RecvDpskDemod = RecvSigFiltered(1:end-UpSampleRate).*conj(RecvSigFiltered(UpSampleRate+1:end));  % ������

% preamble search
RecvCorr = zeros(1,floor(length(RecvDpskDemod)/20));
for k=1:length(RecvDpskDemod)/20                      
    RecvCorr(k) = sum(real(RecvDpskDemod(k:UpSampleRate:k+length(PreambleSig)*UpSampleRate-1)).*PreambleSig);
end
RecvCorr = abs(RecvCorr);
[ peak, pos ] = max(RecvCorr); %��ʱ��

% sampled symbol
RecvSymbolSampled = RecvDpskDemod(pos:UpSampleRate:pos+(length(Preamble)+SymbolLen)*UpSampleRate-1);    
RecvSymbolSampled = real(sign(RecvSymbolSampled(length(Preamble)+1:end))); 

% convolutoinal decoding
code = round((1 - RecvSymbolSampled) / 2);
trel = poly2trellis(CoderConstraint, [171, 133]);
tb = 2;
RecvBit = vitdec(code,trel,tb,'trunc','hard');
RecvBit = RecvBit(1:length(RecvBit)-6);
end