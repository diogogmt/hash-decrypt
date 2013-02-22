#include <cuda_runtime.h>

#include "book.h"
// #include "libs/cuPrintf.cu"
#include "md5.h"


#define T_MASK ((md5_word_t)~0)
#define T1    0xd76aa478
#define T2    0xe8c7b756
#define T3    0x242070db
#define T4    0xc1bdceee
#define T5    0xf57c0faf
#define T6    0x4787c62a
#define T7    0xa8304613
#define T8    0xfd469501
#define T9    0x698098d8
#define T10   0x8b44f7af
#define T11   0xffff5bb1
#define T12   0x895cd7be
#define T13   0x6b901122
#define T14   0xfd987193
#define T15   0xa679438e
#define T16   0x49b40821
#define T17   0xf61e2562
#define T18   0xc040b340
#define T19   0x265e5a51
#define T20   0xe9b6c7aa
#define T21   0xd62f105d
#define T22   0x02441453
#define T23   0xd8a1e681
#define T24   0xe7d3fbc8
#define T25   0x21e1cde6
#define T26   0xc33707d6
#define T27   0xf4d50d87
#define T28   0x455a14ed
#define T29   0xa9e3e905
#define T30   0xfcefa3f8
#define T31   0x676f02d9
#define T32   0x8d2a4c8a
#define T33   0xfffa3942
#define T34   0x8771f681
#define T35   0x6d9d6122
#define T36   0xfde5380c
#define T37   0xa4beea44
#define T38   0x4bdecfa9
#define T39   0xf6bb4b60
#define T40   0xbebfbc70
#define T41   0x289b7ec6
#define T42   0xeaa127fa
#define T43   0xd4ef3085
#define T44   0x04881d05
#define T45   0xd9d4d039
#define T46   0xe6db99e5
#define T47   0x1fa27cf8
#define T48   0xc4ac5665
#define T49   0xf4292244
#define T50   0x432aff97
#define T51   0xab9423a7
#define T52   0xfc93a039
#define T53   0x655b59c3
#define T54   0x8f0ccc92
#define T55   0xffeff47d
#define T56   0x85845dd1
#define T57   0x6fa87e4f
#define T58   0xfe2ce6e0
#define T59   0xa3014314
#define T60   0x4e0811a1
#define T61   0xf7537e82
#define T62   0xbd3af235
#define T63   0x2ad7d2bb
#define T64   0xeb86d391


#define STR_SIZE 6
// If the string has 4 chars, it has a size of 32 bits
// X is a unsigned int pointer, it points to 32 bit chuncks of data
// X[0] will be the whole 4 byte string
// the byte right after the string has the value 0x80, which was translating to 128 since the first nibble is 0 and the second is 8
// a byte with the second nibble as 8 is the decimal 128 --> 1000 0000
// the formula for X_14 is STR_SIZE << 3 as long the string has less than 32 bytes
// after that the formula is (STR_SIZE - 32) << 3 and X_15 will be 1
// We'll be focusing on string less than 32 bytes for now
#define X_1 128
// #define X_14 (STR_SIZE << 3)
#define X_14 (STR_SIZE << 3)
#define ZERO 0

#define WORD_SIZE (STR_SIZE)

/* Round 1. */
/* Let [abcd k s i] denote the operation
   a = b + ((a + F(b,c,d) + X[k] + T[i]) <<< s).
*/
/* Do the following 16 operations. */
// For the first operation the values of a,b,c,d are static
// ~b == d
// Still need to run some calculations and read the md5 RFC to understand what's going on
// For now all we know is that we can replace the first set of calculations by d
// t = a + ((b & c) | (~b & d)) + x_0 +  T1;   a = ((t << 7)   | (t >> (25))) + b; \

