import sys
import os

# Reduce TF logs
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

# set base dir to repository root
repo_base_dir = os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)
))

# add paths
sys.path.append(f'{repo_base_dir}/ext/')
sys.path.append(f'{repo_base_dir}/libs/')
sys.path.append(f'{repo_base_dir}/test/lib/')

from model_archs import create_b2n2_model, create_lenet5_model
import test_tools as test

def create_model(arch, num_train):
    if arch == "B2N2":
        return create_b2n2_model(num_train, 10)
    if arch == "LENET":
        return create_lenet5_model(num_train, 10)

    return None

def train_model(arch, dataset_name, num_epochs):
    dts = test.load_dataset(arch, dataset_name)
    model = create_model(arch, dts.train_len())
    dts.train(model, num_epochs=num_epochs)
    test.save_keras_model(model, arch, dataset_name)

def main():
    train_model("LENET", "MNIST", 10)
    train_model("LENET", "CIFAR", 30)
    train_model("B2N2", "MNIST", 10)
    train_model("B2N2", "CIFAR", 30)

# MAIN
if __name__ == '__main__':
    main()
