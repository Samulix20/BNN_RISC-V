#include "../activations.h"
#include "../layers.h"

void __bnn_layer_ReLU(
	Sigma_t* m_q_sigma,
	Mu_t* m_q_mu,
	Bias_t* v_q_bias,
	Data_t* v_q_input,
	Data_t* v_q_ouput,
	Scale_t S,
	size_t ilen, 
	size_t jlen
) {
	for(size_t i = 0; i < ilen; i++) {

		Iop_t acc = 0;

		for(size_t j = 0; j < jlen; j++) {
			size_t m_idx = flat_idx_2d(i, j, jlen);
			Iop_t q_sigma = (Iop_t) m_q_sigma[m_idx];
			Iop_t q_mu = (Iop_t) m_q_mu[m_idx]; 
			Iop_t q_x = (Iop_t) v_q_input[j];
			Iop_t u = generator(S);
			Iop_t w = ((q_sigma * u) >> S) + q_mu;
			acc += w * q_x; 
		}

		Iop_t q_acc = acc >> S;
		Iop_t q_bias = (Iop_t) v_q_bias[i];
		Data_t q_o = (Data_t) (q_acc + q_bias);
		
		// ReLU
		v_q_ouput[i] = q_o < 0 ? 0 : q_o;
	}
}

#include <stdio.h>

#define SOFTMAX_LAYER_BUFLEN 20

void __bnn_layer_Softmax(
	Sigma_t* m_q_sigma,
	Mu_t* m_q_mu,
	Bias_t* v_q_bias,
	Data_t* v_q_input,
	Softmax_t* v_q_ouput,
	Scale_t S,
	size_t ilen, 
	size_t jlen
) {
	Iop_t max = 0;
	Iop_t tmp_o[ilen];

	for(size_t i = 0; i < ilen; i++) {

		Iop_t acc = 0;

		for(size_t j = 0; j < jlen; j++) {
			size_t m_idx = flat_idx_2d(i, j, jlen);
			Iop_t q_sigma = (Iop_t) m_q_sigma[m_idx];
			Iop_t q_mu = (Iop_t) m_q_mu[m_idx]; 
			Iop_t q_x = (Iop_t) v_q_input[j];
			Iop_t u = generator(S);
			Iop_t w = ((q_sigma * u) >> S) + q_mu;
			acc += w * q_x; 
		}

		Iop_t q_acc = acc >> S;
		Iop_t q_bias = (Iop_t) v_q_bias[i];
		Iop_t q_o = (Data_t) (q_acc + q_bias);
		
		// Find max
		if(q_o > max || i == 0) max = q_o;

		tmp_o[i] = q_o;
	}

	softmax(tmp_o, v_q_ouput, max, S, ilen);
}