#define ROUND_1 \
  t = a + (c) + x_0                  +  T1;   a = ((t << 7)   | (t >> (25))) + b; \
  t = d + ((a & b) | (~a & c)) + x_1 +  T2;   d = ((t << 12)  | (t >> (20))) + a; \
  t = c + ((d & a) | (~d & b)) +        T3;   c = ((t << 17)  | (t >> (15))) + d; \
  t = b + ((c & d) | (~c & a)) +        T4;   b = ((t << 22)  | (t >> (10))) + c; \
  t = a + ((b & c) | (~b & d)) +        T5;   a = ((t << 7)   | (t >> (25))) + b; \
  t = d + ((a & b) | (~a & c)) +        T6;   d = ((t << 12)  | (t >> (20))) + a; \
  t = c + ((d & a) | (~d & b)) +        T7;   c = ((t << 17)  | (t >> (15))) + d; \
  t = b + ((c & d) | (~c & a)) +        T8;   b = ((t << 22)  | (t >> (10))) + c; \
  t = a + ((b & c) | (~b & d)) +        T9;   a = ((t << 7)   | (t >> (25))) + b; \
  t = d + ((a & b) | (~a & c)) +        T10;  d = ((t << 12)  | (t >> (20))) + a; \
  t = c + ((d & a) | (~d & b)) +        T11;  c = ((t << 17)  | (t >> (15))) + d; \
  t = b + ((c & d) | (~c & a)) +        T12;  b = ((t << 22)  | (t >> (10))) + c; \
  t = a + ((b & c) | (~b & d)) +        T13;  a = ((t << 7)   | (t >> (25))) + b; \
  t = d + ((a & b) | (~a & c)) +        T14;  d = ((t << 12)  | (t >> (20))) + a; \
  t = c + ((d & a) | (~d & b)) + X_14 + T15;  c = ((t << 17)  | (t >> (15))) + d; \
  t = b + ((c & d) | (~c & a)) +        T16;  b = ((t << 22)  | (t >> (10))) + c; \


/* Round 2. */
/* Let [abcd k s i] denote the operation
   a = b + ((a + G(b,c,d) + X[k] + T[i]) <<< s).
*/
/* Do the following 16 operations. */
#define ROUND_2 \
  t = a + ((b & d) | (c & ~d)) + x_1 +  T17; a = ((t << 5)  | (t >> (27))) + b; \
  t = d + ((a & c) | (b & ~c)) +        T18; d = ((t << 9)  | (t >> (23))) + a; \
  t = c + ((d & b) | (a & ~b)) +        T19; c = ((t << 14) | (t >> (18))) + d; \
  t = b + ((c & a) | (d & ~a)) + x_0 +  T20; b = ((t << 20) | (t >> (12))) + c; \
  t = a + ((b & d) | (c & ~d)) +        T21; a = ((t << 5)  | (t >> (27))) + b; \
  t = d + ((a & c) | (b & ~c)) +        T22; d = ((t << 9)  | (t >> (23))) + a; \
  t = c + ((d & b) | (a & ~b)) +        T23; c = ((t << 14) | (t >> (18))) + d; \
  t = b + ((c & a) | (d & ~a)) +        T24; b = ((t << 20) | (t >> (12))) + c; \
  t = a + ((b & d) | (c & ~d)) +        T25; a = ((t << 5)  | (t >> (27))) + b; \
  t = d + ((a & c) | (b & ~c)) + X_14 + T26; d = ((t << 9)  | (t >> (23))) + a; \
  t = c + ((d & b) | (a & ~b)) +        T27; c = ((t << 14) | (t >> (18))) + d; \
  t = b + ((c & a) | (d & ~a)) +        T28; b = ((t << 20) | (t >> (12))) + c; \
  t = a + ((b & d) | (c & ~d)) +        T29; a = ((t << 5)  | (t >> (27))) + b; \
  t = d + ((a & c) | (b & ~c)) +        T30; d = ((t << 9)  | (t >> (23))) + a; \
  t = c + ((d & b) | (a & ~b)) +        T31; c = ((t << 14) | (t >> (18))) + d; \
  t = b + ((c & a) | (d & ~a)) +        T32; b = ((t << 20) | (t >> (12))) + c; \


