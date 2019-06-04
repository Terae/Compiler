int f1(int, char, const int ** const*);
int f2(int arg);
int **f3(int var, const char ch) {
    int a;
    int b = 5;
    int c, d = 8;

    if(d - b == 3) {
        printf("Ok\n");
    } else {
        a = d - b * c;
    }

    do {
        a++;
        printf(++a);
    } while(a < 50);

    while(true) {
        for(int i = 0; (i < ((d + b))); ++i) {
            NULL;
            continue;
            printf("Unreachable statement.\n");
        }
        break;
    }

    ;

    int value = 3;

    int ret = 8;

    c = c;

    return &ret;
}

int main(int argc, char **argv) {
	return 0;
}
