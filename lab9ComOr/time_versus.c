#include <stdio.h>
#include <time.h>
int add_asm(){
	int x = 0,y = 2,z =13;
	asm("add %0, %1, %2": "+r"(x),"+r"(y),"+r"(z));
}
int add(){
	int x = 0,y = 2,z =12;
	x = y+ z;
}
int main(int argc, char *argv[])
{
	int i;
	time_t from_time,to_time,c_time,asm_time;
	from_time = time(NULL);
	for(i =0 ; i < 2000000000; i++)add_asm();
	to_time = time(NULL);
	asm_time = to_time - from_time;
	printf("asm time interval = %ld\n", asm_time);

	from_time = time(NULL);
	for(i =0 ; i < 2000000000; i++)add();
	to_time = time(NULL);
	c_time = to_time - from_time;
	printf("c time interval = %ld\n", c_time);
	return(0);

}
