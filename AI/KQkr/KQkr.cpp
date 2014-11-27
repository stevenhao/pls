#include <cstdio>
#include <vector>

using namespace std;

const int MAXS = 40000000;
const int NUMS = 5500000;
const int dead = 64;

#define pprintf(args...) fprintf(FOUT, args)  //, printf("logging "args);
#define repi(i, a) for(typeof((a).begin()) i = (a).begin(), _##i = (a).end(); i != _##i; ++i)
int deg[MAXS];
int vis[MAXS]; // vis[state] <-> #moves from state s.t. state is winning for white
char ans[MAXS]; // #black+white moves till king takes
char _ans[MAXS]; // #black+white moves till king takes

int K, Q, k, r, turn;
// turn = 0 -> black to move
// turn = 1 -> white to move

void read(int state) {
  turn = state % 2; state /= 2;
  r = state % 65; state /= 65;
  k = state % 65; state /= 65;
  Q = state % 65; state /= 65;
  K = state;
}

int mask(int K, int Q, int k, int r, int turn) {
  return turn + 2 * (r + 65 * (k + 65 * (Q + 65 * K)));
}

void fliph(int &x) {
  if (x != 64)
    x += 7 - 2 * (x % 8);
}

void flipv(int &x) {
  if (x != 64)
    x += 56 - 2 * (x - x % 8);
}

void flipd(int &x) {
  if (x != 64)
    x = 8 * (x % 8) + x / 8;
}

int _mask(int K, int Q, int k, int n, int turn) {
  int r = K % 8, c = K / 8;
  if (r >= 4) {
    fliph(Q); fliph(k); fliph(n);
    r = 7 - r;
  }

  if (c >= 4) {
    flipv(Q);
    flipv(k);
    flipv(n);
    c = 7 - c;
  }

  if (r > c) {
    flipd(Q);
    flipd(k);
    flipd(n);
    int _r = r;
    r = c;
    c = _r;
  }

  K = r * (r + 1) / 2 + c;
  int ret =  turn + 2 * (n + 65 * (k + 65 * (Q + 65 * K)));
  //printf("ret = %d\n", ret);
  return ret;
}

bool valid(int K, int Q, int k, int r) {
  if (K != dead) if (K == Q || K == k || K == r) return false;
  if (Q != dead) if (Q == k || Q == r) return false;
  if (k != dead) if (k == r) return false;
  return true;
}

bool iswin(int K, int Q, int k, int r) {
  return K != dead && k == dead;
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

void compfrom(int K, int Q, int k, int r, int turn, vector<int> &v) {
  // states that could have transitioned to cur
  if (turn == 1) { // black just moved
    // k moved
    repi(_nk, km[k]) {
      int nK = K, nQ = Q, nk = k, nr = r, nt = 0;
      nk = *_nk;
      if (nK == nk) continue;
      if (nQ == nk) continue;
      if (nk == nr) continue;

      v.push_back(mask(nK, nQ, nk, nr, nt));
      if (nK == dead) v.push_back(mask(k, nQ, nk, nr, nt));
      if (nQ == dead) v.push_back(mask(nK, k, nk, nr, nt));

    }
    // r moved.

    for(int i = 0; i < 8; ++i) {
      repi(_nr, rm[r][i]) {
        int nK = K, nQ = Q, nk = k, nr = r, nt = 0;
        nr = *_nr;
        if (nK == nr) break;
        if (nQ == nr) break;
        if (nk == nr) break;
        v.push_back(mask(nK, nQ, nk, nr, nt));

        if (nK == dead) v.push_back(mask(r, nQ, nk, nr, nt));
        if (nQ == dead) v.push_back(mask(nK, r, nk, nr, nt));

      }
    }
  } else {
    repi(_nK, km[K]) {
      int nK = K, nQ = Q, nk = k, nr = r, nt = 1;
      nK = *_nK;
      if (nK == nQ) continue;
      if (nK == nk) continue;
      if (nK == nr) continue;
      v.push_back(mask(nK, nQ, nk, nr, nt));
      if (nk == dead) v.push_back(mask(nK, nQ, K, nr, nt));
      if (nr == dead) v.push_back(mask(nK, nQ, nk, K, nt));

    }

    for(int i = 0; i < 8; ++i) {
      repi(_nQ, qm[Q][i]) {
        int nK = K, nQ = Q, nk = k, nr = r, nt = 1;
        nQ = *_nQ;
        if (nQ == nK) break;
        if (nQ == nk) break;
        if (nQ == nr) break;
        v.push_back(mask(nK, nQ, nk, nr, nt));
        if (nk == dead) {
          v.push_back(mask(nK, nQ, Q, nr, nt));
        }
        if (nr == dead) v.push_back(mask(nK, nQ, nk, Q, nt));
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
        for(int r = 0; r < 65; ++r) {
          if (!valid(K, Q, k, r)) continue;
          for(int turn = 0; turn < 2; ++turn) {
            tmp.clear();
            compfrom(K, Q, k, r, turn, tmp);
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
  for(int r = 64; r >= 0; --r) {
    for(int K = 0; K < 65; ++K) {
      for(int Q = 0; Q < 65; ++Q) {
        for(int k = 0; k < 65; ++k) {
          if (!valid(K, Q, k, r)) continue;
          for(int turn = 0; turn < 2; ++turn) {
            int msk = mask(K, Q, k, r, turn);
            if (turn == 0 && valid(K, Q, k, r) && iswin(K, Q, k, r)) {
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
      compfrom(K, Q, k, r, turn, conn);
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

  for(int K = 0; K < 65; ++K) {
    for(int Q = 0; Q < 65; ++Q) {
      for(int k = 0; k < 65; ++k) {
        for(int r = 0; r < 65; ++r) {
          for(int turn = 0; turn < 2; ++turn) {
            int omsk = mask(K, Q, k, r, turn);
            int nmsk = _mask(K, Q, k, r, turn);
            _ans[nmsk] = ans[omsk];
          }
        }
      }
    }
  }

  for(int i = 0; i < NUMS; ++i) {
    pprintf("%c", _ans[i] + 40);
  }
  printf("done with all.\n");
  return 0;
}