/* Round 3. */
/* Let [abcd k s t] denote the operation
   a = b + ((a + H(b,c,d) + X[k] + T[i]) <<< s).
*/
/* Do the following 16 operations. */
#define ROUND_3 \
  t = a + (b ^ c ^ d) +         T33; a = ((t << 4)  | (t >> (28))) + b; \
  t = d + (a ^ b ^ c) +         T34; d = ((t << 11) | (t >> (21))) + a; \
  t = c + (d ^ a ^ b) +         T35; c = ((t << 16) | (t >> (16))) + d; \
  t = b + (c ^ d ^ a) + X_14 +  T36; b = ((t << 23) | (t >> (9)))  + c; \
  t = a + (b ^ c ^ d) + x_1 +   T37; a = ((t << 4)  | (t >> (28))) + b; \
  t = d + (a ^ b ^ c) +         T38; d = ((t << 11) | (t >> (21))) + a; \
  t = c + (d ^ a ^ b) +         T39; c = ((t << 16) | (t >> (16))) + d; \
  t = b + (c ^ d ^ a) +         T40; b = ((t << 23) | (t >> (9)))  + c; \
  t = a + (b ^ c ^ d) +         T41; a = ((t << 4)  | (t >> (28))) + b; \
  t = d + (a ^ b ^ c) + x_0 +   T42; d = ((t << 11) | (t >> (21))) + a; \
  t = c + (d ^ a ^ b) +         T43; c = ((t << 16) | (t >> (16))) + d; \
  t = b + (c ^ d ^ a) +         T44; b = ((t << 23) | (t >> (9)))  + c; \
  t = a + (b ^ c ^ d) +         T45; a = ((t << 4)  | (t >> (28))) + b; \
  t = d + (a ^ b ^ c) +         T46; d = ((t << 11) | (t >> (21))) + a; \
  t = c + (d ^ a ^ b) +         T47; c = ((t << 16) | (t >> (16))) + d; \
  t = b + (c ^ d ^ a) +         T48; b = ((t << 23) | (t >> (9)))  + c; \


/* Round 4. */
/* Let [abcd k s t] denote the operation
   a = b + ((a + I(b,c,d) + X[k] + T[i]) <<< s).
*/
/* Do the following 16 operations. */
#define ROUND_4 \
  t = a + (c ^ (b | ~d)) + x_0 +  T49; a = ((t << 6)  | (t >> (26))) + b; \
  t = d + (b ^ (a | ~c)) +        T50; d = ((t << 10) | (t >> (22))) + a; \
  t = c + (a ^ (d | ~b)) + X_14 + T51; c = ((t << 15) | (t >> (17))) + d; \
  t = b + (d ^ (c | ~a)) +        T52; b = ((t << 21) | (t >> (11))) + c; \
  t = a + (c ^ (b | ~d)) +        T53; a = ((t << 6)  | (t >> (26))) + b; \
  t = d + (b ^ (a | ~c)) +        T54; d = ((t << 10) | (t >> (22))) + a; \
  t = c + (a ^ (d | ~b)) +        T55; c = ((t << 15) | (t >> (17))) + d; \
  t = b + (d ^ (c | ~a)) + x_1 +  T56; b = ((t << 21) | (t >> (11))) + c; \
  t = a + (c ^ (b | ~d)) +        T57; a = ((t << 6)  | (t >> (26))) + b; \
  t = d + (b ^ (a | ~c)) +        T58; d = ((t << 10) | (t >> (22))) + a; \
  t = c + (a ^ (d | ~b)) +        T59; c = ((t << 15) | (t >> (17))) + d; \
  t = b + (d ^ (c | ~a)) +        T60; b = ((t << 21) | (t >> (11))) + c; \
  t = a + (c ^ (b | ~d)) +        T61; a = ((t << 6)  | (t >> (26))) + b; \
  t = d + (b ^ (a | ~c)) +        T62; d = ((t << 10) | (t >> (22))) + a; \
  t = c + (a ^ (d | ~b)) +        T63; c = ((t << 15) | (t >> (17))) + d; \
  t = b + (d ^ (c | ~a)) +        T64; b = ((t << 21) | (t >> (11))) + c; \

