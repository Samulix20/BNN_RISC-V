import tensorflow as tf
import tensorflow_probability as tfp
tfd = tfp.distributions

def create_b2n2_model(num_train, num_classes, learning_rate=0.001):
    # Do not store self references in model cause that crashes the program
    num_train_examples = num_train
    num_train_classes = num_classes
    kl_divergence_function = (
        lambda q, p, _: tfd.kl_divergence(q, p) / tf.cast(num_train_examples, dtype=tf.float32)
    )
    model = tf.keras.models.Sequential([
        tfp.layers.Convolution2DFlipout(
            32, kernel_size=3, padding='SAME',
            kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.relu),
        tfp.layers.Convolution2DFlipout(
            32, kernel_size=3, padding='SAME',
            kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.relu),
        tf.keras.layers.MaxPooling2D(
            pool_size=[2, 2], strides=[2, 2],
            padding='VALID'),
        tfp.layers.Convolution2DFlipout(
            64, kernel_size=3, padding='SAME',
            kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.relu),
        tfp.layers.Convolution2DFlipout(
            64, kernel_size=3, padding='SAME',
            kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.relu),
        tf.keras.layers.MaxPooling2D(
            pool_size=[2, 2], strides=[2, 2],
            padding='VALID'),
        tfp.layers.Convolution2DFlipout(
            128, kernel_size=3, padding='SAME',
            kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.relu),
        tfp.layers.Convolution2DFlipout(
            128, kernel_size=3, padding='SAME',
            kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.relu),
        tf.keras.layers.MaxPooling2D(
            pool_size=[2, 2], strides=[2, 2],
            padding='VALID'),
        tf.keras.layers.Flatten(),
        tfp.layers.DenseFlipout(
            num_train_classes,
            kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.softmax)
    ])
    optimizer = tf.keras.optimizers.Adam(learning_rate=learning_rate)
    model.compile(
        optimizer,
        loss='categorical_crossentropy',
        metrics=['accuracy'],
        experimental_run_tf_function=False
    )
    return model

def create_lenet5_model(num_train, num_classes, learning_rate=0.001):
    num_train_examples = num_train
    num_train_classes = num_classes
    kl_divergence_function = (
        lambda q, p, _: tfd.kl_divergence(q, p) / tf.cast(num_train_examples, dtype=tf.float32)
    )
    model = tf.keras.models.Sequential([
        tfp.layers.Convolution2DFlipout(
            6, kernel_size=5, padding='VALID',
            kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.relu),
        tf.keras.layers.MaxPooling2D(
            pool_size=[2, 2], strides=[2, 2],
            padding='VALID'),
        tfp.layers.Convolution2DFlipout(
            16, kernel_size=5, padding='VALID',
            kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.relu),
        tf.keras.layers.MaxPooling2D(
            pool_size=[2, 2], strides=[2, 2],
            padding='VALID'),
        tfp.layers.Convolution2DFlipout(
            120, kernel_size=4, padding='VALID',
            kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.relu),
        tf.keras.layers.Flatten(),
        tfp.layers.DenseFlipout(
            84, kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.relu),
        tfp.layers.DenseFlipout(
            num_train_classes,
            kernel_divergence_fn=kl_divergence_function,
            activation=tf.nn.softmax)
    ])
    optimizer = tf.keras.optimizers.Adam(learning_rate=learning_rate)
    model.compile(
        optimizer,
        loss='categorical_crossentropy',
        metrics=['accuracy'],
        experimental_run_tf_function=False
    )
    return model
