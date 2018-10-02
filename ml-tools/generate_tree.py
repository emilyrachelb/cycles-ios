#   Filename:       generate_tree.py
#   Author:         emily
#   Date:           September 21, 2018
#   Description:    Generates a decision tree and ML Model
#
#   Copyright (c) 2017 - 2018 emily

#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:

#   The above copyright notice and this permission notice shall be included in all
#   copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#   SOFTWARE.

from __future__ import print_function

import os
import subprocess
import pprint
import random
import warnings

import pandas as pd
import numpy as np

from sklearn.tree import DecisionTreeClassifier, export_graphviz
from sklearn import model_selection

import coremltools


# suppress warnings
def warn(*args, **kwargs):
    pass
warnings.warn = warn


# create tree
def get_code(tree, feature_names, target_names, spacer_base="   "):
    left = tree.tree_.children_left
    right = tree.tree_.children_right
    threshold = tree.tree_.threshold
    features = [feature_names[i] for i in tree.tree_.feature]
    value = tree.tree_.value

    def recurse(left, right, threshold, features, node, depth):
        spacer = spacer_base * depth
        if (threshold[node] != -2):
            print(spacer + "if ( " + features[node] + " <= " + \
            str(threshold[node]) + " ) {")
            if left[node] != -1:
                recurse (left, right, threshold, features, left[node],
                depth+1)
                print(spacer + "}\n" + spacer +"else {")
                if right[node] != -1:
                    recurse (left, right, threshold, features, right[node],
                             depth+1)
            print(spacer + "}")
        else:
            target = value[node]
            for i, v in zip(np.nonzero(target)[1], target[np.nonzero(target)]):
                target_name = target_names[i]
                target_count = int(v)
                print(spacer + "return " + str(target_name) + " ( " + \
                      str(target_count) + " examples )")

    recurse(left, right, threshold, features, 0, 0)


def visualize_tree(tree, feature_names):
    with open("dt.dot", 'w') as f:
        export_graphviz(tree, out_file=f, feature_names=feature_names)
    command = ["dot", "-Tpng", "dt.dot", "-o", "dt.png"]
    try:
        subprocess.check_call(command)
    except:
        exit("Could not run dot, ie graphviz, to produce visualization")

def encode_target(dataset, target_column):
    dataset_mod = dataset.copy()
    targets = dataset_mod[target_column].unique()
    map_to_int = {name: n for n, name in enumerate(targets)}
    dataset_mod["Target"] = dataset_mod[target_column].replace(map_to_int)

    return (dataset_mod, targets)

if __name__ == '__main__':
    # Load dataset
    url = "train_data/csv/training_data.csv"
    names = [
        'date', 'basalBodyTemperature', 'restingHeartRate', 'bodyWeightPounds', 'bodyWeightKilos', 'bodyMassIndex',
        'bodyFat', 'activitySteps', 'sleepMinutesAsleep', 'sleepHoursAsleep', 'cycleStateTarget', 'menstrualFlowTarget',
        'cycleState', 'menstrualFlow', 'cycleDay', 'sex', 'insem', 'opk', 'hpt'
    ]

    dataset = pd.read_csv(url, header=0, delimiter=',', names=names, dtype={
        'date': 'object',
        'basalBodyTemperature': 'float64',
        'restingHeartRate': 'int64',
        'bodyWeightPounds': 'float64',
        'bodyWeightKilos': 'float64',
        'bodyMassIndex': 'float64',
        'bodyFat': 'float64',
        'activitySteps': 'int64',
        'sleepMinutesAsleep': 'float64',
        'sleepHoursAsleep': 'float64',
        'cycleStateTarget': 'int64',
        'menstrualFlowTarget': 'int64',
        'cycleState': 'object',
        'menstrualFlow': 'object',
        'cycleDay': 'int64',
        'sex': 'int64',
        'insem': 'object',
        'opk': 'object',
        'hpt': 'object'
    }, na_filter=False)

    features = ["basalBodyTemperature", "menstrualFlowTarget", "cycleDay"]
    dataset, targets = encode_target(dataset, "cycleState")
    y = dataset["cycleState"]
    x = dataset[features]

    dataset = DecisionTreeClassifier(min_samples_split=10, random_state=99)
    dataset.fit(x,y)

    get_code(dataset, features, targets)
    visualize_tree(dataset, features)

    # descriptions
    model = coremltools.converters.sklearn.convert(dataset,
                                                   ["basalBodyTemperature", "menstrualFlowTarget", "cycleDay"],
                                                   "cycleState")
    model.author = 'Samantha Emily-Rachel Belnavis'
    model.short_description = 'Menstrual cycle CART Model'
    model.license = 'MIT'
    model.input_description['basalBodyTemperature'] = 'Basal Body Temperature'
    model.input_description['menstrualFlowTarget'] = ' Enumerated values for menstrual flow states'
    model.input_description['cycleDay'] = 'Cycle Day'
    model.output_description['cycleState'] = 'Cycle state'

    model.save("cycleDataAllModel.mlmodel")
    with open("prediction_test_output.txt", 'w') as f:
        for i in range(1,26):
            f.write('-' * 20)
            f.write('\n')
            f.write('Randomly-Generated Prediction {}'.format(i))
            f.write('\n')

            rand_bbt = round(random.uniform(35.6, 38.0), 2)
            rand_mFlow = random.randint(0, 4)
            rand_cycleDay = random.randint(0,23)

            prediction = model.predict({'basalBodyTemperature': rand_bbt,
                                        'menstrualFlowTarget': rand_mFlow,
                                        'cycleDay': rand_cycleDay})
            for key in prediction:
                output = str(prediction[key])
                output = output.replace(',', ',\n\t ')
                output = output.replace('{', '\n{\n\t\t')
                output = output.replace('}', '\n}')
                f.write('\'{}\'\n'.format(output))
            f.write('\n')

        scores = model_selection.cross_val_score(dataset, x, y, cv=6)
        f.write('-' * 20)
        f.write('\n')
        msg = "Mean Accuracy: %.2f%% | Max. Accuracy: %.2f%% | Min. Accuracy: %.2f%% | Deviation: (+/- %.2f)" % \
              (scores.mean() * 100, scores.max() * 100, scores.min()*100, scores.std())
        f.write(msg)
        print (msg)

