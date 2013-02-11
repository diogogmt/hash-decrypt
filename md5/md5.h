#define STR_SIZE 6
// the formula for X_14 is STR_SIZE << 3 as long the string has less than 32 bytes
// after that the formula is (STR_SIZE - 32) << 3 and X_15 will be 1
// We'll be focusing on string less than 32 bytes for now
#define X_14 (STR_SIZE << 3)

#define WORD_SIZE (STR_SIZE)

#define S11 7
#define S12 12
#define S13 17
#define S14 22
#define S21 5
#define S22 9
#define S23 14
#define S24 20
#define S31 4
#define S32 11
#define S33 16
#define S34 23
#define S41 6
#define S42 10
#define S43 15
#define S44 21


/* F, G, H and I are basic MD5 functions.
 */
#define F(x, y, z) (((x) & (y)) | ((~x) & (z)))
#define G(x, y, z) (((x) & (z)) | ((y) & (~z)))
#define H(x, y, z) ((x) ^ (y) ^ (z))
#define I(x, y, z) ((y) ^ ((x) | (~z)))

/* ROTATE_LEFT rotates x left n bits.
 */
#define ROTATE_LEFT(x, n) (((x) << (n)) | ((x) >> (32-(n))))


/* FF, GG, HH, and II transformations for rounds 1, 2, 3, and 4.
Rotation is separate from addition to prevent recomputation.
 */
#define FF(a, b, c, d, x, s, ac) { \
 (a) += F ((b), (c), (d)) + (x) + (ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
}

#define GG(a, b, c, d, x, s, ac) { \
 (a) += G ((b), (c), (d)) + (x) + (ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
}

#define HH(a, b, c, d, x, s, ac) { \
 (a) += H ((b), (c), (d)) + (x) + (ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
}

#define II(a, b, c, d, x, s, ac) { \
 (a) += I ((b), (c), (d)) + (x) + (ac); \
 (a) = ROTATE_LEFT ((a), (s)); \
 (a) += (b); \
}

