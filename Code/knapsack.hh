#ifndef VA_DP_KNAPSACK
#define VA_DP_KNAPSACK
#include <vector>


struct population {
	int fitness;
	std :: vector <int> parent;
	population(int f, std :: vector <int> p) : fitness(f), parent(p) {}
};

bool customOrderingPopulation(population leftHandSign, population rightHandSign);

class knapsack {
	int att_C;
	std :: vector <int> att_weight;
	std :: vector <int> att_profits;
	std :: vector <population> att_parents;
	std :: vector <population> att_bests;
	std :: vector <population> att_best_p;
	int att_iterated;
	int att_population;
public:
	void initialize();
	int fitness(std :: vector <int> item);
	void evaluation();
	void mutation(std :: vector<int> &child);
	std :: vector <population> crossover(population leftHandSign, population rightHandSign);
	population run();

	knapsack(std :: vector <int> weights, std :: vector <int> profits, int C, int population, int maxIter) : att_C(C), att_weight(weights), att_profits(profits), att_population(population), att_iterated(maxIter) {
		std :: srand(time(NULL));
		while (att_weight.size() < att_profits.size())
			att_profits.pop_back();
		while (att_weight.size() > att_profits.size())
			att_weight.pop_back();
		initialize();
	}
};


#endif /* VA_DP_KNAPSACK */