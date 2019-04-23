int function(){
	return 0;
}
int other_function(){
	return 1;
}

int main() {
    // tmp: declaration of functions ID
    int variable, var, toto;

    int a;
    a = 2;
    int b = 5;
    int c = 7 + 9;
    int d = (7 + 8) * 10;
    int e = ((5 + 4) * 9) % (80 / 4) - 2;
    int f = ((((((((8 + (1 + 2) - 50) + (5 * 7)) / 9 + 4 % (1 + 6) - 9) + 1) + 1) + 1) - 9) * 7);
    int g = !(1 + 2);
    true || false;
    true && false;
    (8 + 4) || !(toto && (10) - 9);
    printf("Hello");
    printf('r');
    printf(42);
    printf(variable);
    printf(function(var, 80));
    function();
    function(1);
    function(true, "Hello World", 0xDEADBEEF, 'r', 12, other_function());
}
