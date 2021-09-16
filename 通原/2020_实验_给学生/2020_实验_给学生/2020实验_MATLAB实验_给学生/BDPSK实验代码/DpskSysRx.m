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


% differential decoding


% preamble search


% sampled symbol


% convolutoinal decoding

end
    

