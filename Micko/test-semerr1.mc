//OPIS: Pogrešan tip konstante

int abs(int i) {
  int res;
  if(i < 0u)
    res = 0 - i;
  else 
    res = i; 
  return res;
}

int main() {
  return abs(-5);
}
