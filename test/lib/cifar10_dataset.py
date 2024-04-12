import numpy as np
import tensorflow as tf
import tensorflow_probability as tfp
tfd = tfp.distributions

class Cifar10_dataset():

    def __preprocess_dataset(self, dataset):
        images, labels = dataset
        images = 2 * (images / 255.0) - 1 # to float -1.0, 1.0 range
        labels = tf.keras.utils.to_categorical(labels)
        return images, labels

    def __get_dataset(self):
        raw_train_set, raw_test_set = tf.keras.datasets.cifar10.load_data()
        self.train_set = self.__preprocess_dataset(raw_train_set)
        self.test_set = self.__preprocess_dataset(raw_test_set)

    def __init__(self):
        # CIFAR 10 dataset
        self.num_classes = 10
        self.__get_dataset()
        # Format [n, (x * y * z tensor)][labels]
        self.num_train = np.shape(self.train_set[0])[0]

    def train(self, kmodel, num_epochs=30):
        batch_size = 128
        images, labels = self.train_set
        num_batches = int(tf.math.ceil((len(images) / batch_size)))

        for epoch in range(num_epochs):
            epoch_acc, epoch_loss = [], []

            for step in range(num_batches):
                batch_x = images[step * batch_size: (step + 1) * batch_size]
                batch_y = labels[step * batch_size: (step + 1) * batch_size]
                batch_loss, batch_acc = kmodel.train_on_batch(batch_x, batch_y)
                epoch_acc.append(batch_acc)
                epoch_loss.append(batch_loss)
                # Info log
                if step % 100 == 0:
                    print(f'Epoch: {epoch}, Batch index: {step}, Loss: {tf.reduce_mean(epoch_loss):.3f}, Accuracy: {tf.reduce_mean(epoch_acc):.3f}')

    def get_test_labels(self, num_img=500):
        return np.array([l.argmax() for l in self.test_set[1][:num_img]])

    def get_test_data(self, num_img=500):
        return self.test_set[0][:num_img, ...]

    def flatten_data(self, data):
        d1, d2, d3, d4 = data.shape
        return data.reshape(d1, d2 * d3 * d4)

    def train_len(self):
        return len(self.test_set)
