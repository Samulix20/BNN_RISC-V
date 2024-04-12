import os
import sys

# Reduce TF logs
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
import tensorflow as tf

# set base dir to repository root
repo_base_dir = os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)
))

# add paths
sys.path.append(f'{repo_base_dir}/ext/')
sys.path.append(f'{repo_base_dir}/libs/')
sys.path.append(f'{repo_base_dir}/test/lib/')

# Set path to BNN ext module to use same config
os.chdir(f'{repo_base_dir}/ext/BNN_for_hyperspectral_datasets_analysis')

from BNN_for_hyperspectral_datasets_analysis.lib import config
from BNN_for_hyperspectral_datasets_analysis.lib.data import get_dataset
from BNN_for_hyperspectral_datasets_analysis.lib.analysis import (
    bayesian_predictions
)


class hyperspectral_bnn_models():

    model_list = ["BO", "IP", "KSC", "PU", "SV"]

    def __init__(self):
        self.epochs = {
            "BO": 17000,
            "IP": 22000,
            "KSC": 41000,
            "PU": 1800,
            "SV": 4000
        }

    def get_model(self, name):
        # Config params
        base_dir = config.MODELS_DIR
        p_train = config.P_TRAIN
        learning_rate = config.LEARNING_RATE
        l1_n = config.LAYER1_NEURONS
        l2_n = config.LAYER2_NEURONS

        model_dir = (
            f"{name}_{l1_n}-{l2_n}model_{p_train}train_{learning_rate}lr"
        )
        model_dir = os.path.join(model_dir, f"epoch_{self.epochs[name]}")
        model_dir = os.path.join(base_dir, model_dir)

        return tf.keras.models.load_model(model_dir)

    def get_test_data(self, name):
        d_path = config.DATA_PATH
        p_train = config.P_TRAIN
        dataset = config.DATASETS[name]
        _, _, X_test, y_test = get_dataset(dataset, d_path, p_train)
        return (X_test, y_test)

    def predict(self, name, samples=100):
        model = self.get_model(name)
        X_test, _ = self.get_test_data(name)
        return bayesian_predictions(model, X_test, samples=samples)


import test_tools as test
from bnnc.bnnc_env import BnncEnviroment
from bnnc.bnnc_predictions import analyze_predictions, match_ratio, compare_predictions_plots


def hyperspectral_python_predictions(model_name, gen_type_name):
    _, labels = hyperspectral_bnn_models().get_test_data(model_name)
    predictions = hyperspectral_bnn_models().predict(model_name, 100)
    test.save_predictions(
        model_name, gen_type_name, 'py_predictions', predictions
    )
    acc, metrics, averages = analyze_predictions(predictions, labels)
    return acc, (metrics, averages), labels


def hyperspectral_c_predictions(model_name, gen_type):
    model = hyperspectral_bnn_models().get_model(model_name)
    test_data, labels = hyperspectral_bnn_models().get_test_data(model_name)
    c_env = BnncEnviroment()
    c_env.gen_type = gen_type
    c_env.gen_model_src(model)
    c_env.gen_dataset_src(test_data)
    predictions = c_env.predict()
    gen_type_name = test.gen_type_val_to_name(gen_type)
    test.save_predictions(
        model_name, gen_type_name, 'c_predictions', predictions
    )
    acc, metrics, averages = analyze_predictions(predictions, labels)
    return acc, (metrics, averages), labels


def compare_predictions(model_name, gen_type_name, prev_py=None):
    figdir = test.create_figure_directory(gen_type_name, model_name)
    gen_type = test.gen_type_name_to_val(gen_type_name)

    if prev_py is None:
        py_acc, py_data, _ = hyperspectral_python_predictions(
            model_name, gen_type_name
        )
    else:
        py_acc, py_data, _ = prev_py

    c_acc, c_data, labels = hyperspectral_c_predictions(model_name, gen_type)
    print('py_acc c_acc match_ratio', gen_type_name, model_name)
    print(py_acc, c_acc, match_ratio(c_data[0], py_data[0]))
    print()
    compare_predictions_plots(c_data, py_data, labels, figdir)

    return (py_acc, py_data, labels)


def main():
    for model in hyperspectral_bnn_models.model_list:
        pyd = compare_predictions(model, "CLT")
        compare_predictions(model, "Uniform", prev_py=pyd)


if __name__ == '__main__':
    main()
