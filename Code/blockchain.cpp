#include "blockchain.hh"
#include <fstream>
#include <sstream>

block :: block(std :: string previousHash, std :: string data, int blockNumber) : att_nonce(-1), att_data(data), att_blockNumber(blockNumber), att_next(NULL) {
    do {
        std :: string input(std :: to_string(att_blockNumber) + previousHash + att_data + std :: to_string(++att_nonce));
        att_currentHash = sha256(input);
    } while (att_currentHash[0] != '0' || att_currentHash[1] != '0' || att_currentHash[2] != '0' || att_currentHash[3] != '0' || att_currentHash[4] != '0');
}

bool block :: verifyBlock(std :: string previousHash) {
    std :: string input(std :: to_string(att_blockNumber) + previousHash + att_data + std :: to_string(att_nonce));
    att_currentHash = sha256(input);
    return (att_currentHash[0] != '0' || att_currentHash[1] != '0' || att_currentHash[2] != '0' || att_currentHash[3] != '0' || att_currentHash[4] != '0');
}

std :: string block :: getFullData() {
    return std :: string (att_currentHash + " " + std :: to_string(att_nonce) + " " + att_data + "\n");
}



blockchain :: blockchain(std :: string fileName) {
    std :: ifstream myFile(fileName);
    if (!myFile.is_open()) {
        att_head = NULL;
        return;
    }
    int currentBlockNumber(-1);

    std :: string hash;
    long long nonce;
    std :: string data;
    std :: string myLine;

    block *currentQueue(NULL);
    while (!myFile.eof()) {
        ++currentBlockNumber;
        if (!std :: getline(myFile, myLine))
            break;
        std :: stringstream myStream(myLine);

        std :: getline(myStream, hash, ' ');
        myStream >> nonce;
        myStream.get(); //On retire l'espace
        std :: getline(myStream, data);
        if (!currentQueue)
            currentQueue = att_head = new block(hash, currentBlockNumber, data, nonce);
        else
            currentQueue->addNextBlock(new block(hash, currentBlockNumber, data, nonce));
    }
    if (verifyChain()) { //Error, the file we read is corrupted
        printChain();
        emptyChain();
        att_head = NULL;
    }
    myFile.close();
}

int blockchain :: verifyChain() {
    block *currentBlock(att_head);
    if (!att_head)
        return 0;
    if (att_head->verifyBlock("Beginning"))
        return -1;

    while (currentBlock->getNextBlock()) {
        if (currentBlock->getNextBlock()->verifyBlock(currentBlock->getHash()))
            return 1;
        currentBlock = currentBlock->getNextBlock();
    }
    return 0;
}

int blockchain :: addBlock(std :: string data) {
    if (!att_head) {
        att_head = new block("Beginning", data, 0);
        return 0;
    }
    int testingCurrentChain(verifyChain());
    if (testingCurrentChain)
        return testingCurrentChain;
    block *currentBlock(att_head);
    int currentBlockNumber(1);
    while (currentBlock->getNextBlock()) {
        currentBlock = currentBlock->getNextBlock();
        ++currentBlockNumber;
    }
    currentBlock->addNextBlock(new block(currentBlock->getHash(), data, currentBlockNumber));
    return 0;
}

void blockchain :: emptyChain() {
    if (!att_head)
        return;
    block *currentHead(att_head);
    block *previousHead;
    while (currentHead->getNextBlock()) {
        previousHead = currentHead;
        currentHead = currentHead->getNextBlock();
        free(previousHead);
    }
    free(currentHead);
    att_head = NULL;
}

void blockchain :: saveChain(std :: string fileName) {
    std :: ofstream myFile;
    myFile.open(fileName);
    if (!myFile.is_open())
        return; //Error

    block *currentHead(att_head);
    block *previousHead;
    while (currentHead->getNextBlock()) {
        myFile << currentHead->getFullData();
        previousHead = currentHead;
        currentHead = currentHead->getNextBlock();
    }
    myFile << currentHead->getFullData();
    myFile.close();
}

void blockchain :: printChain() {
    if (!att_head)
        return;
    block *currentHead(att_head);
    while (currentHead->getNextBlock()) {
        std :: cout << currentHead->getFullData();
        currentHead = currentHead->getNextBlock();
    }
    std :: cout << currentHead->getFullData();
}
