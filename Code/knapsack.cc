#include <iostream>
#include <vector>
#include <ctime>
#include <cstdlib>
#include <algorithm>


struct population {
	int fitness;
	std :: vector <bool> parent;
	population(int f, std :: vector <bool> p) : fitness(f), parent(p) {}
};

bool customOrderingPopulation(population leftHandSign, population rightHandSign) {
	return leftHandSign.fitness < rightHandSign.fitness;
}

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

	knapsack(std :: vector <int> weights, std :: vector <int> profits, int C, int population, int maxIter) : att_C(C), att_weight(weights), att_profits(profits), att_population(population), att_iterated(maxIter), att_best(-1, {0}) {
		std :: srand(std :: time(NULL));
		while (att_weight.size() < att_profits.size())
			att_profits.pop_back();
		while (att_weight.size() > att_profits.size())
			att_weight.pop_back();
		initialize();
	}
};

void knapsack :: initialize() {
	for (unsigned int i = 0 ; i < att_population ; ++i) {
		std :: vector <bool> parent;
		for (unsigned int j = 0 ; j < att_weight.size() ; ++j)
			parent.push_back(std :: rand() % 2);
		att_parents.push_back(population(fitness(parent), parent));
	}
	att_best = att_parents[0];
}

int knapsack :: fitness(std :: vector <bool> item) {
	int sum_w(0);
	int sum_p(0);
	auto itemIterator(item.begin());
	for (auto weightIterator(att_weight.begin()), profitIterator(att_profits.begin()) ; itemIterator != item.end() ; ++weightIterator, ++profitIterator)
		if (*itemIterator++) {
			sum_w += *weightIterator;
			sum_p += *profitIterator;
		}
	return sum_w > att_C ? -1 : sum_p;
}

void knapsack :: evaluation() {
	int best_pop(att_population / 2);
	std :: sort(att_parents.begin(), att_parents.end(), customOrderingPopulation);
	att_best_p.clear();
	for (unsigned int i = best_pop ; i < att_parents.size() ; ++i)
		att_best_p.push_back(att_parents[i]);
}

void knapsack :: mutation(std :: vector<bool> &child) {
	for (int i = 0 ; i < child.size() ; ++i)
		if (std :: rand() % 2)
			child[i] = 1 - child[i];
}

std :: vector <population> knapsack :: crossover(population leftHandSign, population rightHandSign) {
	int threshold((std :: rand() % (leftHandSign.parent.size() - 2)) + 1);
	std :: vector<bool> tmp1;
	std :: vector<bool> tmp2;
	for (unsigned int i = threshold ; i < leftHandSign.parent.size() ; ++i)
		tmp1.push_back(leftHandSign.parent[i]);
	for (unsigned int i = threshold ; i < rightHandSign.parent.size() ; ++i)
		tmp2.push_back(rightHandSign.parent[i]);
	for (unsigned int i = 0 ; i < threshold ; ++i) {
		tmp1.push_back(leftHandSign.parent[i]);
		tmp2.push_back(rightHandSign.parent[i]);
	}
	std :: vector <population> result;
	result.push_back(population(fitness(tmp1), tmp1));
	result.push_back(population(fitness(tmp2), tmp2));
	return result;
}

population knapsack :: run() {
	while (att_iterated--) {
		evaluation();
		int pop(att_best_p.size());
		for (int i = 0 ; i < pop ; ++i) {
			if (i < pop - 1) {
				population r1(att_best_p[i]);
				population r2(att_best_p[i + 1]);
				std :: vector <population> children(crossover(r1, r2));
				att_parents[2 * i]     = children[0];
				att_parents[2 * i + 1] = children[1];
			}
			else {
				population r1(att_best_p[i]);
				population r2(att_best_p[0]);
				std :: vector <population> children(crossover(r1, r2));
				att_parents[2 * i]     = children[0];
				att_parents[2 * i + 1] = children[1];
			}
		}
		for (unsigned int i = 0 ; i < att_parents.size() ; ++i) {
			mutation(att_parents[i].parent);
			att_parents[i].fitness = fitness(att_parents[i].parent);
		}
		std :: sort(att_parents.begin(), att_parents.end(), customOrderingPopulation);
		att_best = customOrderingPopulation(att_best, att_parents.back()) ? att_parents.back() : att_best;
	}
	return att_best;
}

/*
int main() {
	std :: vector <int> weights({70, 73, 77, 80, 82, 87, 90, 94, 98, 106, 110, 113, 115, 118, 120});
	std :: vector <int> profits({135, 139, 149, 150, 156, 163, 173, 184, 192, 201, 210, 214, 221, 229, 240});
	int C(750); // Maximum capacity
	int popul(100);
	int iterations(100);
	knapsack k(weights, profits, C, popul, iterations);
	population test = k.run();
	std :: cout << test.fitness << " is the fitness for vector [";
	if (test.parent.size())
		std :: cout << test.parent[0];
	for (unsigned int i = 1 ; i < test.parent.size(); ++i)
		std ::  cout << ", " << test.parent[i];
	std :: cout << "]" << std :: endl;
}
*/
