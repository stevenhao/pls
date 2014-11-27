#include <cstdio>
#include <vector>

using namespace std;

const int MAXS = 40000000;
const int dead = 64;

#define pprintf(args...) fprintf(FOUT, args)  //, printf("logging "args);
#define repi(i, a) for(typeof((a).begin()) i = (a).begin(), _##i = (a).end(); i != _##i; ++i)
int deg[MAXS];
int vis[MAXS]; // vis[state] <-> #moves from state s.t. state is winning for white
char ans[MAXS]; // #black+white moves till king takes

int K, Q, k, n, turn;
// turn = 0 -> black to move
// turn = 1 -> white to move

void read(int state) {
  turn = state % 2; state /= 2;
  n = state % 65; state /= 65;
  k = state % 65; state /= 65;
  Q = state % 65; state /= 65;
  K = state;
}

int mask(int K, int Q, int k, int n, int turn) {
  return turn + 2 * (n + 65 * (k + 65 * (Q + 65 * K)));
}

bool valid(int K, int Q, int k, int n) {
  if (K != dead) if (K == Q || K == k || K == n) return false;
  if (Q != dead) if (Q == k || Q == n) return false;
  if (k != dead) if (k == n) return false;
  return true;
}

bool iswin(int K, int Q, int k, int n) {
  return K != dead && k == dead;
}

bool issq(int x, int y) {
  return x >= 0 && x < 8 && y >= 0 && y < 8;
}

vector<int> km[65], qm[65][8], rm[65][8], nm[65];

void check(int k, int j, int x, int y, int nx, int ny) {
  if (nx >= 0 && nx < 8 && ny >= 0 && ny < 8 && !(x == nx && y == ny)) {
    int a = x + 8 * y, b = nx + 8 * ny;
    if (k == 0) km[a].push_back(b);
    else if (k == 1) qm[a][j].push_back(b);
    else if (k == 2) rm[a][j].push_back(b);
    else nm[a].push_back(b);
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

      for(int i = -2; i <= 2; ++i) {
        for(int j = -2; j <= 2; ++j) {
          if (i * j == 2 || i * j == -2) {
            int nx = x + i;
            int ny = y + j;
            check(3, 0, x, y, nx, ny);
          }
        }
      }
    }
  }
}

void compfrom(int K, int Q, int k, int n, int turn, vector<int> &v) {
  // states that could have transitioned to cur
  if (turn == 1) { // black just moved
    // k moved
    repi(_nk, km[k]) {
      int nK = K, nQ = Q, nk = k, nn = n, nt = 0;
      nk = *_nk;
      if (nK == nk) continue;
      if (nQ == nk) continue;
      if (nk == nn) continue;

      v.push_back(mask(nK, nQ, nk, nn, nt));
      if (nK == dead) v.push_back(mask(k, nQ, nk, nn, nt));
      if (nQ == dead) v.push_back(mask(nK, k, nk, nn, nt));

    }
    // n moved.

    repi(_nn, nm[n]) {
      int nK = K, nQ = Q, nk = k, nn = n, nt = 0;
      nn = *_nn;
      if (nK == nn) continue;
      if (nQ == nn) continue;
      if (nk == nn) continue;
      v.push_back(mask(nK, nQ, nk, nn, nt));

      if (nK == dead) v.push_back(mask(n, nQ, nk, nn, nt));
      if (nQ == dead) v.push_back(mask(nK, n, nk, nn, nt));

    }
  } else {
    repi(_nK, km[K]) {
      int nK = K, nQ = Q, nk = k, nn = n, nt = 1;
      nK = *_nK;
      if (nK == nQ) continue;
      if (nK == nk) continue;
      if (nK == nn) continue;
      v.push_back(mask(nK, nQ, nk, nn, nt));
      if (nk == dead) v.push_back(mask(nK, nQ, K, nn, nt));
      if (nn == dead) v.push_back(mask(nK, nQ, nk, K, nt));

    }

    for(int i = 0; i < 8; ++i) {
      repi(_nQ, qm[Q][i]) {
        int nK = K, nQ = Q, nk = k, nn = n, nt = 1;
        nQ = *_nQ;
        if (nQ == nK) break;
        if (nQ == nk) break;
        if (nQ == nn) break;
        v.push_back(mask(nK, nQ, nk, nn, nt));
        if (nk == dead) {
          v.push_back(mask(nK, nQ, Q, nn, nt));
        }
        if (nn == dead) v.push_back(mask(nK, nQ, nk, Q, nt));
      }
    }
  }
}

vector<int> fin[200];



bool ismate(int msk) {
  int othmsk = msk ^ 1;
  return ans[othmsk] == 1; // must be check
}

FILE *FOUT = fopen("out", "w");
int main() {
  memset(ans, -1, sizeof(ans));
  printf("precomputing 1.\n");
  prec();
  printf("done precomputing 1.\n");

  printf("precomputing 2.\n");
  vector<int> tmp;
  for(int K = 0; K < 65; ++K) {
    printf("K = %d\n", K);
    for(int Q = 0; Q < 65; ++Q) {
      for(int k = 0; k < 65; ++k) {
        for(int n = 0; n < 65; ++n) {
          if (!valid(K, Q, k, n)) continue;
          for(int turn = 0; turn < 2; ++turn) {
            tmp.clear();
            compfrom(K, Q, k, n, turn, tmp);
            repi(i, tmp) {
              ++deg[*i];
            }
          }
        }
      }
    }
  }
  printf("done precomputing 2.\n");

  printf("precomputing 3.\n");
  vector<int> v;
  for(int n = 64; n >= 0; --n) {
    for(int K = 0; K < 65; ++K) {
      for(int Q = 0; Q < 65; ++Q) {
        for(int k = 0; k < 65; ++k) {
          if (!valid(K, Q, k, n)) continue;
          for(int turn = 0; turn < 2; ++turn) {
            int msk = mask(K, Q, k, n, turn);
            if (turn == 0 && valid(K, Q, k, n) && iswin(K, Q, k, n)) {
              vis[msk] = deg[msk] + 1;
              v.push_back(msk);
            }
          }
        }
      }
    }
  }
  printf("done precomputing 3.\n");

  printf("solving.\n");
  for(int i = 0; i < 100 * 2; ++i) { // search for mate in <= 100
    printf("solving %d\n", i);
    printf("%d win states.\n", int(v.size()));
    vector<int> nv;
    repi(cur, v) {
      if (*cur == 35416754) {
        printf("i = %d, cur = %d\n", i, 35416754);
        printf("ismate = %d\n", ismate(*cur));
      }

      if (i == 2 && !ismate(*cur)) {
        continue;
      }
      read(*cur);
      if (i > 0 && k == dead) continue;
      ans[*cur] = i;
      vector<int> conn;
      compfrom(K, Q, k, n, turn, conn);
      repi(j, conn) {
        ++vis[*j];
        if (i % 2 == 0) {
          if (vis[*j] == 1) {
            nv.push_back(*j);
          }
        } else {
          if (vis[*j] == deg[*j]) {
            nv.push_back(*j);
          }
        }
      }
      ans[*cur] = i;
//      pprintf("%d ", *cur);
    }
//    pprintf("-1\n");
    v = nv;
    printf("done with %d.\n", i);
  }

  for(int i = 0; i < MAXS; ++i) {
    pprintf("%c", ans[i] + 40);
  }
  printf("done with all.\n");
  return 0;
}

