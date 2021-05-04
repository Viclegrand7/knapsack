#include <iostream>
#include "sha256.h"
 
using std::string;
using std::cout;
using std::endl;
 
int main(int argc, char *argv[])
{
    long nonce=0; 
    //long nonce=72608; 
    string input1;
    string output1;

    do
    {
	input1="1"+std::to_string(nonce)+"MAIN4";
	output1=sha256(input1);
	nonce++;
	if (nonce%1000000==0)
		std::cout << nonce << std::endl;
    } while ((output1[0]!='0') || (output1[1]!='0') || (output1[2]!='0') || (output1[3]!='0')); 
    cout << "sha256('"<< input1 << "'):" << output1 << endl;
 
    return 0;
}
