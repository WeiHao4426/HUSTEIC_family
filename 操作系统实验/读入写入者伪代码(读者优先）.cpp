//����д����ʵ��α����(�������ȣ� 

int readcount=0;
semaphore writeblock,mutex;
writeblock=1;mutex=1;//��ʼ�������Զ���д��
Cobegin


Process ReaderThread()
{
	P(mutex);    //��ȡ�����ٽ���Ȩ��
    readcount++; //�Ķ���������һ
	
	if(readcount==1)      //�Ķ�����������һ��ʾ֮ǰû�����Ķ�����Ҫ��ȡ�Ķ�Ȩ��
	    P(writeblock);     //д�����޷�д��
		V(mutex);          //�ͷ�Ȩ�ޣ����������Ķ��߽���
		
		/*���ļ�*/ 
		
		P(mutex);       //�Ķ���ϻ�ȡ�޸��Ķ�������Ȩ�� 
		readcount--;    //�Ķ�������һ 
		if(readcount==0)            //��ʾ�������һ���Ķ��ߣ��Ķ����ͷ��ٽ���������д����д�� 
		      V(writeblock);
		V(mutex);
 } 
 
 
 Process ReaderThread()     //д����� 
 {
 	P(writeblock);          //д����д�룬�Ķ����޷������ٽ��� 
 	/*д�ļ�*/
	 
	V(writeblock);          //����д�� 
 }
 
 coend
