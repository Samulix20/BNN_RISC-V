import os
import tensorflow as tf
import numpy as np

repo_base_dir = os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)
)))

results_base_dir = f'{repo_base_dir}/tmp/'


def gen_type_val_to_name(val):
    return ["CLT", "Uniform"][val]


def gen_type_name_to_val(name):
    return {"CLT": 0, "Uniform": 1}[name]


def create_figure_directory(gen_str, model_name):
    d = f'{results_base_dir}/Figures/{gen_str}/{model_name}'
    os.makedirs(d, exist_ok=True)
    return d


def save_predictions(mname, gen_type_name, fname, predictions):
    dirname = f'{results_base_dir}/Predictions/{gen_type_name}/{mname}/'
    filename = f'{dirname}/{fname}'
    os.makedirs(dirname, exist_ok=True)
    np.savez(filename, predictions)


def load_predictions(mname, gen_type_name, fname):
    dirname = f'{results_base_dir}/Predictions/{gen_type_name}/{mname}/'
    filename = f'{dirname}/{fname}'
    return np.load(filename)['arr_0']


def bayesian_python_predictions(kmodel, data_x, samples=100):
    predictions = []
    for _ in range(samples):
        predictions.append(kmodel.predict(data_x, verbose=0))
    return tf.stack(predictions, axis=0)


def load_keras_model(model_arch, dataset_name):
    mdir = f'{results_base_dir}/Models/{model_arch}/{dataset_name}/keras_model'
    return tf.keras.models.load_model(mdir)


def save_keras_model(kmodel, model_arch, dataset_name):
    mdir = f'{results_base_dir}/Models/{model_arch}/{dataset_name}/keras_model'
    os.makedirs(mdir, exist_ok=True)
    kmodel.save(mdir)


def model_str(model_arch, dataset_name):
    return f'{model_arch}_{dataset_name}'


from cifar10_dataset import Cifar10_dataset
from mnist_dataset import Mnist_dataset


def load_dataset(model_arch, dataset_name):
    if dataset_name == "CIFAR":
        return Cifar10_dataset()
    if dataset_name == "MNIST":
        return Mnist_dataset(pad = model_arch == "B2N2")

    return None
