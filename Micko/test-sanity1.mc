//OPIS: Sanity check za miniC gramatiku

int f(int x) {
    int y;
    return x + 2 - y;
}

unsigned f2() {
    return 2u;
}

unsigned ff(unsigned x) {
    unsigned y;
    return x + f2() - y;
}

int main() {
    int a;
    int b;
    int aa;
    int bb;
    int c;
    int d;
    unsigned u;
    unsigned w;
    unsigned uu;
    unsigned ww;

    //poziv funkcije
    a = f(3);
   
    //if iskaz sa else delom
    if(a < b)
        a = 1;
    else
        a = -2;

    if(a + c == b + d - 4)
        a = 1;
    else
        a = 2;

    //ugnjezdeni if iskazi
    if(a < b)
        if(u == w) {
            u = ff(1u);
            a = f(11);
        }
        else {
            w = 2u;
        }
    else {
        if(a + c == b - d - -4) {
            a = 1;
            if (a + (aa-c) - d < b + (bb-a))
                uu = w-u+uu;
            else
                d = aa+bb-c;
        }
        else
            a = 2;
        a = f(42);
    }

    //if iskaz bez else dela
    if(a < b)
        a = 1;

    if(a + c == b - +4)
        a = 1;
}

