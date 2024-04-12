#ifndef BNN_LAYERS_H
#define BNN_LAYERS_H

#include "activations.h"

// Flat index utils

inline size_t flat_idx_2d (size_t i, size_t j, size_t jlen) {
    return (i * jlen + j);
}

inline size_t flat_idx_3d (  
	size_t i, size_t j, size_t t, 
    size_t jlen, size_t tlen
) {
    return (i * jlen * tlen + flat_idx_2d(j, t, tlen));
}

// Layer function wrappers
// TODO REMOVE WRAPPERS AND USE REAL FUNCTIONS

void __bnn_layer_conv2D_valid_ReLU (
	Data_t* t_q_input, 
    size_t ilen, size_t jlen, size_t tlen,
	size_t num_filters, size_t kernel_size,
	Mu_t** mu_kernels_list, 
    Sigma_t** sigma_kernels_list, 
    Bias_t* v_q_bias,
	Data_t* t_q_output,
    Scale_t S
);

void __bnn_layer_conv2D_same_ReLU (
    Data_t* t_q_input, 
    size_t ilen, size_t jlen, size_t tlen,
	size_t num_filters, size_t kernel_size,
	Mu_t** mu_kernels_list, 
    Sigma_t** sigma_kernels_list, 
    Bias_t* v_q_bias,
	Data_t* t_q_output,
    Scale_t S
);

void __bnn_layer_ReLU(
	Sigma_t* m_q_sigma,
	Mu_t* m_q_mu,
	Bias_t* v_q_bias,
	Data_t* v_q_input,
	Data_t* v_q_ouput,
	Scale_t S,
	size_t ilen, 
	size_t jlen
);

void __bnn_layer_Softmax(
	Sigma_t* m_q_sigma,
	Mu_t* m_q_mu,
	Bias_t* v_q_bias,
	Data_t* v_q_input,
	Softmax_t* v_q_ouput,
	Scale_t S,
	size_t ilen, 
	size_t jlen
);

void __layer_max_pooling2D(
	Data_t* input,
	size_t ilen, size_t jlen, size_t tlen,
	size_t stride_i, size_t stride_j,
	Data_t* output
);

inline void bnn_layer_ReLU(	
	Data_t* input, 
	Mu_t* meds, Sigma_t* vars, Bias_t* bias, 
	size_t num_out, size_t num_in,
	Data_t* output
) {
	__bnn_layer_ReLU(
		vars,
		meds,
		bias,
		input,
		output,
		BNN_SCALE_FACTOR,
		num_out,
		num_in
	);
}

inline void bnn_layer_softmax(
	Data_t* input, 
	Mu_t* meds, Sigma_t* vars, Bias_t* bias, 
	size_t num_out, size_t num_in,
	Softmax_t* output
) {
	__bnn_layer_Softmax(
		vars,
		meds,
		bias,
		input,
		output,
		BNN_SCALE_FACTOR,
		num_out,
		num_in
	);
}

inline void bnn_layer_conv2D_valid (
	Data_t* input, size_t ilen, size_t jlen, size_t tlen,
	size_t num_filters, size_t kernel_size,
	Mu_t** kernels_avg, Sigma_t** kernels_var, Bias_t* kernels_bias,
	Data_t* output
) {
	__bnn_layer_conv2D_valid_ReLU (
		input, ilen, jlen, tlen,
		num_filters, kernel_size,
		kernels_avg, kernels_var, kernels_bias,
		output, BNN_SCALE_FACTOR
	);
}

inline void bnn_layer_conv2D_same (
	Data_t* input, size_t ilen, size_t jlen, size_t tlen,
	size_t num_filters, size_t kernel_size,
	Mu_t** kernels_avg, Sigma_t** kernels_var, Bias_t* kernels_bias,
	Data_t* output
) {
	__bnn_layer_conv2D_same_ReLU (
		input, ilen, jlen, tlen,
		num_filters, kernel_size,
		kernels_avg, kernels_var, kernels_bias,
		output, BNN_SCALE_FACTOR
	);
}


inline void layer_max_pooling2D(
	Data_t* input,
	size_t ilen, size_t jlen, size_t tlen,
	size_t stride_i, size_t stride_j,
	Data_t* output
) {
	__layer_max_pooling2D(
		input, ilen, jlen, tlen,
		stride_i, stride_j, output
	);
}


#endif
