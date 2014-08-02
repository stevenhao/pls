#include <cstdio>

int K, Q, k, r, turn;
int x, y;
void rd(int a) {
  if (a == 64) {
    x = 0; y = 0; return;
  }
  x = 1 + (a % 8);
  y = 1 + (a / 8);
}

void read(int msk) {
  turn = msk % 2; msk /= 2;
  K = msk % 65; msk /= 65;
  Q = msk % 65; msk /= 65;
  k = msk % 65; msk /= 65;
  r = msk;
}

int main() {
  for(int i = 0; i < 200; ++i) {
    printf("i = %d\n\n\n", i);
    int cnt = 0;
    while (scanf("%d", &x) != -1) {
      if (x == -1) break;
      if (cnt > 5) continue;
      ++cnt;
      read(x);
      rd(K);
      printf("WK: (%d, %d)\n", x, y);
      rd(Q);
      printf("WQ: (%d, %d)\n", x, y);
      rd(k);
      printf("BK: (%d, %d)\n", x, y);
      rd(r);
      printf("BR: (%d, %d)\n", x, y);
      if (i % 2 == 0) printf("(black to move)\n");
      else printf("(white to move)\n");
      printf("\n");
    }
  }
}
