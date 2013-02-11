#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "md5.h"


typedef struct {
  unsigned char c0;
  unsigned char c1;
  unsigned char c2;
  unsigned char c3;
  unsigned char c4;
  unsigned char c5;
  unsigned char word[32];
  unsigned char hash[32];
} test_data;

void run_test (test_data* t);

int main (void) {
  printf("main\n");

  test_data t;
  t.c0 = 'a';
  t.c1 = 'a';
  t.c2 = 'a';
  t.c3 = 'a';
  t.c4 = 'a';
  t.c5 = 'a';
  strcpy(t.word, "aaaaaa");
  strcpy(t.hash, "0b4e7a0e5fe84ad35fb5f95b9ceeac79");

  run_test(&t);

  return 0;
}


void run_test (test_data* t) {
  printf("running test for word: %s\n", t->word);

  unsigned char digest[16];
  unsigned char test_hash[32];
  int i;

  unsigned int a, b, c, d;
  unsigned int temp;

  // Iterate on the 1st letter -> use threadIdx.x
  unsigned int x_0, x_1 = 0;

  char cached_ascii_code_0 = t->c0;
  char cached_ascii_code_1 = t->c1;
  char cached_ascii_code_2 = t->c2;
  char cached_ascii_code_3 = t->c3;
  char cached_ascii_code_4 = t->c4;
  char cached_ascii_code_5 = t->c5;

  x_0  = cached_ascii_code_0;
  x_0 |= cached_ascii_code_1 << 8;
  x_0 |= cached_ascii_code_2 << 16;
  x_0 |= cached_ascii_code_3 << 24;

  x_1 = cached_ascii_code_4;
  x_1 |= cached_ascii_code_5 << 8;
  // Add padding bit
  x_1 |= 0x80 << 16;

  a = 0x67452301;
  b = 0xefcdab89;
  c = 0x98badcfe;
  d = 0x10325476;


  /* Round 1 */
  FF (a, b, c, d, x_0,  S11, 0xd76aa478); /* 1 */
  FF (d, a, b, c, x_1,  S12, 0xe8c7b756); /* 2 */
  FF (c, d, a, b, 0,    S13, 0x242070db); /* 3 */
  FF (b, c, d, a, 0,    S14, 0xc1bdceee); /* 4 */
  FF (a, b, c, d, 0,    S11, 0xf57c0faf); /* 5 */
  FF (d, a, b, c, 0,    S12, 0x4787c62a); /* 6 */
  FF (c, d, a, b, 0,    S13, 0xa8304613); /* 7 */
  FF (b, c, d, a, 0,    S14, 0xfd469501); /* 8 */
  FF (a, b, c, d, 0,    S11, 0x698098d8); /* 9 */
  FF (d, a, b, c, 0,    S12, 0x8b44f7af); /* 10 */
  FF (c, d, a, b, 0,    S13, 0xffff5bb1); /* 11 */
  FF (b, c, d, a, 0,    S14, 0x895cd7be); /* 12 */
  FF (a, b, c, d, 0,    S11, 0x6b901122); /* 13 */
  FF (d, a, b, c, 0,    S12, 0xfd987193); /* 14 */
  FF (c, d, a, b, X_14, S13, 0xa679438e); /* 15 */
  FF (b, c, d, a, 0,    S14, 0x49b40821); /* 16 */


 /* Round 2 */
  GG (a, b, c, d, x_1,  S21, 0xf61e2562); /* 17 */
  GG (d, a, b, c, 0,    S22, 0xc040b340); /* 18 */
  GG (c, d, a, b, 0,    S23, 0x265e5a51); /* 19 */
  GG (b, c, d, a, x_0,  S24, 0xe9b6c7aa); /* 20 */
  GG (a, b, c, d, 0,    S21, 0xd62f105d); /* 21 */
  GG (d, a, b, c, 0,    S22,  0x2441453); /* 22 */
  GG (c, d, a, b, 0,    S23, 0xd8a1e681); /* 23 */
  GG (b, c, d, a, 0,    S24, 0xe7d3fbc8); /* 24 */
  GG (a, b, c, d, 0,    S21, 0x21e1cde6); /* 25 */
  GG (d, a, b, c, X_14, S22, 0xc33707d6); /* 26 */
  GG (c, d, a, b, 0,    S23, 0xf4d50d87); /* 27 */
  GG (b, c, d, a, 0,    S24, 0x455a14ed); /* 28 */
  GG (a, b, c, d, 0,    S21, 0xa9e3e905); /* 29 */
  GG (d, a, b, c, 0,    S22, 0xfcefa3f8); /* 30 */
  GG (c, d, a, b, 0,    S23, 0x676f02d9); /* 31 */
  GG (b, c, d, a, 0,    S24, 0x8d2a4c8a); /* 32 */


  /* Round 3 */
  HH (a, b, c, d, 0,    S31, 0xfffa3942); /* 33 */
  HH (d, a, b, c, 0,    S32, 0x8771f681); /* 34 */
  HH (c, d, a, b, 0,    S33, 0x6d9d6122); /* 35 */
  HH (b, c, d, a, X_14, S34, 0xfde5380c); /* 36 */
  HH (a, b, c, d, x_1,  S31, 0xa4beea44); /* 37 */
  HH (d, a, b, c, 0,    S32, 0x4bdecfa9); /* 38 */
  HH (c, d, a, b, 0,    S33, 0xf6bb4b60); /* 39 */
  HH (b, c, d, a, 0,    S34, 0xbebfbc70); /* 40 */
  HH (a, b, c, d, 0,    S31, 0x289b7ec6); /* 41 */
  HH (d, a, b, c, x_0,  S32, 0xeaa127fa); /* 42 */
  HH (c, d, a, b, 0,    S33, 0xd4ef3085); /* 43 */
  HH (b, c, d, a, 0,    S34,  0x4881d05); /* 44 */
  HH (a, b, c, d, 0,    S31, 0xd9d4d039); /* 45 */
  HH (d, a, b, c, 0,    S32, 0xe6db99e5); /* 46 */
  HH (c, d, a, b, 0,    S33, 0x1fa27cf8); /* 47 */
  HH (b, c, d, a, 0,    S34, 0xc4ac5665); /* 48 */


  /* Round 4 */
  II (a, b, c, d, x_0,  S41, 0xf4292244); /* 49 */
  II (d, a, b, c, 0,    S42, 0x432aff97); /* 50 */
  II (c, d, a, b, X_14, S43, 0xab9423a7); /* 51 */
  II (b, c, d, a, 0,    S44, 0xfc93a039); /* 52 */
  II (a, b, c, d, 0,    S41, 0x655b59c3); /* 53 */
  II (d, a, b, c, 0,    S42, 0x8f0ccc92); /* 54 */
  II (c, d, a, b, 0,    S43, 0xffeff47d); /* 55 */
  II (b, c, d, a, x_1,  S44, 0x85845dd1); /* 56 */
  II (a, b, c, d, 0,    S41, 0x6fa87e4f); /* 57 */
  II (d, a, b, c, 0,    S42, 0xfe2ce6e0); /* 58 */
  II (c, d, a, b, 0,    S43, 0xa3014314); /* 59 */
  II (b, c, d, a, 0,    S44, 0x4e0811a1); /* 60 */
  II (a, b, c, d, 0,    S41, 0xf7537e82); /* 61 */
  II (d, a, b, c, 0,    S42, 0xbd3af235); /* 62 */
  II (c, d, a, b, 0,    S43, 0x2ad7d2bb); /* 63 */
  II (b, c, d, a, 0,    S44, 0xeb86d391); /* 64 */


  a += 0x67452301;
  b += 0xefcdab89;
  c += 0x98badcfe;
  d += 0x10325476;



  for (i = 0; i < 4; ++i)
    digest[i] = (unsigned char)(a >> ((i & 3) << 3));

  for (i = 4; i < 8; ++i)
    digest[i] = (unsigned char)(b >> ((i & 3) << 3));

  for (i = 8; i < 12; ++i)
    digest[i] = (unsigned char)(c >> ((i & 3) << 3));

  for (i = 12; i < 16; ++i)
    digest[i] = (unsigned char)(d >> ((i & 3) << 3));

  for (i = 0; i < 16; i++)
    sprintf(test_hash + i * 2, "%02x", digest[i]); 

  printf("Original hash: %s\n", t->hash);
  printf("Test hash:     %s\n", test_hash);
  printf("match: %s\n", !strcmp(t->hash, test_hash) ? "YES" : "NO");
}