#ifndef VA_DP_BLOCKCHAIN
#define VA_DP_BLOCKCHAIN
#include "sha256.h"
#include <string>
#include <iostream>

class block {
	std :: string att_currentHash;
	int att_blockNumber;
	std :: string att_data;
	long long att_nonce;
	block *att_next;
public:
	block(std :: string previousHash, std :: string data, int blockNumber = 0);
	block(std :: string currentHash, int blockNumber, std :: string data, long long nonce) : att_currentHash(currentHash), att_blockNumber(blockNumber), att_data(data), att_nonce(nonce), att_next(NULL) {}
	bool verifyBlock(std :: string previousHash);
	void addNextBlock(block *nextBlock) {att_next = nextBlock;};
	std :: string getHash() {return att_currentHash;};
	block *getNextBlock() {return att_next;};
	std :: string getFullData();
	bool isPlayer() {return att_data[0] == 'P';};
	int giveScore();
};

class blockchain {
	block *att_head;
public:
	blockchain() : att_head(NULL) {}
	blockchain(std :: string fileName);
	int verifyChain();
	int addBlock(std :: string data);
	void emptyChain();
	void saveChain(std :: string fileName);
	void printChain();
	bool isEmpty() {return att_head == NULL;};
	int currentLevel();
	void currentScores(int *scores);
};

#endif //VA_DP_BLOCKCHAIN