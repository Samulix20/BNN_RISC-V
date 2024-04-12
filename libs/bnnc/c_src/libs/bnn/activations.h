#ifndef BNN_H
#define BNN_H

#include "types.h"
#include "random.h"

inline Data_t ReLU(const Data_t v) {
	return v > 0 ? v : 0;
}

// Asumes S is a power of 2 exponent and lower than 28
inline Softmax_t to_Softmax_t(const Iop_t v, const Scale_t S) {
	return ((Softmax_t) v) << (S_Softmax - S);
}

#define TAYLOR_EXP_LOOKUP_TABLE_LEN    6
extern const int32 EXP_TAYLOR_DENOM_F32_28[TAYLOR_EXP_LOOKUP_TABLE_LEN];

#define INTEGER_EXP_LOOKUP_TABLE_LEN    20
extern const int32 INTEGER_EXP_LOOKUP_TABLE_F32_28[INTEGER_EXP_LOOKUP_TABLE_LEN];

// https://en.wikipedia.org/wiki/Taylor_series
// Calculates exp function using the Taylor series approximation
inline Softmax_t taylor_exp(Softmax_t v) {
	Softmax_t result = ITOFIX(1, S_Softmax, Softmax_t) + v;
	Softmax_t numerator = v;
	for(size_t i = 0; i < TAYLOR_EXP_LOOKUP_TABLE_LEN; i++) {  
		numerator = _MULFIX(numerator, v, S_Softmax, Softmax_t, int64);
		result += _MULFIX(numerator, EXP_TAYLOR_DENOM_F32_28[i], S_Softmax, Softmax_t, int64);
	}
	return result;
}

/*
v = (integer) a + (decimal) b
exp(v) = exp(a + b) = exp(a) * exp(b)
exp(a) is obtained using a lookup table
exp(b) is obteined using the Taylor Series

v must be negative to get results in [0,1] range

Returns result with F_BITS_SOFTMAX precision, values in [0,1]
*/
inline Softmax_t expfix(Iop_t v, Scale_t S) {
	// Only increase data type size
	Softmax_t aux = (Softmax_t) v;

	// abs Integer part
	u_Softmax_t integer_part = -aux >> S;
	// Exp(Integer part)
	Softmax_t ei;
	// Value too small
	if(integer_part >= INTEGER_EXP_LOOKUP_TABLE_LEN) return 0;
	else ei = INTEGER_EXP_LOOKUP_TABLE_F32_28[integer_part];

	// Decimal part
	Softmax_t decimal_part = to_Softmax_t(aux + (integer_part << S), S);
	// Exp(Decimal part)
	Softmax_t ed = taylor_exp(decimal_part);

	return _MULFIX(ei, ed, S_Softmax, Softmax_t, int64);
}

// Calculates softmax function of array v
// Uses v - max(v) to avoid overflows
// Internally uses Softmax_t (F32_28) to get good decimal precision
inline void softmax(Iop_t* v_in, Softmax_t* v_out, Iop_t max, Scale_t S, size_t n) {
	Softmax_t denom = 0;
	Softmax_t tmp[n];

	// Get denominator and substract max
	// expfix returns in T2
	for(size_t i = 0; i < n; i++) {
		tmp[i] = expfix(v_in[i] - max, S);
		denom += tmp[i];
	}

	// Avoid doing multiple divisions
	denom = _DIVFIX(ITOFIX(1, S_Softmax, int64), denom, S_Softmax, Softmax_t, int64);

	// numerator * (1/denominator)
	for(size_t i = 0; i < n; i++) {
		v_out[i] = _MULFIX(tmp[i], denom, S_Softmax, Softmax_t, int64);
	}
}

#endif