void create_md5_hash_str (const char* word, char* hash_str);
void break_down_hash (char* hash, char* hash_str);
int hex_to_decimal (char c);

int brute_force (char* original_word);



 __constant__ char constant_ascii_codes[64];
 __constant__ int constant_hash_to_break[4];

__global__ void kernel(int* global_word, char offset_1, char offset_2, char offset_3, char offset_4, char offset_5) {

  unsigned int a, b, c, d;
  unsigned int t;

  // Iterate on the 1st letter -> use threadIdx.x
  int x_0 = constant_ascii_codes[threadIdx.x];
  int x_1;

  char cached_ascii_code_1 = constant_ascii_codes[offset_1+threadIdx.y];
  char cached_ascii_code_2 = constant_ascii_codes[offset_2+blockIdx.x];
  char cached_ascii_code_3 = constant_ascii_codes[offset_3+blockIdx.y];
  char cached_ascii_code_4 = constant_ascii_codes[offset_4+blockIdx.z];
  char cached_ascii_code_5 = constant_ascii_codes[offset_5];

  int cached_hash_to_break_1 = constant_hash_to_break[0];
  int cached_hash_to_break_2 = constant_hash_to_break[1];
  int cached_hash_to_break_3 = constant_hash_to_break[2];
  int cached_hash_to_break_4 = constant_hash_to_break[3];

  // Iterate on the 2th letter -> use threadIdx.y
  // Block has 16 threads on the y dimension
  // That means this code will iterate 16 times on the ascii_code values
  x_0 |= cached_ascii_code_1 << 8;

  // Iterate on the 3th letter -> use blockIdx.x
  // Grid has 16 threads on the x dimension and 4 on the y
  // That means that blockIdx.x will iterate from 0-16 and on the host we launch
  // a kernel 4 times increments the offset_2 by 16 each time
  // This way all possible combinations are tested
  x_0 |= cached_ascii_code_2 << 16;

  // Iterate on the 4th letter -> use blockIdx.y
  x_0 |= cached_ascii_code_3 << 24;

  // Iterate on the 5th letter -> use blockIdx.z
  x_1 = cached_ascii_code_4;

  // Iterate on the 6th letter -> launch kernel 64 times for all 5 letter combinations
  x_1 |= cached_ascii_code_5 << 8;

  // Add padding bit
  x_1 |= 0x80 << 16;

  a = 0x67452301;
  b = 0xefcdab89;
  c = 0x98badcfe;
  d = 0x10325476;

  ROUND_1
  ROUND_2
  ROUND_3
  ROUND_4
  
  if (cached_hash_to_break_1  == a   &&
      cached_hash_to_break_2  == b   &&
      cached_hash_to_break_3  == c   &&
      cached_hash_to_break_4  == d
    ) {
    // cuPrintf("\n**************************found*****************\n\n");
    global_word[0] = x_0;
    global_word[1] = x_1 & 0xffff;
  }


  // if (threadIdx.x == 0 && offset_1+threadIdx.y == 0 && offset_2+blockIdx.x == 0 && offset_3+blockIdx.y == 0 && offset_4+blockIdx.z == 0) {
  // // if (threadIdx.x == 0) {
  //   cuPrintf("%c,%c,%c,%c,%c,%c\n", constant_ascii_codes[threadIdx.x], constant_ascii_codes[offset_1+threadIdx.y],
  //     constant_ascii_codes[offset_2+blockIdx.x], constant_ascii_codes[offset_3+blockIdx.y],
  //     constant_ascii_codes[offset_4+blockIdx.z], constant_ascii_codes[offset_5+blockIdx.z]);
  //   cuPrintf("1: %d - 2: %d - 3: %d - 4: %d - 5: %d\n", offset_1, offset_2, offset_3, offset_4, offset_5);
  //   cuPrintf("tx: %d - ty: %d - bx: %d - by: %d - bz: %d\n", threadIdx.x, threadIdx.y, blockIdx.x, blockIdx.y, blockIdx.z);
  //   cuPrintf("a: %u\n", a);
  //   cuPrintf("b: %u\n", b);
  //   cuPrintf("c: %u\n", c);
  //   cuPrintf("d: %u\n", d);
  // }

}

