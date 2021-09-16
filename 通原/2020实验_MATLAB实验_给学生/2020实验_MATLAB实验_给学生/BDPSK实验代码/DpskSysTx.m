%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName:            DpskSysTx.m
%  Description:         DPSKͨ��ϵͳ�����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Parameter List:       
%       Output Parameter
%           SendBit     ��������Դ
%           SendBpsk    ��ֱ�����BPSK��Ԫ
%           SendSig     DPSK�ѵ��ź�
%           MsgLen      ����Դ����
%       Input Parameter
%           Fs          ������
%           Rs          ��Ԫ����
%           SFile       ����Դ�ļ�
%           SigLen      �����źų���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SendBit,SendBpsk,SendSig,MsgLen]  = DpskSysTx(Fs, Rs, SFile, SigLen)
UpSampleRate=Fs/Rs;
CoderConstraint = 7;%  Լ������ 
Rolloff=1;
Preamble=[1 1 1 1 0 1 0 1 1 0 0 1 0 0 0 0];
FilterSymbolLen = 6;

% generate random message
load(SFile); %������Դ����
MsgLen = length(SendBit);

% convolutoinal coding
trel = poly2trellis(CoderConstraint, [171, 133]);
SendBitWithTail = [SendBit, zeros(size(1 : CoderConstraint - 1))];%  ��β����, ����Ϣ�Ľ�β��� coder_constraint-1 ����
code = convenc(SendBitWithTail, trel);%  ���ÿ⺯�������ɾ����

% add preamble 
data=[Preamble,code];

% dpsk coding
SendBpsk=zeros(1,length(data)+1);
for iBit=1:length(data)
    SendBpsk(iBit+1)=xor(SendBpsk(iBit),data(iBit));
end

% mapping 0 to +1; 1 to -1
SendBpsk=1-2*SendBpsk;

% upsampling 
SendBpskUp=zeros(1,length(SendBpsk)*UpSampleRate);
for iBits=1:length(SendBpsk)
    SendBpskUp(UpSampleRate*iBits)=SendBpsk(iBits);
end

% RRC filtering
filterDef=fdesign.pulseshaping(UpSampleRate,'Square Root Raised Cosine','Nsym,Beta',FilterSymbolLen,Rolloff);
myFilter = design(filterDef);
myFilter.Numerator=myFilter.Numerator*UpSampleRate;
SendSig = conv(myFilter.Numerator,SendBpskUp);

% ȷ���źų�����SigLen
if length(SendSig)>SigLen
    SendSig = 0.7*SendSig(1:SigLen);
elseif length(SendSig)<SigLen
    SendSig = 0.7*[SendSig zeros(1,SigLen-length(SendSig))];
end

