import os
import sys

from multiprocessing import Pool

# Reduce TF logs
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

import numpy as np

# MAKE SCRIPT INDEPENDENT OF WORKDIR

# set base dir to repository root
repo_base_dir = os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)
))

results_base_dir = f'{repo_base_dir}/tmp/'

# add paths
sys.path.append(f'{repo_base_dir}/ext/')
sys.path.append(f'{repo_base_dir}/libs/')
sys.path.append(f'{repo_base_dir}/test/lib/')

from bnnc.bnnc_env import BnncEnviroment
from bnnc.bnnc_predictions import (
    analyze_predictions, match_ratio, compare_predictions_plots
)
import test_tools as tools


def parallel_cpred(work_data):
    model_arch, dataset_name, data, gen_type = work_data
    kmodel = tools.load_keras_model(model_arch, dataset_name)
    bnnc_env = BnncEnviroment()
    bnnc_env.gen_type = gen_type
    bnnc_env.gen_model_src(kmodel)
    bnnc_env.gen_dataset_src(data)
    return bnnc_env.predict()


def parallel_cpred_handler(
    dts, model_arch, dataset_name, gen_type_name, num_img, num_workers
):
    data_x = dts.get_test_data(num_img)
    labels = dts.get_test_labels(num_img)
    gen_type = tools.gen_type_name_to_val(gen_type_name)
    worker_pool = Pool(num_workers)
    results = worker_pool.map(
        parallel_cpred,
        [
            (model_arch, dataset_name, dts.flatten_data(d), gen_type)
            for d in np.split(data_x, num_workers)
        ]
    )
    predictions = np.concatenate(results, axis=1)
    mstr = tools.model_str(model_arch, dataset_name)
    tools.save_predictions(mstr, gen_type_name, 'c_predictions', predictions)
    acc, metrics, averages = analyze_predictions(predictions, labels)
    return acc, (metrics, averages), labels


def model_pypreds(model_arch, dataset_name, gen_type_name, num_img):
    dts = tools.load_dataset(model_arch, dataset_name)
    labels = dts.get_test_labels(num_img)
    kmodel = tools.load_keras_model(model_arch, dataset_name)
    predictions = tools.bayesian_python_predictions(
        kmodel,
        dts.get_test_data(num_img)
    )
    mstr = tools.model_str(model_arch, dataset_name)
    tools.save_predictions(mstr, gen_type_name, 'py_predictions', predictions)
    acc, metrics, averages = analyze_predictions(predictions, labels)
    return acc, (metrics, averages), labels


def eval_model(model_arch, gen_type_name, dataset_name, num_img, num_threads):
    c_acc, c_data, labels = parallel_cpred_handler(
        tools.load_dataset(model_arch, dataset_name),
        model_arch, dataset_name, gen_type_name, num_img, num_threads
    )
    py_acc, py_data, _ = model_pypreds(
        model_arch, dataset_name, gen_type_name, num_img
    )
    mstr = tools.model_str(model_arch, dataset_name)
    print(f'py_acc c_acc match_ratio {mstr}')
    print(py_acc, c_acc, match_ratio(c_data[0], py_data[0]))
    print()
    d = tools.create_figure_directory(gen_type_name, mstr)
    compare_predictions_plots(c_data, py_data, labels, d)


def main():
    num_img = 10000
    num_threads = 20

    eval_model("LENET", "CLT", "MNIST", num_img, num_threads)
    eval_model("LENET", "Uniform", "MNIST", num_img, num_threads)
    eval_model("LENET", "CLT", "CIFAR", num_img, num_threads)
    eval_model("LENET", "Uniform", "CIFAR", num_img, num_threads)

    eval_model("B2N2", "CLT", "MNIST", num_img, num_threads)
    eval_model("B2N2", "Uniform", "MNIST", num_img, num_threads)
    eval_model("B2N2", "CLT", "CIFAR", num_img, num_threads)
    eval_model("B2N2", "Uniform", "CIFAR", num_img, num_threads)


# MAIN
if __name__ == '__main__':
    main()
