#include <pthread.h>
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "enetServer.h"
#include "knapsack.hh"

ENetAddress address;
ENetHost *server;
ENetPeer *peer;
ENetEvent event;
int count=0;
int cpt=0;
int idx;

char recMess[200];
char mess[200];

int nbConnectes;
int estConnecte[4];

int fsm;

int num;

pthread_mutex_t lock_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t  started_cond = PTHREAD_COND_INITIALIZER;

volatile int start;

    unsigned int capacity = 750;
    std::vector<int> weights{  70,73,77,80,82,87,90,94,98,106,110,113,115,118,120};
    std::vector<int> profits{ 135,139,149,150,156,163,173,184,192,201,210,214,221,229,240};
    size_t popsize = 100;
    unsigned int maxit = 1000;


void sendBroadcast(char *mess)
{
	char buffer[500];

	//for (int i=0;i<12;i++)
	for (int i=0;i<8;i++)
		buffer[i]=0;
	//buffer[8]=1;
	buffer[8]=4;

	int len=strlen(mess);
	int cpt=0;
	for (cpt=0;cpt<len;cpt++)
		buffer[9+cpt]=mess[cpt];
	buffer[9+cpt]=0;

	printf("len=%d %s\n",len,mess);

	ENetPacket * packet = enet_packet_create (buffer, 10+len, ENET_PACKET_FLAG_RELIABLE);
	enet_host_broadcast (server, 1, packet);
}

void handleIncomingMessage()
{
	printf("fsm=%d\n",fsm);
	switch (fsm)
	{
		case 0:
			// start=1;
                	if (pthread_mutex_lock(&lock_mutex)!=0)
                        	printf("there is an error in pthread_mutex_lock in producer()\n");

			if (pthread_cond_broadcast(&started_cond)!=0)
				printf("there is an error in pthread_cond_broadcast in producer()\n");

                	if (pthread_mutex_unlock(&lock_mutex)!=0)
                        	printf("there is an error in pthread_mutek_unlock in producer()\n");

			break;
		default:
			break;
	}
	printf("en sortant fsm=%d\n",fsm);
}

void heavyComputation()
{
        //volatile unsigned long long i;
        unsigned long long i;

        for (i=0;i<1000000000ULL;i++);
}

void* DoWork(void* args) {

	while (1)
	{
		if (pthread_mutex_lock(&lock_mutex)!=0)
			printf("there is an error in pthread_mutex_lock in DoWork()\n");

		if (pthread_cond_wait(&started_cond,&lock_mutex)!=0)
			printf("there is an error in pthread_cond_wait\n");

		if (pthread_mutex_unlock(&lock_mutex)!=0)
			printf("there is an error in pthread_mutek_unlock in DoWork()\n");

    		printf("start ID: %lu, CPU: %d\n", pthread_self(), sched_getcpu());

    /* Init solver */
    Knapsack k(capacity, weights, profits, popsize, maxit);
    /* Launch genetic algorithm */
    k.run();
    /* Print best solution found */
    k.print_bestsol();

		//heavyComputation();
    		printf("end   ID: %lu, CPU: %d\n", pthread_self(), sched_getcpu());

	}
}

int main (int argc, char ** argv) 
{
    	pthread_attr_t attr;
    	cpu_set_t cpus;
    	pthread_attr_init(&attr);
    	int i;

    	int numberOfProcessors = sysconf(_SC_NPROCESSORS_ONLN);
    	printf("Number of processors: %d\n", numberOfProcessors);

    	pthread_t threads[numberOfProcessors];

    	for (i = 0; i < numberOfProcessors; i++) 
	{
       		CPU_ZERO(&cpus);
       		CPU_SET(i, &cpus);
       		pthread_attr_setaffinity_np(&attr, sizeof(cpu_set_t), &cpus);
       		pthread_create(&threads[i], &attr, DoWork, NULL);
    	}

	printf("enet_initialize()\n");

	if (enet_initialize () != 0)
	{
        	fprintf (stderr, "An error occurred while initializing ENet.\n");
        	return EXIT_FAILURE;
    	}

	address.host = ENET_HOST_ANY;

	address.port = 4242;
	printf("enet_host_create()\n");

	server = enet_host_create (& address, 32, 2, 0, 0);
	if (server == NULL)
	{
       		fprintf (stderr, 
			"An error occurred while trying to create an ENet server host.\n");
       		exit (EXIT_FAILURE);
    	}

	fsm=0;

    	printf("before while() mainloop\n");

   	while (1)
   	{

    		while (enet_host_service (server, &event, TOMAX) > 0)
    		{
       			switch (event.type)
       			{
          			case ENET_EVENT_TYPE_CONNECT:
             				printf ("A new client connected from %x:%u.\n", 
					event.peer -> address.host, event.peer -> address.port);
             				break;
          			case ENET_EVENT_TYPE_RECEIVE:
             				//printf ("A packet of length %u containing %s was received from %s on channel %u.\n", 
					//	(int)event.packet -> dataLength, 
					//	(char*)event.packet -> data, 
					//	(char*)event.peer -> data, (int)event.channelID);
					peer=event.peer;
					//strcpy(recMess,(char*)(event.packet->data)+9);
					idx=0;
					for (int i=9;i<(int)event.packet->dataLength;i++)
					{
						//printf("%c",(char)event.packet->data[i]);
						recMess[idx++]=(char)event.packet->data[i];
					}
					recMess[idx++]='\0';
					printf("recMess=|%s|\n",recMess);
             				enet_packet_destroy (event.packet);
					handleIncomingMessage();
             				break;
          			case ENET_EVENT_TYPE_DISCONNECT:
             				printf ("%s disconnected FPX.\n", (char*)event.peer -> data);
             				event.peer -> data = NULL;
       			}
    		}
	}

	atexit (enet_deinitialize);
}
