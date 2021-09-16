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

%% �������������ʵ���������ջ�
% RRC filtering
filterDef=fdesign.pulseshaping(UpSampleRate,'Square Root Raised Cosine','Nsym,Beta',FilterSymbolLen,Rolloff);
myFilter = design(filterDef);
myFilter.Numerator=myFilter.Numerator*UpSampleRate;
RecvSigFiltered = conv(myFilter.Numerator,RecvSig);

% differential decoding
RecvDpskDemod = RecvSigFiltered(1:end-Ts).*conj(RecvSigFiltered(Ts+1:end));  

% preamble search
RecvCorr = zeros(1,floor(length(RecvDpskDemod)/Ts));
for k=1:(length(RecvDpskDemod)/Ts)
    RecvCorr(k) = sum(real(RecvDpskDemod(k:Ts:k+PreambleLen*UpSampleRate-1)).*PreambleSig);
end
RecvCorr = abs(RecvCorr);
[~, pos ] = max(RecvCorr); 

% sampled symbol
RecvSymbolSampled = RecvDpskDemod(pos:UpSampleRate:pos+(PreambleLen+SymbolLen)*UpSampleRate-1);    
RecvSymbolSampled = real(sign(RecvSymbolSampled(PreambleLen+1:end)));

% convolutoinal decoding
trel = poly2trellis(CoderConstraint, [171, 133]);
RecvBit = vitdec(RecvSymbolSampled,trel,5*CoderConstraint,'term','unquant');
RecvBit = RecvBit(1:length(RecvBit)-FilterSymbolLen);
end