#include "../activations.h"
#include "../layers.h"

void __layer_max_pooling2D(
	Data_t* input,
	size_t ilen, size_t jlen, size_t tlen,
	size_t stride_i, size_t stride_j,
	Data_t* output
) {
	const size_t out_ilen = ilen / stride_i;
	const size_t out_jlen = jlen / stride_j;
	const size_t out_tlen = tlen;
	size_t idx;

	// for each channel
	for(size_t t = 0; t < out_tlen; t++) {
		
		// for each submatrix 2D == for each output
		size_t i, j;
		for(i = 0; i < out_ilen; i++) {
			for(j = 0; j < out_jlen; j++) {

				// initial max value -> smallest value
				Data_t max_v;

				// for each element of submatrix
				size_t ki, kj;
				for(ki = 0; ki < stride_i; ki++) {
					for(kj = 0; kj < stride_j; kj++) {
						
						size_t ii = i * stride_i + ki;
						size_t jj = j * stride_j + kj;
						
                        idx = flat_idx_3d(ii, jj, t, jlen, tlen);
                        Data_t v = input[idx];

						// Get max value
						if((ki == 0 && kj == 0) || v > max_v) max_v = v;
					}
				}

				idx = flat_idx_3d(i, j, t, out_jlen, out_tlen);
				output[idx] = max_v;
			}
		}
	}
}
