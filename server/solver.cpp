#include <cstdio>
#include <vector>

using namespace std;

const int MAXS = 40000000;;
const int dead = 64;

#define repi(i, a) for(typeof((a).begin()) i = (a).begin(), _##i = (a).end(); i != _##i; ++i)

int ans[MAXS]; // #black+white moves till king takes

int mask(int K, int Q, int k, int r, int turn) {
  return turn + 2 * (K + 65 * (Q + 65 * (k + 65 * r)));
}

int K, Q, k, r, turn;

void read(int msk) {
  turn = msk % 2; msk /= 2;
  K = msk % 65; msk /= 65;
  Q = msk % 65; msk /= 65;
  k = msk % 65; msk /= 65;
  r = msk;
}

bool issq(int x, int y) {
  return x >= 0 && x < 8 && y >= 0 && y < 8;
}

vector<int> km[65], qm[65][8], rm[65][8];

void check(int k, int j, int x, int y, int nx, int ny) {
  if (nx >= 0 && nx < 8 && ny >= 0 && ny < 8 && !(x == nx && y == ny)) {
    int a = x + 8 * y, b = nx + 8 * ny;
    if (k == 0) km[a].push_back(b);
    else if (k == 1) qm[a][j].push_back(b);
    else rm[a][j].push_back(b);
  }
}

void prec() {
  int dx[] = {1, 1, 0, -1, -1, -1, 0, 1},
      dy[] = {0, 1, 1, 1, 0, -1, -1, -1};

 for(int x = 0; x < 8; ++x) {
    for(int y = 0; y < 8; ++y) {
      for(int nx = x - 1; nx <= x + 1; ++nx) {
        for(int ny = y - 1; ny <= y + 1; ++ny) {
          check(0, 0, x, y, nx, ny);
        }
      }

      for(int i = 1; i <= 2; ++i) {
        for(int dir = 0; dir < 8; ++dir) {
          for(int d = 1; d <= 8; ++d) {
            if (i == 2 && dir % 2 != 0) continue; // rooks don't move diagonal
            int nx = x + dx[dir] * d;
            int ny = y + dy[dir] * d;
            check(i, dir, x, y, nx, ny);
          }
        }
      }
    }
  }
}

void compto(int K, int Q, int k, int r, int turn, vector<int> &v) {
  // states that cur can transition to
  if (turn == 0) { // black to move
    // k moves
    repi(_nk, km[k]) {
      int nK = K, nQ = Q, nk = k, nr = r, nt = 1;
      nk = *_nk;
      if (nK == nk) nK = dead;
      if (nQ == nk) nQ = dead;
      if (nk == nr) continue;

      v.push_back(mask(nK, nQ, nk, nr, nt));
    }

    // r moves
    for(int i = 0; i < 8; ++i) {
      repi(_nr, rm[r][i]) {
        bool capture = false;
        int nK = K, nQ = Q, nk = k, nr = r, nt = 1;
        nr = *_nr;
        if (nK == nr) nK = dead, capture = true;
        if (nQ == nr) nQ = dead, capture = true;
        if (nk == nr) break;
        v.push_back(mask(nK, nQ, nk, nr, nt));

        if (capture) break;

      }
    }

  } else {
    repi(_nK, km[K]) {
      int nK = K, nQ = Q, nk = k, nr = r, nt = 0;
      nK = *_nK;
      if (nK == nQ) continue;
      if (nK == nk) nk = dead;
      if (nK == nr) nr = dead;
      v.push_back(mask(nK, nQ, nk, nr, nt));

    }

    for(int i = 0; i < 8; ++i) {
      repi(_nQ, qm[Q][i]) {
        bool capture = false;
        int nK = K, nQ = Q, nk = k, nr = r, nt = 0;
        nQ = *_nQ;
        if (nQ == nK) break;
        if (nQ == nk) nk = dead, capture = true;
        if (nQ == nr) nr = dead, capture = true;
        v.push_back(mask(nK, nQ, nk, nr, nt));
        if (capture) break;
      }
    }
  }
}

int parse(int x) {
  if (x == 0) return 64;
  int a = x / 10, b = x % 10;
  return (a - 1) + 8 * (b - 1);
}

bool get() {
  printf("Enter RC RC RC RC T (T = 1 if white to move)\n");
  int _K, _Q, _k, _r;;
  if (scanf("%d %d %d %d %d", &_K, &_Q, &_k, &_r, &turn) == -1) return false;
  K = parse(_K); Q = parse(_Q); k = parse(_k); r = parse(_r);
  return true;
}

int x, y;
void rd(int a) {
  if (a == 64) {
    x = 0; y = 0; return;
  }
  x = 1 + (a % 8);
  y = 1 + (a / 8);
}


FILE *FIN = fopen("out", "r");
int main() {
  prec();
  int i = 0;
  memset(ans, -2, sizeof(ans));
  while (fscanf(FIN, "%d", &x) != -1) {
    if (x == -1) ++i;
    else {
      ans[x] = i;
    }
  }

  printf("ready.\n");
  while (get()) {
    printf("read %d %d %d %d %d\n", K, Q, k, r, turn);
    int cur = mask(K, Q, k, r, turn);
    printf("mask = %d\n", cur);
    printf("white mates in %d\n", (ans[cur]) / 2) ;
    vector<int> conn;
    compto(K, Q, k, r, turn, conn);
    printf("comp'd.\n");
    int nxt = -1;
    repi(i, conn) {
      if (ans[*i] == ans[cur] - 1) nxt = *i;
    }
    if (nxt == -1) {
      printf("can't find.\n");
    } else {
      read(nxt);
      rd(K);
      printf("WK: (%d, %d)\n", x, y);
      rd(Q);
      printf("WQ: (%d, %d)\n", x, y);
      rd(k);
      printf("BK: (%d, %d)\n", x, y);
      rd(r);
      printf("BR: (%d, %d)\n", x, y);
    }
  }


}
