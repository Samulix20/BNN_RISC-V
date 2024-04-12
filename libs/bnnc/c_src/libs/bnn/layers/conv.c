#include "../activations.h"
#include "../layers.h"

void __bnn_layer_conv2D_valid_ReLU (
	Data_t* t_q_input, 
    size_t ilen, size_t jlen, size_t tlen,
	size_t num_filters, size_t kernel_size,
	Mu_t** mu_kernels_list, 
    Sigma_t** sigma_kernels_list, 
    Bias_t* v_q_bias,
	Data_t* t_q_output,
    Scale_t S
) {
	const size_t out_ilen = ilen - kernel_size + 1;
	const size_t out_jlen = jlen - kernel_size + 1;
	const size_t out_tlen = num_filters;
	size_t idx;

	// for each filter == for each output channel
	for(size_t t = 0; t < out_tlen; t++) {

		Mu_t* t_q_mu = mu_kernels_list[t];
		Sigma_t* t_q_sigma = sigma_kernels_list[t];
        Iop_t q_bias = (Iop_t) v_q_bias[t];

		// for each submatrix
		size_t i, j;
		for(i = 0; i < out_ilen; i++) {
			for(j = 0; j < out_jlen; j++) {
				
				Iop_t acc = 0;
				
				// for each element of 2D kernel and channels
				size_t ki, kj, tt;
				for(ki = 0; ki < kernel_size; ki++) {
					for(kj = 0; kj < kernel_size; kj++) {
						for(tt = 0; tt < tlen; tt++) {

							size_t ii = i + ki;
							size_t jj = j + kj;

							// Sample weight
							idx = flat_idx_3d(ki, kj, tt, kernel_size, tlen);

                            Iop_t q_sigma = (Iop_t) t_q_sigma[idx];
							Iop_t q_mu = (Iop_t) t_q_mu[idx];
                            Iop_t u = generator(S);
                            Iop_t w = ((q_sigma * u) >> S) + q_mu;
                            
                            idx = flat_idx_3d(ii, jj, tt, jlen, tlen);
                            
                            Iop_t q_x = (Iop_t) t_q_input[idx];
                            acc += w * q_x;
						}
					}
				}

                Iop_t q_acc = acc >> S;
				Data_t q_o = (Data_t) (q_acc + q_bias);
                
				idx = flat_idx_3d(i, j, t, out_jlen, out_tlen);
				t_q_output[idx] = ReLU(q_o);
			}
		}
	}
}


void __bnn_layer_conv2D_same_ReLU (
    Data_t* t_q_input, 
    size_t ilen, size_t jlen, size_t tlen,
	size_t num_filters, size_t kernel_size,
	Mu_t** mu_kernels_list, 
    Sigma_t** sigma_kernels_list, 
    Bias_t* v_q_bias,
	Data_t* t_q_output,
    Scale_t S
) {
	// Padding same, same input and output size
	const size_t out_ilen = ilen;
	const size_t out_jlen = jlen;

	// Get limits until pad starts
	const size_t max_ilen = ilen - kernel_size + 1;
	const size_t max_jlen = jlen - kernel_size + 1;

	// Get number of pad to add
	const size_t pad_i = ilen - max_ilen;
	const size_t pad_j = jlen - max_jlen;

	// Get right and upper pad limits
	const size_t pad_i_start = pad_i >> 1; // same as / 2
	const size_t pad_j_start = pad_j >> 1; // same as / 2

	const size_t out_tlen = num_filters;
	size_t idx;

	// for each filter == for each output channel
	for(size_t t = 0; t < out_tlen; t++) {

		Mu_t* t_q_mu = mu_kernels_list[t];
		Sigma_t* t_q_sigma = sigma_kernels_list[t];
        Iop_t q_bias = (Iop_t) v_q_bias[t]; 

		// for each submatrix
		size_t i, j;
		for(i = 0; i < out_ilen; i++) {
			for(j = 0; j < out_jlen; j++) {
				
				Iop_t acc = 0;
				
				// for each element of 2D kernel and channels
				size_t ki, kj, tt;
				for(ki = 0; ki < kernel_size; ki++) {
					for(kj = 0; kj < kernel_size; kj++) {
						for(tt = 0; tt < tlen; tt++) {

							// Input index strides i,j
							size_t ii = i + ki;
							size_t jj = j + kj;

							// Check left pad element
							if ((ii < pad_i_start) || (jj < pad_j_start)) {
								// pad 0 then v = 0
								// If v == 0 then acc += 0, can ignore
								continue;
							}

							// Fix left pad offset
							ii -= pad_i_start;
							jj -= pad_j_start;

							// If out of original matrix is right padding
							if ((ii >= ilen) || (jj >= jlen)) {
								// Ignore
								continue;
							}

							// Sample weight
							idx = flat_idx_3d(ki, kj, tt, kernel_size, tlen);
							
                            Iop_t q_sigma = (Iop_t) t_q_sigma[idx];
							Iop_t q_mu = (Iop_t) t_q_mu[idx];
                            Iop_t u = generator(S);
                            Iop_t w = ((q_sigma * u) >> S) + q_mu;
                            
                            idx = flat_idx_3d(ii, jj, tt, jlen, tlen);
                            
                            Iop_t q_x = (Iop_t) t_q_input[idx];
                            acc += w * q_x;
						}
					}
				}

				Iop_t q_acc = acc >> S;
				Data_t q_o = (Data_t) (q_acc + q_bias);

				idx = flat_idx_3d(i, j, t, out_jlen, out_tlen);
				
                // ReLU
                t_q_output[idx] = ReLU(q_o);
			}
		}
	}
}
