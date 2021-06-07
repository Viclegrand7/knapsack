#include "blockchain.hh"

int main() {
	blockchain maChaine;
	maChaine.addBlock("Salut");
	maChaine.addBlock("Yo");
	maChaine.printChain();
	maChaine.saveChain("savefile.sav");

	std :: cout << std :: endl << "Now saving + reading" <<  std :: endl << std :: endl;

	blockchain newChain("savefile.sav");
	newChain.printChain();

	maChaine.emptyChain();
	newChain.emptyChain();
}