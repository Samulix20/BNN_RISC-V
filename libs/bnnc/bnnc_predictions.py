import sys

from math import log

import numpy as np
import matplotlib.pyplot as pl

def calc_accuracy(metrics):
    """
        Calculates prediction accuracy from its metrics

        Parameters:
            metrics (Numpy Array): Metrics Array
                Shape 2D (Numer of Predictions, 4)
                    0: Correct?
                    1: Class Predicted
                    2: H
                    3: Ep
        
        Returns:
            accuracy (Float): Predictions accuracy
    """
    return np.sum(metrics[:,0]) / metrics.shape[0]

def analyze_predictions(preds, labels):
    """
        Calculates acuracy of the predictions samples average and its related uncertainty metrics

            Parameters:
                preds (Numpy Array): Predictions array 
                    Shape 3D (Samples per prediction, Number of Predictions, Number of Classes)
                
                labels (Numpy Array): Test data labels for the predictions
                    Shape 1D (Number of Predictions)

            Returns:
                accuracy (Float): Predictions accuracy
                
                averages (Numpy Array): Prediction samples average
                    Shape 2D (Number of Predictions, Number of Classes)
                
                metrics (Numpy Array): Prediction related metrics
                    Shape 2D (Numer of Predictions, 4)
                        0: Correct?
                        1: Class Predicted
                        2: H
                        3: Ep
    """

    num_samples, num_predictions, _ = preds.shape

    metrics = []
    averages = []

    for pnum in range(num_predictions):
        dpred = preds[:,pnum,:]

        # Avoid log(0), NAN safe data
        p = np.array(
            [[sys.float_info.min if x < sys.float_info.min else x for x in dpred[i,:]] for i in range(num_samples)]
        )

        avg = np.mean(p, axis=0)
        cp = avg.argmax()

        # Global uncertainty (H) -- Predictive entropy
        h = -np.sum(avg * np.log(avg))

        # Expected entropy (Ep)
        ep = np.mean(-np.sum(p * np.log(p), axis=1))

        # correct, class predicted, H, Ep
        metrics.append([1 if cp == labels[pnum] else 0, cp, h, ep])
        averages.append(avg.tolist())

    metrics = np.array(metrics)
    averages = np.array(averages)

    return calc_accuracy(metrics), metrics, averages

def match_ratio(metrics_c, metrics_py):
    """
        Calculates the class predicted match ratio beetwen C and Python predictions

        Parameters:
            metrics_c (Numpy Array): C predictions metrics array             
            metrics_py (Numpy Array): Python prediction metrics array
                Shape 2D (Numer of Predictions, 4)
                        0: Correct?
                        1: Class Predicted
                        2: H
                        3: Ep

        Returns:
            Predictions Match ratio
    """

    return (np.sum(metrics_c[:,1] == metrics_py[:,1])) / metrics_c.shape[0]

COLOR_1 = "#11008f"
COLOR_1_LIGHT = "#8566bd"

COLOR_2 = "#ffa000"
COLOR_2_LIGHT = "#ffc57a"

def group_accuracy_data(metrics, bins):
    acc_data = []
    for i in range(len(bins) - 1):
        g = metrics[(metrics[:,2] >= bins[i]) & (metrics[:,2] < bins[i+1])]     

        # Empty group
        if g.shape[0] == 0:
            acc_data.append([0,0])

        else:  
            acc_data.append([np.sum(g[:,0]) / g.shape[0], g.shape[0] / metrics.shape[0]])

    # len(bins) - 1
    # bin accuracy, % of total data in bin
    return np.array(acc_data)



def plot_accuracy_vs_uncertainty(metrics_c, metrics_py, result_dir, num_groups=15):
    # Create fig
    fig, axes = pl.subplots(1,1)
    axes.set_ylim(0,1)
    w = 0.03

    # Divide in bins
    _, bins = np.histogram(metrics_c[:,2], bins=num_groups)
    # Generate plot data
    plot_data = group_accuracy_data(metrics_c, bins)
    # Plot
    axes.bar(bins[:-1]-w/2, plot_data[:,1], width=w, color=COLOR_1)
    axes.plot(bins[:-1], plot_data[:,0], color=COLOR_1)

    # Repeat using same bins for python prediction
    plot_data = group_accuracy_data(metrics_py, bins)
    axes.bar(bins[:-1]+w/2, plot_data[:,1], width=w, color=COLOR_2)
    axes.plot(bins[:-1], plot_data[:,0], color=COLOR_2)

    # Legend
    axes.legend(
        ['C', 'Python'],
        bbox_to_anchor=(0.5, 1),
        loc='lower center', ncols=2
    )

    axes.set_ylabel('% of pixels in group')

    secax_y = axes.secondary_yaxis(location="right")
    secax_y.set_ylabel('Group accuracy')

    axes.set_xlabel('Group Uncertainty')

    fig.tight_layout()
    fig.savefig(f'{result_dir}/accuracy_vs_uncertainty.pdf')
    fig.savefig(f'{result_dir}/accuracy_vs_uncertainty.png')



