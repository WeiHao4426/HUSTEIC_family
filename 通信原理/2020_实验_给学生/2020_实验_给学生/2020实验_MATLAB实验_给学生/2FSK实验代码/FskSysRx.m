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


% filtering of carrier1


% filtering of carrier2


% FSK demodulation


% preamble search


% sampled symbol


% convolutoinal decoding


end
    

