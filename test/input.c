int glob;
int calculate(int e,char a, int b){
	return a+b;
}
int main(){
	const int v = 0;
	v = 5;
	char a = 5;
	int *ptr = &a;
	char b = 3;
	int f = 2;
	int e = 0;
	calculate(a,f+e,a+b);
}
