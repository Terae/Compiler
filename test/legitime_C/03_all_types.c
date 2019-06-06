int main() {
    int a;
    const int b = 5;
    int* c;
    const int *d = &b;
    int **e;
    const int const* f = 0x80005321;
    char g;
    const char h = 'c';
    const char *i = &h;
    char **j;
    char const ***k = NULL;
    char l = 'a';
    char m, n, o = 'o', p = 'p';
    char q = '$';
    char *str = "I am a string recognized as\t\t\n  \t\ta string!";
    int bool_1 = true;
    int bool_2 = false;
    int hexa_1 = 0x00;
    int hexa_2 = 0XFe8C3d5;
    int octal = 06;
    int expo_1 = 40e10;
    int expo_2 = 1E30;
    int null_v = NULL;
}
