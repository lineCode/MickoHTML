//OPIS: Numerički izraz

int fja() {
    int z;
    int a;
    int b;
    int c;
    int d;
    z = a;
    z=a+( (b-(c+d)) - ((b+c)-((d+ 1)+ fja() - ((a+ 1)- ((c+a)-(a-c))))) );
    return z;
}

int main() {
    int r;
    r = fja();        
}
