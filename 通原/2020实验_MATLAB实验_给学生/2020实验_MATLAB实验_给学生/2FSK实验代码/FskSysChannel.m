%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FileName:            FskSysChannel.m
%  Description:         �ŵ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Parameter List:       
%       Output Parameter
%           RecvSig         �����ź�
%           ChanParameter   �ŵ�����
%       Input Parameter
%           SendSig     �����ź�
%           Fs          ������
%           Amax        ����źŷ���
%           Pmax        �����λƫ��
%           Fmax        ���Ƶƫ Hz
%           Tmax        ���ʱ��ƫ�� ��
%           SNR         �����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ RecvSig, ChannelParameter] = FskSysChannel(SendSig,Fs,Amax,Pmax,Fmax,Tmax,SNR)

% �������
A = (0.1+0.9*rand(1,1))*Amax;
% ������ƫ
P = (2*rand(1,1)-1)*Pmax;
% ����Ƶƫ
F = (2*rand(1,1)-1)*Fmax;
% ����ʱƫ
T = floor(rand(1,1)*Tmax*Fs);

ChannelParameter = [ A P F T SNR];

% ��ʱƫ
SendSig = [ zeros(1,T) SendSig(1,1:end-T) ];

% ��Ƶƫ����ƫ�ͷ��ȱ仯
t = (0:length(SendSig)-1)/Fs;
RecvSig = A*exp(j*(2*pi*F*t+P)).*SendSig; 

RecvSig = awgn(RecvSig, SNR, 'measured');%�Ӹ�˹������
