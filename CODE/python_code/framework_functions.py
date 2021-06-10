import importlib
import numpy as np
from python_code import utils, conv_measures

utils = importlib.reload(utils)
conv_measures = importlib.reload(conv_measures)

framework_functions = {
    'original': {
        'f': conv_measures.identity,
        'conv_importer': utils.get_convs,
        'p': {},
        'default_alphas': [None],
        'keep_only': None,
    },


    'recursive-down-mean': {
        'f': conv_measures.recursive_measure,
        'p': {'aggregator': np.mean, 'default_alpha': False},
        'conv_importer': utils.get_convs,
        #'default_alphas': list(np.linspace(0, 1, 101)), #[0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
        'default_alphas': [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
        'keep_only': None
    },
    'recursive-down-mean-only_roots': {
        'f': conv_measures.recursive_measure,
        'p': {'aggregator': np.mean, 'default_alpha': False},
        'conv_importer': utils.get_convs,
        'default_alphas': [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
        'keep_only': 'roots'
    },
    'recursive-down-max': {
        'f': conv_measures.recursive_measure,
        'p': {'aggregator': np.max, 'default_alpha': False},
        'conv_importer': utils.get_convs,
        'default_alphas': [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
        'keep_only': None
    },
    'recursive-up-mean': {
        'f': conv_measures.recursive_inverse_measure,
        'p': {'aggregator': np.max, 'default_alpha': False},
        'conv_importer': lambda : utils.get_convs(conv_type='backward'),
        'default_alphas': [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
        'keep_only': None
    },
    'recursive-up-max': {
        'f': conv_measures.recursive_inverse_measure,
        'p': {'aggregator': np.max, 'default_alpha': False},
        'conv_importer': lambda : utils.get_convs(conv_type='backward'),
        'default_alphas': [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
        'keep_only': None
    },
    'distance': {
        'f': conv_measures.distance_from_root,
        'p': {},
        'conv_importer': lambda : utils.get_convs(conv_type='backward'),
        'default_alphas': [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2.],
        'keep_only': None
    },

    'markovian-backward-mean': {
        'f': conv_measures.markov_recursive,
        'p' : {'aggregator': np.mean},
        'conv_importer': utils.get_convs,
        'default_alphas': [None],
        'keep_only': 'roots'

    },

    'markovian-forward-mean': {
        'f': conv_measures.markov_recursive_inverse,
        'p': {'aggregator': np.mean},
        'conv_importer': lambda : utils.get_convs(conv_type='backward'),
        'default_alphas': [None],
        'keep_only': 'leaves'

    },
    'markovian-recursive': {
        'f': conv_measures.markov_recursive_inverse_II,
        'p': {'aggregator': np.mean},
        'conv_importer': utils.get_convs,
        'default_alphas': [None],
        'keep_only': None
    },
    'hrbp-b': {
        'f': conv_measures.hrbp_b,
        'p': {'aggregator': np.mean},
        'conv_importer': utils.get_convs,
        'default_alphas': [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
        'keep_only': 'leaves'
    },

    'hrbp-f': {
        'f': conv_measures.hrbp_f,
        'p': {'aggregator': np.mean},
        'conv_importer': utils.get_convs,
        'default_alphas': [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
        'keep_only': 'roots'
    },

    'hrbp-b-full': {
        'f': conv_measures.hrbp_b,
        'p': {'aggregator': np.mean},
        'conv_importer': utils.get_convs,
        'default_alphas': [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
        'keep_only': None,
    },

    'hrbp-f-full': {
        'f': conv_measures.hrbp_f,
        'p': {'aggregator': np.mean},
        'conv_importer': utils.get_convs,
        'default_alphas': [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1],
        'keep_only': None,
    },
}
