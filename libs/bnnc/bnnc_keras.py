import numpy as np
import tensorflow as tf
import sys
from math import log2, ceil, sqrt

# Returns C code string from array
def c_array_format(array, name, fbits, data_type):
    tofixed = 2**fbits

    if len(array.shape) >= 3:
        text = f'// Array {len(array.shape)}D {array.shape}\n'

        if(np.prod(array.shape) > (2**32-1)):
            print("ERROR, array too big!")

        text += f'{data_type} {name}[{np.prod(array.shape)}] = ' + '{'
        f = array.flatten()
        for v in f:
            text += f'{int(v * tofixed) + 0}, '
        text = text[:-2]
        text += '};\n'

    elif len(array.shape) == 2:

        lsize = array.shape[1]

        text = f'// Matrix {array.shape[0]} x {lsize}\n'
        text += f'{data_type} {name}[{array.shape[0] * lsize}] = ' + '{'

        for row in array:
            for w in row:
                text += f'{int(w * tofixed) + 0}, '
            text += '\n'
        text = text[:-3]
        text += '};\n'

    else:
        text = f'// Array {array.shape[0]}\n'
        text += f'{data_type} {name}[{array.shape[0]}] = ' + '{'

        for w in array:
            text += f'{int(w * tofixed) + 0}, '
        text = text[:-2]
        text += '};\n'

    return text

def uniform_transform(averages, variances):
    t_var = variances * sqrt(12.0)
    t_avg = averages - 0.5 * t_var
    return t_avg, t_var

def process_layer_averages_variances(layer, gen_type):
    weights = layer.get_weights()
    averages = weights[0].T
    variances = np.array(tf.nn.softplus(weights[1])).T

    # normal/gaussian generation
    if gen_type == 0 or gen_type == 2:
        t_avg = averages
        t_var = variances
    
    # uniform generation
    elif gen_type == 1:
        t_avg, t_var = uniform_transform(averages, variances)

    else:
        raise Exception(f"Unknown gen type {gen_type}")

    return t_avg, t_var

# Returns C code from a data matrix [NUM_DATAxFEATURES_PER_DATA]
def c_data_format(data, fbits):
    c_code = "#ifndef BNN_DATA_H\n#define BNN_DATA_H\n\n"
    c_code += "// Include types from bnn library\n#include <bnn/types.h>\n\n"
    c_code += f'#define NUM_DATA {data.shape[0]}\n'
    c_code += f'#define FEATURES_PER_DATA {data.shape[1]}\n'
    c_code += c_array_format(data, 'data_matrix', fbits, 'Data_t')
    c_code += "\n#endif\n"
    return c_code

# LAYER FORMATING

template_DenseFlipout_format = """
// LAYER {layername} //
const size_t {layername}_num_in = {num_inputs};
const size_t {layername}_num_out = {num_outputs};

const size_t {layername}_output_size = {num_outputs};
Data_t {layername}_out[{num_outputs}];

"""

template_DenseFlipout_fcall = """
{t}bnn_layer_{f_act} (
{t}{t}{input},
{t}{t}{layername}_avg, {layername}_var, {layername}_bias,
{t}{t}{layername}_num_out, {layername}_num_in,
{t}{t}{layername}_out
{t});
"""

def DenseFlipout_cformat(layer, fbits, gen_type):
    weights = layer.get_weights()
    num_inputs, num_outputs = weights[0].shape

    c_code = template_DenseFlipout_format.format(
        layername = layer.name,
        num_inputs = num_inputs,
        num_outputs = num_outputs,
    )

    t_avg, t_var = process_layer_averages_variances(layer, gen_type)

    # Average
    c_code += c_array_format(t_avg, f'{layer.name}_avg', fbits, 'Mu_t') + '\n'
    # Variance
    c_code += c_array_format(t_var, f'{layer.name}_var', fbits, 'Sigma_t') + '\n'
    # Bias
    c_code += c_array_format(weights[2], f'{layer.name}_bias', fbits, 'Bias_t') + '\n'

    return c_code

template_Conv2DFlipout_format = """
// LAYER {layername} //
const size_t {layername}_in_ilen = {in_ilen};
const size_t {layername}_in_jlen = {in_jlen};
const size_t {layername}_in_tlen = {in_tlen};

const size_t {layername}_out_ilen = {out_ilen};
const size_t {layername}_out_jlen = {out_jlen};
const size_t {layername}_out_tlen = {num_filters};

const size_t {layername}_num_filters = {num_filters};
const size_t {layername}_kernel_size = {kernel_size};

Data_t {layername}_out[{num_outputs}];

"""

template_Conv2DFlipout_fcall = """
{t}bnn_layer_conv2D_{padding} (
{t}{t}{input},
{t}{t}{layername}_in_ilen, {layername}_in_jlen, {layername}_in_tlen,
{t}{t}{layername}_num_filters, {layername}_kernel_size,
{t}{t}{layername}_kernels_avg, {layername}_kernels_var, {layername}_bias,
{t}{t}{layername}_out
{t});
"""

