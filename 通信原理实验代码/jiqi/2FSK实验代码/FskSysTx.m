%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName:            FskSysTx.m
%  Description:         FSKͨ��ϵͳ�����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Parameter List:       
%       Output Parameter
%           SendBit     ��������Դ
%           SendSig     DPSK�ѵ��ź�
%           MsgLen      ����Դ����
%       Input Parameter
%           Fs          ������
%           Rs          ��Ԫ����
%           SFile       ����Դ�ļ�
%           SigLen      �����źų���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SendBit,SendSig,MsgLen]  = FskSysTx(Fs, Rs, SFile, SigLen)
UpSampleRate=Fs/Rs;
CoderConstraint = 7;%  Լ������ 
Preamble=[1 1 1 1 0 1 0 1 1 0 0 1 0 0 0 0];

% generate message
load(SFile);  %������Դ����
MsgLen = length(SendBit);

%% �������������ʵ�����������
% convolutoinal coding
trel = poly2trellis(CoderConstraint, [171, 133]);
SendBitWithTail = [SendBit, zeros(size(1 : CoderConstraint - 1))];%  ��β����, ����Ϣ�Ľ�β��� coder_constraint-1 ����
code = convenc(SendBitWithTail, trel);%  ���ÿ⺯�����ɾ����

% add preamble 
data = [Preamble, code];

% FSK modulation
% M = 2;        % Modulation order
% freqsep = 2*Rs;  % Frequency separation (Hz)
% nsamp = UpSampleRate;    % Number of samples per symbol
% SendSig = fskmod(data,M,freqsep,nsamp,Fs);
t=(0:length(data)*UpSampleRate-1)/Fs;

carrier1 = exp(1j*2*pi*Rs*t);
carrier2 = exp(1j*2*pi*3*Rs*t);

SendSig = zeros(1,length(data) * UpSampleRate);
for i = 1:length(data)
    SendSig(((i-1)*UpSampleRate+1):i  *UpSampleRate) = data(i);
end

code1 = SendSig .* carrier1;
code2 = (~SendSig) .* carrier2;
SendSig = code1 + code2;

% ȷ���źų�����SigLen
if length(SendSig)>SigLen
    SendSig = SendSig(1:SigLen);
elseif length(SendSig)<SigLen
    SendSig = [SendSig zeros(1,SigLen-length(SendSig))];
end



