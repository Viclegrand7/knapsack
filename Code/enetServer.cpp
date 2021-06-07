#include "enetServer.h"
#include "blockchain.hh"

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

int maxWeight = 150;

int computerScore(0);
int playerScore(0);

char *saveFileName("savefile.sav");

int num;

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

	ENetPacket *packet = enet_packet_create (buffer, 10+len, ENET_PACKET_FLAG_RELIABLE);
	enet_host_broadcast (server, 1, packet);
}

void sendTousConnectes()
{
	char mess[10];

	sprintf(mess,"X");
	sendBroadcast(mess);
}

void sendEstDejaConnecte(int d)
{
	printf("%d est déjà connecte\n",d);
}

void sendCommandeIllegale()
{
}

void sendMap(char *m)
{
	char mess[500];

	sprintf(mess,"M%s",m);
	sendBroadcast(mess);
}

void sendBomb(int j,int y,int x)
{
	char mess[20];

	sprintf(mess,"B%d%3.3d%3.3d",j,y,x);
	sendBroadcast(mess);
}

void sendFlag(int j,int v,int y,int x)
{
	char mess[20];

	sprintf(mess,"F%d%d%3.3d%3.3d",j,v,y,x);
	sendBroadcast(mess);
}

void sendDiscovered(int j,int v,int y,int x)
{
	char mess[20];

	sprintf(mess,"D%d%d%3.3d%3.3d",j,v,y,x);
	sendBroadcast(mess);
}

void sendStop()
{
	char mess[20];

	sprintf(mess,"S");
	sendBroadcast(mess);
}



void handleKnapsack(void *values) {
	char *allValues = (char *) values;
	stringstream myStream(allValues);
	std :: getline(myStream, numberOfItems, ',');
	myStream >> numberOfItems;
	std :: vector <int> weights;
	std :: vector <int> values;
	
	int temporaryInteger;
	for (int i = 0 ; i < numberOfItems ; ++i) {
		std :: getline(myStream, temporaryInteger, ',');
		weights.push_back(temporaryInteger);
	}
	for (int i = 0 ; i < numberOfItems ; ++i) {
		std :: getline(myStream, temporaryInteger, ',');
		values.push_back(temporaryInteger);
	}

	knapsack myKnapsack(weights, values, maxWeight, 100, 100);
	population bestPop = myKnapsack.run();

	char *message[100];
	message[0] = 'C'; //Computer
	for (unsigned int i = 0 ; i < bestPop.parent.size() ; ++i)
		sprintf(message + 1 + i, "%d", bestPop.parent[i]);
	sprintf(message + 90, "%d", bestPop.fitness);
	sendBroadcast(message);
	myChain.addBlock(message);
}

void addBlock(void *values) {
	char *data = (char *) values;
	myChain.addBlock(data);
}

void handleIncomingMessage()
{
	switch recMess[0] {
		case 'C':
			int dir = recMess[1] - '0';
			if (!estConnecte[dir]) {
				++nbConnectes;
				estConnecte[dir] = 1;
				//sendEstConnecte(dir);
			}
			else
				sendEstDejaConnecte(dir);

			// Tout le monde est connecté, on envoie plein de choses
			// aux interfaces graphiques.
			if (nbConnectes == 1) {
				sendTousConnectes();

				fsm=1;
			}
	break;
		case 'L': //Loot. AI cannot access this event
/*		char numberOfItems(recMess[1]);
		int *allValues = malloc((2 * numberOfItems + 1) * sizeof(int));
		allValues[0] = (int) numberOfItems;
		for (char i = 0 ; i < numberOfItems ; ++i) {
			allValues[i + 1] = (int) recMess[2 + i];
			allValues[i + 1 + numberOfItems] = (int) recMess[2 + numberOfItems + i];
		}
		pthread_t knapsackThread;
		int threadError(pthread_create(&knapsackThread, NULL, handleKnapsack, (void *) &allValues));
		if (threadError)
			std :: cout << "Error while creating thread: " << threadError << std :: endl;
		pthread_join(knapsackThread, NULL);
*/	break;
		case 'P': //Planet

		//Need to redo it, send char * directly;

/*		char numberOfItems(recMess[1]);
		std :: vector <int> weights;
		std :: vector <int> values;
		for (char i = 0 ; i < numberOfItems ; ++i) {
			weights.push_back(recMess[2 + i]);
			values.push_back(recMess[2 + numberOfItems + i]);
		}
		pthread_t knapsackThread;
		int threadError(pthread_create(&knapsackThread, NULL, handleKnapsack, (void *) &allValues));
		if (threadError)
			std :: cout << "Error while creating thread: " << threadError << std :: endl;
		pthread_join(knapsackThread, NULL);
*/	break;
		case 'S': //Score
		pthread_t blockchainThread;
		recMess[0] = 'P'; //Player
		playerScore = std :: atoi(recMess + 1);
		int threadError(pthread_create(&blockchainThread, NULL, addBlock, (void *) recMess));
		if (threadError)
			std :: cout << "Error while creating thread: " << threadError << std :: endl;
		pthread_join(blockchainThread, NULL);	
	break;
		default:
	break;
	}
}

int main (int argc, char ** argv) 
{
	printf("enet_initialize()\n");

	if (enet_initialize () != 0) {
		fprintf (stderr, "An error occurred while initializing ENet.\n");
		return EXIT_FAILURE;
    }

	address.host = ENET_HOST_ANY;

	address.port = 4242;
	printf("enet_host_create()\n");

	server = enet_host_create (& address, 32, 2, 0, 0);
	if (server == NULL) {
		fprintf (stderr, "An error occurred while trying to create an ENet server host.\n");
		exit (EXIT_FAILURE);
	}


	fsm=0;

	printf("before while() mainloop\n");

/*   	while (1)
   	{
*/		while (enet_host_service (server, &event, TOMAX) > 0)
		{
   			switch (event.type) {
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
				for (unsigned int i = 9 ; i < event.packet->dataLength; ++i) {
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
			break;
   			}
		}
/*	}
*/
	atexit (enet_deinitialize);
}
