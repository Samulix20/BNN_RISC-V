import numpy as np
import tensorflow as tf
import tensorflow_probability as tfp
tfd = tfp.distributions

class Mnist_dataset():

    class MNISTSequence(tf.keras.utils.Sequence):

        def __preprocessing(self, images, labels):
            images = 2 * (images / 255.) - 1.
            images = images[..., tf.newaxis]

            labels = tf.keras.utils.to_categorical(labels)
            return images, labels

        def __init__(self, data, batch_size=128):
            images, labels = data
            self.images, self.labels = self.__preprocessing(images, labels)
            self.batch_size = batch_size

        def __len__(self):
            return int(tf.math.ceil(len(self.images) / self.batch_size))

        def __getitem__(self, idx):
            batch_x = self.images[idx * self.batch_size: (idx + 1) * self.batch_size]
            batch_y = self.labels[idx * self.batch_size:(idx + 1) * self.batch_size]
            return batch_x, batch_y

    def __init__(self, batch_size=128, pad=False):
        train_set, heldout_set = tf.keras.datasets.mnist.load_data()

        if pad:
            # pad to 32x32
            train_set_pad = (
                np.pad(train_set[0], ((0,0), (2,2), (2,2)), 'constant', constant_values=(0,0)),
                train_set[1]
            )
            heldout_set_pad = (
                np.pad(heldout_set[0], ((0,0), (2,2), (2,2)), 'constant', constant_values=(0,0)),
                heldout_set[1]
            )
        else:
            train_set_pad = train_set
            heldout_set_pad = heldout_set

        self.train_seq = self.MNISTSequence(data=train_set_pad, batch_size=batch_size)
        self.test_seq = self.MNISTSequence(data=heldout_set_pad, batch_size=batch_size)

    def train(self, kmodel, num_epochs=10):
        for epoch in range(num_epochs):
            epoch_accuracy, epoch_loss = [], []
            for step, (batch_x, batch_y) in enumerate(self.train_seq):
                batch_loss, batch_accuracy = kmodel.train_on_batch(batch_x, batch_y)
                epoch_accuracy.append(batch_accuracy)
                epoch_loss.append(batch_loss)
                if step % 100 == 0:
                    print(f'Epoch: {epoch}, Batch index: {step}, Loss: {tf.reduce_mean(epoch_loss):.3f}, Accuracy: {tf.reduce_mean(epoch_accuracy):.3f}')

    def get_test_labels(self, num_img=500):
        return np.array([l.argmax() for l in self.test_seq.labels[:num_img]])

    def get_test_data(self, num_img=500):
        return self.test_seq.images[:num_img,:,:,0]

    def flatten_data(self, data):
        d1, d2, d3 = data.shape
        return data.reshape(d1, d2 * d3)

    def train_len(self):
        return len(self.train_seq)