def plot_class_uncertainty(metrics_c, metrics_py, num_classes, labels, result_dir):

    # Create fig
    fig, axes = pl.subplots(1,1)
    axes.set_ylim(0,log(num_classes))
    w = 0.4
    x_bar = np.arange(num_classes)
    axes.set_xticks(x_bar)

    axes.set_ylabel('Average uncertainty')
    axes.set_xlabel("Class")

    plot_data_c_H = []
    plot_data_c_Ep = []
    plot_data_py_H = []
    plot_data_py_Ep = []

    for i in range(num_classes):

        # Select only pixels from class i
        mask = labels[:] == i

        plot_data_c_H.append(np.mean(metrics_c[mask,2]))
        plot_data_c_Ep.append(np.mean(metrics_c[mask,3]))

        plot_data_py_H.append(np.mean(metrics_py[mask,2]))
        plot_data_py_Ep.append(np.mean(metrics_py[mask,3]))

    axes.bar(x_bar - w/2, plot_data_py_H, width=w, color=COLOR_2_LIGHT, edgecolor='black', zorder=3)
    axes.bar(x_bar - w/2, plot_data_py_Ep, width=w, color=COLOR_2, edgecolor='black', zorder=3)

    axes.bar(x_bar + w/2, plot_data_c_H, width=w, color=COLOR_1_LIGHT, edgecolor='black', zorder=3)
    axes.bar(x_bar + w/2, plot_data_c_Ep, width=w, color=COLOR_1, edgecolor='black', zorder=3)

    # Legend
    axes.legend(
        ['Python $\mathbb{H}$', 'Python $\mathbb{E}_{p(w|D)}$', 'C $\mathbb{H}$', 'C $\mathbb{E}_{p(w|D)}$'],
        bbox_to_anchor=(0.5, 1),
        loc='lower center', ncols=4
    )

    fig.tight_layout()
    fig.savefig(f'{result_dir}/class_uncertainty.pdf')
    fig.savefig(f'{result_dir}/class_uncertainty.png')

def plot_calibration(averages_c, averages_py, labels, result_dir):
    _, num_classes =  averages_c.shape

    labels_one_hot = np.zeros((len(labels), num_classes))
    labels_one_hot[range(len(labels)), labels] = 1

    p_groups = np.linspace(0,1,11)
    center = p_groups[:-1] + (p_groups[1:] - p_groups[:-1]) / 2

    fig, ax = pl.subplots(1,1)
    ax.set(xticks=p_groups, yticks=p_groups)
    ax.plot(center, center, color='black', linestyle='dashed')

    p_groups[-1] += 0.1

    averages = averages_c
    result = []
    for i in range(len(p_groups) - 1):
        p_min = p_groups[i]
        p_max = p_groups[i + 1]
        group = labels_one_hot[(averages >= p_min) & (averages < p_max)]
        result.append(group.sum() / len(group))
    ax.plot(center, result, color=COLOR_1)

    averages = averages_py
    result = []
    for i in range(len(p_groups) - 1):
        p_min = p_groups[i]
        p_max = p_groups[i + 1]
        group = labels_one_hot[(averages >= p_min) & (averages < p_max)]
        result.append(group.sum() / len(group))
    ax.plot(center, result, color=COLOR_2)

    ax.legend(
        ["Optimal Calibration", 'C', 'Python'],
        bbox_to_anchor=(0.5, 1),
        loc='lower center', ncols=3
    )

    ax.grid(visible=True, axis='y', zorder=0)

    fig.tight_layout()
    fig.savefig(f'{result_dir}/calibration.pdf')
    fig.savefig(f'{result_dir}/calibration.png')


def plot_prediction_uncertainty(metrics_c, metrics_py, result_dir):
    fig, axes = pl.subplots(1,2)

    ax = axes[0]
    metrics = metrics_py
    data_correct = metrics[metrics[:,0] == 1.0]
    data_fail = metrics[metrics[:,0] == 0.0]
    counts, bins = np.histogram(data_fail[:,2], 10)
    ax.hist(bins[:-1], bins, weights=counts / np.sum(counts), color='red', alpha=0.7, zorder=3)
    counts, bins = np.histogram(data_correct[:,2], 10)
    ax.hist(bins[:-1], bins, weights=counts / np.sum(counts),  color='royalblue', alpha=0.8, zorder=3)
    ax.set_ylim([0, 1])
    ax.set_title("Python")
    ax.grid(visible=True, axis='y', zorder=0)

    ax = axes[1]
    metrics = metrics_c
    data_correct = metrics[metrics[:,0] == 1.0]
    data_fail = metrics[metrics[:,0] == 0.0]
    counts, bins = np.histogram(data_fail[:,2], 10)
    ax.hist(bins[:-1], bins, weights=counts / np.sum(counts), color='red', alpha=0.7, zorder=3, label="Incorrect predictions")
    counts, bins = np.histogram(data_correct[:,2], 10)
    ax.hist(bins[:-1], bins, weights=counts / np.sum(counts),  color='royalblue', alpha=0.8, zorder=3, label="Correct predictions")
    ax.set_ylim([0, 1])
    ax.set_title("C")
    ax.grid(visible=True, axis='y', zorder=0)
    ax.legend()

    fig.supxlabel('Prediction Uncertainty')
    fig.supylabel('Density')

    fig.tight_layout()
    fig.savefig(f'{result_dir}/prediction_uncertainty.pdf')
    fig.savefig(f'{result_dir}/prediction_uncertainty.png')


def compare_predictions_plots(data_c, data_py, labels, result_dir):
    metrics_c, averages_c = data_c
    metrics_py, averages_py = data_py
    _, num_classes = averages_c.shape

    # Plot acc vs uncertainty
    plot_accuracy_vs_uncertainty(metrics_c, metrics_py, result_dir)
    # Plot clas uncertainty
    plot_class_uncertainty(metrics_c, metrics_py, num_classes, labels, result_dir)
    plot_prediction_uncertainty(metrics_c, metrics_py, result_dir)
    plot_calibration(averages_c, averages_py, labels, result_dir)

    # Clean matplotlib
    pl.close('all')