int main (int argc, char *argv[]) {
  if (argc != 2) {
    printf("**invalid number of arguments**\n");
    return 1;
  }
  char original_word[10];
  strcpy(original_word, argv[1]);

  int rv = 0;
  rv = brute_force(original_word);

  printf("Broke Hash? %s\n", rv == 1 ? "YES" : "NO");

  return 0;
}



int brute_force (char* original_word) {
  cudaDeviceProp prop;
  int whichDevice;
  HANDLE_ERROR(cudaGetDevice( & whichDevice));
  HANDLE_ERROR(cudaGetDeviceProperties( & prop, whichDevice));
  if (!prop.deviceOverlap) {
    printf("Device will not handle overlaps, so no "
    "speed up from streams\n");
    return 0;
  }

  char hash_str[32];
  char h_hash[16];
  

  create_md5_hash_str(original_word, hash_str);

  fprintf(stdout, "original_word: |%s|\n", original_word);
  fprintf(stdout, "hash to break: %s\n", hash_str);

  break_down_hash(h_hash, hash_str);

  int* X = (int *)h_hash;
  printf("X[0]: %u\n", X[0]);
  printf("X[1]: %u\n", X[1]);
  printf("X[2]: %u\n", X[2]);
  printf("X[3]: %u\n\n\n", X[3]);

  // After the digest is finished those operations are made
  // Since we are the ones creating the digest there is no need perform those operations
  X[0] -= 0x67452301;
  X[1] -= 0xefcdab89;
  X[2] -= 0x98badcfe;
  X[3] -= 0x10325476;

  printf("X[0]: %u\n", X[0]);
  printf("X[1]: %u\n", X[1]);
  printf("X[2]: %u\n", X[2]);
  printf("X[3]: %u\n", X[3]);  

  // initialize the stream
  cudaStream_t stream;
  HANDLE_ERROR(cudaStreamCreate( & stream));


  char host_ascii_codes[64];
  char* host_word;
  // allocate page-locked memory, used to stream
  HANDLE_ERROR(cudaHostAlloc((void**)&host_word, sizeof(char) * WORD_SIZE, cudaHostAllocDefault));

  // int* device_hash_to_break;
  int* device_word;
  HANDLE_ERROR(cudaMalloc((void**)&device_word, sizeof(char) * WORD_SIZE));

  int ascci_counter = 0;
  for (int i = 48; i <= 57; i++) {
    host_ascii_codes[ascci_counter++] = i;
  }
  for (int i = 65; i <= 90; i++) {
    host_ascii_codes[ascci_counter++] = i;
  }
  for (int i = 97; i <= 122; i++) {
    host_ascii_codes[ascci_counter++] = i;
  }
  host_ascii_codes[62] = 63; // ?
  host_ascii_codes[63] = 64; // @

  HANDLE_ERROR(cudaMemcpyToSymbol(constant_ascii_codes, host_ascii_codes, sizeof(char) * 64));
  HANDLE_ERROR(cudaMemcpyToSymbol(constant_hash_to_break, X, sizeof(int) * 4));

  cudaEvent_t start, stop;
  float elapsedTime;
  // start the timers
  HANDLE_ERROR(cudaEventCreate( & start));
  HANDLE_ERROR(cudaEventCreate( & stop));
  HANDLE_ERROR(cudaEventRecord(start, 0));

  // cudaPrintfInit();
  dim3 dimBlock(64, 16, 1);
  dim3 dimGrid(16, 16, 16);

  for (int it_1 = 0; it_1 < 64; it_1 += 16) { // ThreadIdx.y
    for (int it_2 = 0; it_2 < 64; it_2 += 16) { // BlockIdx.x
      for (int it_3 = 0; it_3 < 64; it_3 += 16) { // BlockIdx.y
        for (int it_4 = 0; it_4 < 64; it_4 += 16) { // BlockIdx.z
          for (int it_5 = 0; it_5 < 64; it_5 += 1) { 
            kernel <<<dimGrid, dimBlock, 0, stream>>>(device_word,
              it_1, it_2,
              it_3, it_4,
              it_5);
            // copy the data from device to locked memory
            HANDLE_ERROR(cudaMemcpyAsync(host_word, device_word, sizeof(char) * WORD_SIZE, cudaMemcpyDeviceToHost, stream));
          }
          // printf("after loop\n");
          // copy result chunk from locked to full buffer
          HANDLE_ERROR(cudaStreamSynchronize(stream));
          // printf("after sync.\n");

          HANDLE_ERROR(cudaEventRecord(stop, 0));
          HANDLE_ERROR(cudaEventSynchronize(stop));
          HANDLE_ERROR(cudaEventElapsedTime( & elapsedTime, start, stop));
          printf("[%d, %d, %d, %d] Time taken:  %3.1f ms\n", it_1, it_2, it_3, it_4, elapsedTime);
          

          int broke = 1;
          for (int j = 0; j < WORD_SIZE; j++) {
            if (original_word[j] != host_word[j]) {
              // printf("Did not find a match, going to next iteration.\n");
              broke = 0;
              break;
            }
          }

          if (broke) {
            printf("Found a match!\n");
            for (int i = 0; i < WORD_SIZE; i++) {
              printf("%c,", host_word[i]);
            }
            printf("|\n");
            HANDLE_ERROR(cudaEventRecord(stop, 0));
            HANDLE_ERROR(cudaEventSynchronize(stop));
            HANDLE_ERROR(cudaEventElapsedTime( & elapsedTime, start, stop));
            printf("[%d, %d] Time taken:  %3.1f ms\n", it_1, it_2, elapsedTime);
            return 1;
          }
        } // End Loop 4
      } // End Loop 3
    } // End Loop 2
  } // End Loop 1

  // cudaPrintfDisplay(stdout, true);
  // cudaPrintfEnd();


  // cleanup the streams and memory
  HANDLE_ERROR(cudaFreeHost(host_word));
  HANDLE_ERROR(cudaFree(device_word));
  HANDLE_ERROR(cudaStreamDestroy(stream));
  return 0;  
}




