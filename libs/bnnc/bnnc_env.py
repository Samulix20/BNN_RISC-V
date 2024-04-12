import os
import tempfile
import copy

import pandas as pd
import numpy as np

from .bnnc_keras import bnn_keras_model_to_c, c_data_format

class BnncEnviroment():

    def _df_to_array(df):
        bgm = []
        mc_samples = df["mcpass"].max() + 1
        for i in range(mc_samples):
            bgm.append(df[(df["mcpass"] == i)].filter(regex="class").values)
        return np.array(bgm)

    def bash_exec(self, cmd):
        r = os.system(cmd)
        if r != 0:
            raise Exception(f'bash_exec: {cmd} error code {r}')

    def __init__(self):
        """
            Creates a temporary enviroment for BNN C inference execution
        """
        csrc_dir = f'{os.path.dirname(os.path.abspath(__file__))}/c_src/'
        self.tmp_dir = tempfile.TemporaryDirectory(prefix="c_bnn_env_")
        self.bash_exec(f"""
            cp -r {csrc_dir}/* {self.tmp_dir.name}/
        """)
        self.env_dir = self.tmp_dir.name
        self.c_bnn_dir = self.env_dir

        # Default values
        self.scale_bits = 8 # Scale is 2**8
        self.gen_type = 1 # Uniform Transform gen
        self.mc_passes = 100 # Montecarlo inference passes

    def gen_dataset_src(self, data, copy_dir=None):
        """
            Generates data C source files from a dataset

                Parameters:
                    data (Numpy Array): Test dataset
                    copy_dir (Directory Path) (optional): Path to copy the generated C files
        """

        # Dataset C code
        with open(f"{self.c_bnn_dir}/test_data.h", "w") as f:
            f.write(c_data_format(data, self.scale_bits))

        if copy_dir is not None:
            self.bash_exec(f"""
                cp -a {self.c_bnn_dir}/test_data.h {copy_dir}/
            """)

    def gen_model_src(self, model, copy_dir=None):
        """
            Generates model C source files from a trained keras model

                Parameters:
                    model (Tensorflow Keras model): Trained BNN model
                    copy_dir (Directory Path) (optional): Path to copy the generated C files
        """

        # Model C code
        c_weights, c_model, type_config = bnn_keras_model_to_c(model, self.scale_bits, self.gen_type, self.mc_passes)

        with open(f'{self.c_bnn_dir}/bnn_model_weights.h', 'w') as f:
            f.write(c_weights)
        with open(f'{self.c_bnn_dir}/bnn_model.h', 'w') as f:
            f.write(c_model)
        with open(f'{self.c_bnn_dir}/libs/bnn/config.h', 'w') as f:
            f.write(type_config)

        if copy_dir is not None:
            self.bash_exec(f"""
                cp -a {self.c_bnn_dir}/. {copy_dir}/
            """)

        return self

    def predict(self, quiet=True):
        """
            Runs C predictions of a previously generated C model and dataset

                Parameters:
                    quiet (bool): If true silences realtime prediction outputs to console

                Returns:
                    Predictions results as a Numpy Array 
                        Shape 3D (Monte Carlo Samples, Number of Test Data, Number of Classes)
        """

        redir = "> /dev/null" if quiet else ""
        self.bash_exec(f"""
            cd {self.env_dir}
            make {redir}
        """)

        return BnncEnviroment._df_to_array(pd.read_csv(f'{self.c_bnn_dir}/run.log'))

    def clean(self):
        self.bash_exec(f"""
            cd "{self.env_dir}/programs"
            make clean
        """)
