int f1(int, char, const int ** const*);
int f2(int a);
int **f3(int var, const char value) {
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

    int value = 3;
    switch(value) {
        case 0:
            value += 10;
            break;

        case 1:
            value /= 5;
            break;

        case 2:
        {
            value = (d * 5);
            value %= 3;
            break;
        }

        case 3:
            printf("Hello World\n");

        default:
            {
                int *ptr;
                printf("Inside the default case.\n");
                break;
            }
    }

    int ret = 8;
    return &ret;
}

int main(int argc, char **argv) {

}