def Conv2DFlipout_cformat(layer, fbits):
    weights = layer.get_weights()
    
    # Kernel Dimensions
    kernel_size = weights[0].shape[0]
    in_tlen = weights[0].shape[2]

    # Num Filters
    num_filters = weights[0].shape[3]

    # Input/Ouput Shape
    _, out_ilen, out_jlen, _ = layer.output_shape
    padding_type = layer.get_config()['padding']
    if padding_type == 'valid':
        in_ilen = out_ilen + kernel_size - 1
        in_jlen = out_jlen + kernel_size - 1
    elif padding_type == 'same':
        in_ilen = out_ilen
        in_jlen = out_jlen

    avg_txt = ""
    var_txt = ""

    c_code = template_Conv2DFlipout_format.format(
        layername = layer.name,
        in_ilen = in_ilen,
        in_jlen = in_jlen,
        in_tlen = in_tlen,
        out_ilen = out_ilen,
        out_jlen = out_jlen,
        num_filters = num_filters,
        kernel_size = kernel_size,
        num_outputs = out_ilen * out_jlen * num_filters
    )

    for f in range(num_filters):
        c_code += c_array_format(weights[0][:,:,:,f], f'{layer.name}_f{f}_avg', fbits, 'Mu_t') + '\n'
        avg_txt += f'{layer.name}_f{f}_avg, '
        c_code += c_array_format(np.array(tf.nn.softplus(weights[1][:,:,:,f])), f'{layer.name}_f{f}_var', fbits, 'Sigma_t') + '\n'
        var_txt += f'{layer.name}_f{f}_var, '

    c_code += c_array_format(weights[2], f'{layer.name}_bias', fbits, 'Bias_t') + '\n'

    c_code += f'Mu_t* {layer.name}_kernels_avg[{num_filters}] = ' + '{' + f'{avg_txt[:-2]}' + '};\n\n'
    c_code += f'Sigma_t* {layer.name}_kernels_var[{num_filters}] = ' + '{' + f'{var_txt[:-2]}' + '};\n\n'

    return c_code

template_Conv2D_format = """
// LAYER {layername} //
const size_t {layername}_in_ilen = {in_ilen};
const size_t {layername}_in_jlen = {in_jlen};
const size_t {layername}_in_tlen = {in_tlen};

const size_t {layername}_out_ilen = {out_ilen};
const size_t {layername}_out_jlen = {out_jlen};
const size_t {layername}_out_tlen = {num_filters};

const size_t {layername}_num_filters = {num_filters};
const size_t {layername}_kernel_size = {kernel_size};

Data_t {layername}_out[{num_outputs}];

"""

template_Conv2D_fcall = """
{t}layer_conv2D (
{t}{t}{input},
{t}{t}{layername}_in_ilen, {layername}_in_jlen, {layername}_in_tlen,
{t}{t}{layername}_num_filters, {layername}_kernel_size,
{t}{t}{layername}_kernels_avg, {layername}_bias,
{t}{t}{layername}_out
{t});
"""

template_MaxPooling2D_format = """
// LAYER {layername} //
const size_t {layername}_in_ilen = {in_ilen};
const size_t {layername}_in_jlen = {in_jlen};
const size_t {layername}_in_tlen = {out_tlen};

const size_t {layername}_out_ilen = {out_ilen};
const size_t {layername}_out_jlen = {out_jlen};
const size_t {layername}_out_tlen = {out_tlen};

const size_t {layername}_stride_i = {stride_i};
const size_t {layername}_stride_j = {stride_j};

Data_t {layername}_out[{num_outputs}];

"""

template_MaxPooling2D_fcall = """
{t}layer_max_pooling2D (
{t}{t}{input},
{t}{t}{layername}_in_ilen, {layername}_in_jlen, {layername}_in_tlen,
{t}{t}{layername}_stride_i, {layername}_stride_j,
{t}{t}{layername}_out
{t});
"""

def MaxPooling2D_cformat(layer, fbits):
    c_code = ""
    stride_i, stride_j = layer.get_config()["strides"]

    # Input/Ouput Shape
    _, out_ilen, out_jlen, out_tlen = layer.output_shape
    in_ilen = out_ilen * stride_i
    in_jlen = out_jlen * stride_j

    c_code += template_MaxPooling2D_format.format(
        layername = layer.name,
        in_ilen = in_ilen,
        in_jlen = in_jlen,
        out_tlen = out_tlen,
        out_ilen = out_ilen,
        out_jlen = out_jlen,
        stride_i = stride_i,
        stride_j = stride_j,
        num_outputs = out_ilen * out_jlen * out_tlen,
    )

    return c_code

##############################################

bnn_c_weights_template = """
#ifndef MODEL_DATA_{modelname}_H
#define MODEL_DATA_{modelname}_H

// Include bnn library
#include <bnn/layers.h>
{modelcode}
#endif 
"""

