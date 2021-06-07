#include "enetServer.h"
#include "blockchain.hh"
#include "knapsack.hh"
#include <pthread.h>
#include <sstream>

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

const char *saveFileName("savefile.sav");

pthread_mutex_t knapsackMutex;
pthread_mutex_t blockchainMutex;

int num;

void sendBroadcast(char *message) {
	char buffer[500];

	//for (int i=0;i<12;i++)
	for (int i=0;i<8;i++)
		buffer[i]=0;
	//buffer[8]=1;
	buffer[8]=4;

	int len=strlen(message);
	int counter=0;
	for (counter=0;counter<len;counter++)
		buffer[9+counter]=message[counter];
	buffer[9+counter]=0;

	printf("len=%d %s\n", len, message);

	ENetPacket *packet = enet_packet_create (buffer, 10+len, ENET_PACKET_FLAG_RELIABLE);
	enet_host_broadcast(server, 1, packet);
}

void sendTousConnectes() {
	char message[10];

	sprintf(message,"X");
	sendBroadcast(message);
}

void sendEstDejaConnecte(int d) {
	printf("%d est déjà connecte\n",d);
}



void *handleKnapsack(void *values) {
	std :: vector <std :: string> **datas = (std :: vector <std :: string> **) values;
	std :: vector <std :: string> *knapsackValues = datas[0];
	std :: vector <std :: string> *blockchainValues = datas[1];

	char trashComa;
	int temporaryInteger;


	while (1) {
		pthread_mutex_lock(&knapsackMutex);
		unsigned int size = knapsackValues->size();
		pthread_mutex_unlock(&knapsackMutex);
		if (size) {
			pthread_mutex_lock(&knapsackMutex);
			std :: stringstream myStream(knapsackValues->front());
			knapsackValues->erase(knapsackValues->begin());
			pthread_mutex_unlock(&knapsackMutex);
			int numberOfItems;
			std :: vector <int> weights;
			std :: vector <int> valuesK;
			myStream >> numberOfItems >> trashComa;
			for (int i = 0 ; i < numberOfItems ; ++i) {
				myStream >> temporaryInteger >> trashComa;
				weights.push_back(temporaryInteger);
			}
			for (int i = 0 ; i < numberOfItems ; ++i) {
				myStream >> temporaryInteger >> trashComa;
				valuesK.push_back(temporaryInteger);
			}

			knapsack myKnapsack(weights, valuesK, maxWeight, 100, 100);
			struct population bestPop = myKnapsack.run();

			std :: string message("C");
			for (unsigned int i = 0 ; i < bestPop.parent.size() ; ++i)
				message += std :: to_string(bestPop.parent[i]) + ",";
			message += std :: to_string(bestPop.fitness) + "\0";

			char charMessage[100];
			memcpy(charMessage, ("C" + std :: to_string(bestPop.fitness)).c_str(), 100);
			sendBroadcast(charMessage);

			pthread_mutex_lock(&blockchainMutex);
			blockchainValues->push_back(message);
			pthread_mutex_unlock(&blockchainMutex);
		}
	}
	return NULL;
}

void *handleBlockchain(void *values) {
	std :: vector <std :: string> **datas = (std :: vector <std :: string> **) values;
//	std :: vector <std :: string> *knapsackValues = datas[0];
	std :: vector <std :: string> *blockchainValues = datas[1];


	blockchain myChain(saveFileName);
	if (!myChain.isEmpty()) { //Backing up
		int currentLevel = myChain.currentLevel();
		int scores[2];
		myChain.currentScores(scores);
		char message[100];
		sprintf(message, "R%d,%d,%d", currentLevel, scores[0], scores[1]); //Recover
		sendBroadcast(message);
	}

	while (1) {
		pthread_mutex_lock(&blockchainMutex);
		unsigned int size = blockchainValues->size();
		pthread_mutex_unlock(&blockchainMutex);
		if (size) {
			pthread_mutex_lock(&blockchainMutex);
			std :: string data(blockchainValues->front());
			std :: cout << data << std :: endl;
			blockchainValues->erase(blockchainValues->begin());
			pthread_mutex_unlock(&blockchainMutex);

			myChain.addBlock(data);

			myChain.printChain();
		}
	}

	myChain.saveChain(saveFileName);
	return NULL;
}

void handleIncomingMessage(void *values) {
	std :: vector <std :: string> **datas = (std :: vector <std :: string> **) values;
	std :: vector <std :: string> *knapsackValues = datas[0];
	std :: vector <std :: string> *blockchainValues = datas[1];

	switch (recMess[0]) {
		case 'C':
		{
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
			if (nbConnectes == 1)
				sendTousConnectes();
		}

		break;
	case 'L': //Loot. AI cannot access this event
	{
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
*/
	}	
		break;
	case 'P': //Planet
	{
		pthread_mutex_lock(&knapsackMutex);
		knapsackValues->push_back(recMess + 1);
		pthread_mutex_unlock(&knapsackMutex);
	}
		break;
	case 'S': //Score
	{
		recMess[0] = 'P'; //Player

		pthread_mutex_lock(&blockchainMutex);
		blockchainValues->push_back(recMess);
		pthread_mutex_unlock(&blockchainMutex);

		break;
	}
	default:
		break;
	}
}

int main (int argc, char ** argv) {
	if (pthread_mutex_init(&knapsackMutex, NULL))
		perror("mutex_lock");
	if (pthread_mutex_init(&blockchainMutex, NULL))
		perror("mutex_lock");

	printf("enet_initialize()\n");

	if (enet_initialize()) {
		fprintf (stderr, "An error occurred while initializing ENet.\n");
		return EXIT_FAILURE;
    }

	address.host = ENET_HOST_ANY;

	address.port = 4242;
	printf("enet_host_create()\n");

	server = enet_host_create(&address, 32, 2, 0, 0);
	if (!server) {
		fprintf(stderr, "An error occurred while trying to create an ENet server host.\n");
		exit(EXIT_FAILURE);
	}

	std :: vector <std :: string> knapsackValues;
	std :: vector <std :: string> blockchainValues;
	std :: vector <std :: string> *datas[2] = {&knapsackValues, &blockchainValues};

	pthread_t knapsackThread;
	int threadError(pthread_create(&knapsackThread, NULL, handleKnapsack, (void *) datas));
	if (threadError)
		std :: cout << "Error while creating thread: " << threadError << std :: endl;

	pthread_t blockchainThread;
	threadError = pthread_create(&blockchainThread, NULL, handleBlockchain, (void *) datas);
	if (threadError)
		std :: cout << "Error while creating thread: " << threadError << std :: endl;



	printf("before while() mainloop\n");

   	while (1) {
		while (enet_host_service (server, &event, TOMAX) > 0) {
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

				handleIncomingMessage((void *) datas);
			break;

	  			case ENET_EVENT_TYPE_DISCONNECT:
					printf ("%s disconnected FPX.\n", (char*)event.peer -> data);
					event.peer -> data = NULL;
			break;
				default:
			break;
			}
		}
	}

	pthread_join(knapsackThread, NULL);
	pthread_join(blockchainThread, NULL);
	atexit(enet_deinitialize);
}
