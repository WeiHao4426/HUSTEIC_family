// ���˼��
//Ϊʹ�����߹�ƽ��������������

//��1������д�ߵ����ȼ���ͬ

//��2�����ߡ�д�߻������

//��3��ֻ������һ��д�߷����ٽ���

//��4�������ж������ͬʱ�����ٽ�������Դ

//  ʵ�ַ���

//��1������rw �ź���ʵ�ֶ��ٽ���Դ�Ļ�����ʡ�

//��2�����ü�����readcountʵ�ֶ�����߷����ٽ���Դ��ͨ�������ź���mutexʵ�ֶ�readcount �������Ļ�����ʡ�

//��3�������ź���wʵ�ֶ��ߺ�д�ߵĹ�ƽ����


int readcount=0;
semaphore w=1, mutex =1;
Reader()
{
	While(true)
	{
        wait (w);
        wait (mutex);
        if (readcount == 0)
	       wait(rw);
    	readcount++;	
    	signal (mutex);
        signal (w);
		 ��
    	   perform read operation
		 ��
    	wait (mutex);
    	readcount--;
    	if (readcount == 0)
    		signal (rw);
    	signal (mutex);
	}
}
 
 
Writer()
{     
	While(true)
{
    wait(w);
    wait(rw);
	    ��
         perform write operation
	    ��
    signal(rw);
signal(w);
}
}