bnn_c_model_template = """
#ifndef MODEL_{modelname}_H
#define MODEL_{modelname}_H

#include "bnn_model_weights.h"

Softmax_t* {modelname}_output = {prev_layername}_out;
size_t num_classes = {num_classes};

void {modelname}_inference (Data_t* {modelname}_input) {{
{modelfcall}
}}

#endif
"""

config_h_template="""
#ifndef BNN_CONFIG_H
#define BNN_CONFIG_H

#define BNN_SIGMA_DT {sigma_t}
#define BNN_MU_DT {mu_t}
#define BNN_BIAS_DT {bias_t}
#define BNN_DATA_DT int32
#define BNN_SCALE_FACTOR {scale_bits}

#define BNN_INTERNAL_GEN {gen_type}

#define BNN_MC_PASSES {mc_passes}

#endif
"""

def select_data_type(bw, signed):
    u = 'u' if not signed else ''
    if bw > 16:
        return f'{u}int32'
    elif bw > 8:
        return f'{u}int16'
    else:
        return f'{u}int8'

def data_range_to_data_type(dr, scale_bits):
    s_dr = (dr * 2**scale_bits).astype(int)
    signed = s_dr[0] < 0
    s_bw = ceil(log2(np.max(np.abs(s_dr))))
    s_bw += 1 if signed else 0
    dt = select_data_type(s_bw, signed)
    return dt

def analyze_model(model, scale_bits, gen_type):
    
    mu_t_range = np.array([sys.float_info.max, sys.float_info.min])
    sigma_t_range = np.array([sys.float_info.max, sys.float_info.min])
    bias_t_range = np.array([sys.float_info.max, sys.float_info.min])

    for l in model.layers:
        wl = l.get_weights()

        try:
            t_avg, t_var = process_layer_averages_variances(l, gen_type)
        except:
            continue

        for i in range(3):
            if i == 0:
                mu_t_range[0] = min(mu_t_range[0], np.min(t_avg))
                mu_t_range[1] = max(mu_t_range[1], np.max(t_avg))
            elif i == 1:
                sigma_t_range[0] = min(sigma_t_range[0], np.min(t_var))
                sigma_t_range[1] = max(sigma_t_range[1], np.max(t_var))
            else:
                bias_t_range[0] = min(bias_t_range[0], np.min(wl[i]))
                bias_t_range[1] = max(bias_t_range[1], np.max(wl[i]))


    mu_t = data_range_to_data_type(mu_t_range, scale_bits)
    sigma_t = data_range_to_data_type(sigma_t_range, scale_bits)
    bias_t = data_range_to_data_type(bias_t_range, scale_bits)

    scope = locals()
    create_dict = lambda *args: {i:eval(i, scope) for i in args}
    return create_dict('sigma_t', 'bias_t', 'mu_t')

def bnn_keras_model_to_c(model, fbits, gen_type, mc_passes):

    c_code = ""
    model_func = ""
    defined_input = False

    type_config = config_h_template.format(
        **analyze_model(model, fbits, gen_type),
        scale_bits=fbits,
        gen_type=gen_type,
        mc_passes=mc_passes
    )

    for i in range(len(model.layers)):
        layer = model.layers[i]

        # Model has defined input layer
        if layer.__class__.__name__ == "InputLayer":
            defined_input = True
            continue

        if i == 0 or defined_input:
            input_array = f"{model.name}_input"
            defined_input = False
        else:
            input_array = f"{prev_layername}_out"

        if layer.__class__.__name__ == "DenseFlipout":
            c_code += DenseFlipout_cformat(layer, fbits, gen_type)
            f_act = "ReLU" if layer.get_config()["activation"] == "relu" else "softmax"
            model_func += template_DenseFlipout_fcall.format(
                t = "\t",
                f_act = f_act,
                layername = layer.name,
                input = input_array
            )
        
        elif layer.__class__.__name__ == "Conv2DFlipout":
            c_code += Conv2DFlipout_cformat(layer, fbits)
            model_func += template_Conv2DFlipout_fcall.format(
                t = "\t",
                input = input_array,
                layername = layer.name,
                padding = layer.get_config()['padding']
            )

        elif layer.__class__.__name__ == "MaxPooling2D":
            c_code += MaxPooling2D_cformat(layer, fbits)
            model_func += template_MaxPooling2D_fcall.format(
                t = "\t",
                input = input_array,
                layername = layer.name
            )

        elif layer.__class__.__name__ == "Flatten":
            continue

        else:
            raise Exception(f'Unknown layer type {layer.__class__.__name__}')

        prev_layername = layer.name

    num_classes = model.layers[-1].output_shape[1]

    # Buffers and model weights
    c_weights = bnn_c_weights_template.format(
        modelname = model.name,
        modelcode = c_code
    )
    
    # Code and final model pointers
    c_model = bnn_c_model_template.format(
        modelname = model.name,
        prev_layername = prev_layername,
        num_classes = num_classes,
        modelfcall = model_func
    )

    return c_weights, c_model, type_config
