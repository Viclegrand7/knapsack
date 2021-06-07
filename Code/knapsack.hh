#ifndef VA_DP_KNAPSACK
#define VA_DP_KNAPSACK
#include <vector>


struct population {
	int fitness;
	std :: vector <bool> parent;
	population(int f, std :: vector <bool> p) : fitness(f), parent(p) {}
};

bool customOrderingPopulation(population leftHandSign, population rightHandSign);

class knapsack {
	int att_C;
	std :: vector <int> att_weight;
	std :: vector <int> att_profits;
	std :: vector <population> att_parents;
	population att_best;
	std :: vector <population> att_best_p;
	int att_iterated;
	int att_population;
public:
	void initialize();
	int fitness(std :: vector <bool> item);
	void evaluation();
	void mutation(std :: vector<bool> &child);
	std :: vector <population> crossover(population leftHandSign, population rightHandSign);
	population run();
	knapsack(std :: vector <int> weights, std :: vector <int> profits, int C, int population, int maxIter);
};


#endif /* VA_DP_KNAPSACK */