// Create hash string for |word|
// This is the hash string to the original hash we are trying to break
// We use the hash string to create the 16 8bit hexadecinal chunks
void create_md5_hash_str(const char* word, char* hash_str) {
  int di;

  md5_state_t state;
  md5_byte_t digest[16];  

  md5_init(&state);
  md5_append(&state, (const md5_byte_t *)word, strlen(word));
  md5_finish(&state, digest);
  
  for (di = 0; di < 16; di++) {
    sprintf(hash_str + di * 2, "%02x", digest[di]); 
  }
}

void break_down_hash (char* hash, char* hash_str) {
  int i, j;
  int digest = 0;
  int dec1 = 0;
  int dec2 = 0;
  for (i = 0, j = 0; i < 32; i += 2, j++) {
    dec1 = hex_to_decimal(hash_str[i]);
    dec2 = hex_to_decimal(hash_str[i+1]);
    // fprintf(stdout, "dec1: %d\n", dec1);
    // fprintf(stdout, "dec2: %d\n", dec2);
    digest =  dec1 * 16 + dec2;
    hash[j] = digest;
    // fprintf(stdout, "i %d - digest: %d\n", i, digest);
  }
}

int hex_to_decimal (char c) {
  switch (c) {
    case '0':
      return 0;
    case '1':
      return 1;
    case '2':
      return 2;
    case '3':
      return 3;
    case '4':
      return 4;
    case '5':
      return 5;
    case '6':
      return 6;
    case '7':
      return 7;
    case '8':
      return 8;
    case '9':
      return 9;
    case 'a':
    case 'A':
      return 10;
    case 'b':
    case 'B':
      return 11;
    case 'c':
    case 'C':
      return 12;
    case 'd':
    case 'D':
      return 13;
    case 'e':
    case 'E':
      return 14;
    case 'f':
    case 'F':
      return 15;
    default:
      fprintf(stdout, "FAILED to get convert %c to decimal\n", c);
  }

  return -1;
}







