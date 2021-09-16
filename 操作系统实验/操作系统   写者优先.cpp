/*
* 	д������
*/

//���˼· 
/* 
д������������������ơ���֮ͬ������һ��һ��д�ߵ�������Ӧ�þ�����ļ�����д�����������һ��д���ڵȴ������µ����Ķ��߲�������ж�������
Ϊ��Ӧ�����һ�����ͱ���write_count�����ڼ�¼���ڵȴ���д�ߵ���Ŀ����write_count=0ʱ���ſ����ͷŵȴ��Ķ����̶߳��С�

Ϊ�˶�ȫ�ֱ���write_countʵ�ֻ��⣬��������һ���������mutex2��

Ϊ��ʵ��д�����ȣ�Ӧ�����һ���ٽ�������read������д����д�ļ���ȴ�ʱ�����߱���������read�ϡ�ͬ�����ж��߶�ʱ��д�߱���ȴ������ǣ�������һ���������RW_mutex��ʵ��������⡣

��д����дʱ��д�߱���ȴ���

�����߳�Ҫ��ȫ�ֱ���read_countʵ�ֲ����ϵĻ��⣬������һ�������������Ϊmutex1��
*/

//�ź�������

/*
�������ź���������
��������ź������ֱ���RWMutex, mutex1, mutex2, mutex3, wrt������ȫ�����ͱ���writeCount, readCount

�ź���mutex1��д�ߵĽ��������˳�����ʹ�ã�ʹ��ÿ��ֻ��һ��д�߶�����Ӧ���������Ƴ������в�����
��Ҫԭ���ǽ��������˳������ڶԱ���writeCount���޸ģ�ÿ��д�����������writeCount��1���˳�����writeCount��1��
�ź���RWMutex���Ƕ��ߺ�д������֮��Ļ����ź�������֤ÿ��ֻ������ֻд��

д�������У�д�ߵĲ���Ӧ�������ڶ��ߣ����ź���һֱ��ռ���ţ�ֱ��û��д�ߵ�ʱ��Ż��ͷţ�
����writeCount����1��ʱ�������ź���RWMutex�������д�������ٴ����룬����д���ǲ���ͬʱ����д�����ģ�
����Ҫ����һ���ź���wrt����֤ÿ��ֻ��һ��д�߽���д��������д�ߵ�����writeCount����0��ʱ����֤����ʱû��û�ж����ˣ�
�ͷ��ź���RWMutex���ź���mutex2��ֹһ�ζ�������޸�readCount����readCountΪ1��ʱ��Ϊ��ֹд�߽���д�����������ź���wrt����д�߾��޷�����д�����ˡ�
�ź���mutex3����Ҫ�ô����Ǳ���д��ͬʱ�������߽��о������������ź���RWMutex��mutex3���ͷţ���һ����д�ߣ�д�߿����ϻ����Դ��


*/ 



# include <stdio.h>
# include <stdlib.h>
# include <time.h>
# include <sys/types.h>
# include <pthread.h>
# include <semaphore.h>
# include <string.h>
# include <unistd.h>

//semaphores
sem_t RWMutex, mutex1, mutex2, mutex3, wrt;
int writeCount, readCount;


struct data {
	int id;
	int opTime;
	int lastTime;
};

//����
void* Reader(void* param) {
	int id = ((struct data*)param)->id;
	int lastTime = ((struct data*)param)->lastTime;
	int opTime = ((struct data*)param)->opTime;

	sleep(opTime);
	printf("Thread %d: waiting to read\n", id);	

	sem_wait(&mutex3);
	sem_wait(&RWMutex);
	sem_wait(&mutex2);
	readCount++;
	if(readCount == 1)
		sem_wait(&wrt);
	sem_post(&mutex2);
	sem_post(&RWMutex);
	sem_post(&mutex3);

	printf("Thread %d: start reading\n", id);
	/* reading is performed */
	sleep(lastTime);
	printf("Thread %d: end reading\n", id);

	sem_wait(&mutex2);
	readCount--;
	if(readCount == 0)
		sem_post(&wrt);
	sem_post(&mutex2);

	pthread_exit(0);
}

//д��
void* Writer(void* param) {
	int id = ((struct data*)param)->id;
	int lastTime = ((struct data*)param)->lastTime;
	int opTime = ((struct data*)param)->opTime;

	sleep(opTime);
	printf("Thread %d: waiting to write\n", id);
	
	sem_wait(&mutex1);
	writeCount++;
	if(writeCount == 1){
		sem_wait(&RWMutex);
	}
	sem_post(&mutex1);
	
	sem_wait(&wrt);
	printf("Thread %d: start writing\n", id);
	/* writing is performed */
	sleep(lastTime);
	printf("Thread %d: end writing\n", id);
	sem_post(&wrt);

	sem_wait(&mutex1);
	writeCount--;
	if(writeCount == 0) {
		sem_post(&RWMutex);
	}
	sem_post(&mutex1);
	
	pthread_exit(0);
}

int main() {
	//pthread
	pthread_t tid; // the thread identifier

	pthread_attr_t attr; //set of thread attributes

	/* get the default attributes */
	pthread_attr_init(&attr);

	//initial the semaphores
    sem_init(&mutex1, 0, 1);
    sem_init(&mutex2, 0, 1);
    sem_init(&mutex3, 0, 1);
    sem_init(&wrt, 0, 1);
    sem_init(&RWMutex, 0, 1);

    readCount = writeCount = 0;

	int id = 0;
	while(scanf("%d", &id) != EOF) {

		char role;		//producer or consumer
		int opTime;		//operating time
		int lastTime;	//run time

		scanf("%c%d%d", &role, &opTime, &lastTime);
		struct data* d = (struct data*)malloc(sizeof(struct data));

		d->id = id;
		d->opTime = opTime;
		d->lastTime = lastTime;

		if(role == 'R') {
			printf("Create the %d thread: Reader\n", id);
			pthread_create(&tid, &attr, Reader, d);

		}
		else if(role == 'W') {
			printf("Create the %d thread: Writer\n", id);
			pthread_create(&tid, &attr, Writer, d);
		}
	}

	sem_destroy(&mutex1);
	sem_destroy(&mutex2);
	sem_destroy(&mutex3);
	sem_destroy(&RWMutex);
	sem_destroy(&wrt);

	return 0;
}

