//
//  Tournament.swift
//  Bluff City Cup
//
//  Created by Ross Montague on 2/29/16.
//  Copyright © 2016 Jumpstop Creations. All rights reserved.
//

import Foundation
import CloudKit

class Tournament {
    
    static let alternateShotProbabilities: [Int: [Int: [Int: (blueWin: Double, redWin: Double, tie: Double)]]] = [
        9: [
            1: [
                0: (blueWin: 0.416, redWin: 0.416, tie: 0.169),
            ],
            2: [
                -1: (blueWin: 0.249, redWin: 0.589, tie: 0.162),
                0: (blueWin: 0.411, redWin: 0.411, tie: 0.178),
                1: (blueWin: 0.589, redWin: 0.249, tie: 0.162),
            ],
            3: [
                -2: (blueWin: 0.112, redWin: 0.765, tie: 0.123),
                -1: (blueWin: 0.235, redWin: 0.595, tie: 0.17),
                0: (blueWin: 0.405, redWin: 0.405, tie: 0.19),
                1: (blueWin: 0.595, redWin: 0.235, tie: 0.17),
                2: (blueWin: 0.765, redWin: 0.112, tie: 0.123),
            ],
            4: [
                -3: (blueWin: 0.03, redWin: 0.906, tie: 0.064),
                -2: (blueWin: 0.094, redWin: 0.783, tie: 0.123),
                -1: (blueWin: 0.217, redWin: 0.602, tie: 0.18),
                0: (blueWin: 0.398, redWin: 0.398, tie: 0.204),
                1: (blueWin: 0.602, redWin: 0.217, tie: 0.18),
                2: (blueWin: 0.783, redWin: 0.094, tie: 0.123),
                3: (blueWin: 0.906, redWin: 0.03, tie: 0.064),
            ],
            5: [
                -4: (blueWin: 0.002, redWin: 0.981, tie: 0.016),
                -3: (blueWin: 0.019, redWin: 0.926, tie: 0.055),
                -2: (blueWin: 0.074, redWin: 0.804, tie: 0.122),
                -1: (blueWin: 0.196, redWin: 0.611, tie: 0.192),
                0: (blueWin: 0.389, redWin: 0.389, tie: 0.223),
                1: (blueWin: 0.611, redWin: 0.196, tie: 0.192),
                2: (blueWin: 0.804, redWin: 0.074, tie: 0.122),
                3: (blueWin: 0.926, redWin: 0.019, tie: 0.055),
                4: (blueWin: 0.981, redWin: 0.002, tie: 0.016),
            ],
            6: [
                -4: (blueWin: 0.0, redWin: 0.992, tie: 0.008),
                -3: (blueWin: 0.008, redWin: 0.949, tie: 0.043),
                -2: (blueWin: 0.051, redWin: 0.83, tie: 0.119),
                -1: (blueWin: 0.17, redWin: 0.623, tie: 0.206),
                0: (blueWin: 0.376, redWin: 0.376, tie: 0.247),
                1: (blueWin: 0.623, redWin: 0.17, tie: 0.206),
                2: (blueWin: 0.83, redWin: 0.051, tie: 0.119),
                3: (blueWin: 0.949, redWin: 0.008, tie: 0.043),
                4: (blueWin: 0.992, redWin: 0.0, tie: 0.008),
            ],
            7: [
                -3: (blueWin: 0.0, redWin: 0.973, tie: 0.027),
                -2: (blueWin: 0.027, redWin: 0.865, tie: 0.108),
                -1: (blueWin: 0.135, redWin: 0.64, tie: 0.225),
                0: (blueWin: 0.36, redWin: 0.36, tie: 0.28),
                1: (blueWin: 0.64, redWin: 0.135, tie: 0.225),
                2: (blueWin: 0.865, redWin: 0.027, tie: 0.108),
                3: (blueWin: 0.973, redWin: 0.0, tie: 0.027),
            ],
            8: [
                -2: (blueWin: 0.0, redWin: 0.91, tie: 0.09),
                -1: (blueWin: 0.09, redWin: 0.67, tie: 0.24),
                0: (blueWin: 0.33, redWin: 0.33, tie: 0.34),
                1: (blueWin: 0.67, redWin: 0.09, tie: 0.24),
                2: (blueWin: 0.91, redWin: 0.0, tie: 0.09),
            ],
            9: [
                -1: (blueWin: 0.0, redWin: 0.7, tie: 0.3),
                0: (blueWin: 0.3, redWin: 0.3, tie: 0.4),
                1: (blueWin: 0.7, redWin: 0.0, tie: 0.3),
            ]
        ],
        18: [
            1: [
                0: (blueWin: 0.44, redWin: 0.44, tie: 0.12),
            ],
                2: [
                    -1: (blueWin: 0.32, redWin: 0.562, tie: 0.118),
                    0: (blueWin: 0.438, redWin: 0.438, tie: 0.124),
                    1: (blueWin: 0.562, redWin: 0.32, tie: 0.118),
                ],
                3: [
                    -2: (blueWin: 0.211, redWin: 0.685, tie: 0.104),
                    -1: (blueWin: 0.315, redWin: 0.564, tie: 0.121),
                    0: (blueWin: 0.436, redWin: 0.436, tie: 0.127),
                    1: (blueWin: 0.564, redWin: 0.315, tie: 0.121),
                    2: (blueWin: 0.685, redWin: 0.211, tie: 0.104),
                ],
                4: [
                    -3: (blueWin: 0.122, redWin: 0.797, tie: 0.081),
                    -2: (blueWin: 0.203, redWin: 0.69, tie: 0.106),
                    -1: (blueWin: 0.31, redWin: 0.566, tie: 0.125),
                    0: (blueWin: 0.434, redWin: 0.434, tie: 0.132),
                    1: (blueWin: 0.566, redWin: 0.31, tie: 0.125),
                    2: (blueWin: 0.69, redWin: 0.203, tie: 0.106),
                    3: (blueWin: 0.797, redWin: 0.122, tie: 0.081),
                ],
                5: [
                    -4: (blueWin: 0.06, redWin: 0.886, tie: 0.054),
                    -3: (blueWin: 0.114, redWin: 0.805, tie: 0.081),
                    -2: (blueWin: 0.195, redWin: 0.697, tie: 0.108),
                    -1: (blueWin: 0.303, redWin: 0.568, tie: 0.128),
                    0: (blueWin: 0.432, redWin: 0.432, tie: 0.136),
                    1: (blueWin: 0.568, redWin: 0.303, tie: 0.128),
                    2: (blueWin: 0.697, redWin: 0.195, tie: 0.108),
                    3: (blueWin: 0.805, redWin: 0.114, tie: 0.081),
                    4: (blueWin: 0.886, redWin: 0.06, tie: 0.054),
                ],
                6: [
                    -5: (blueWin: 0.023, redWin: 0.947, tie: 0.03),
                    -4: (blueWin: 0.053, redWin: 0.895, tie: 0.052),
                    -3: (blueWin: 0.105, redWin: 0.814, tie: 0.081),
                    -2: (blueWin: 0.186, redWin: 0.703, tie: 0.11),
                    -1: (blueWin: 0.297, redWin: 0.571, tie: 0.133),
                    0: (blueWin: 0.429, redWin: 0.429, tie: 0.141),
                    1: (blueWin: 0.571, redWin: 0.297, tie: 0.133),
                    2: (blueWin: 0.703, redWin: 0.186, tie: 0.11),
                    3: (blueWin: 0.814, redWin: 0.105, tie: 0.081),
                    4: (blueWin: 0.895, redWin: 0.053, tie: 0.052),
                    5: (blueWin: 0.947, redWin: 0.023, tie: 0.03),
                ],
                7: [
                    -6: (blueWin: 0.007, redWin: 0.981, tie: 0.012),
                    -5: (blueWin: 0.019, redWin: 0.954, tie: 0.027),
                    -4: (blueWin: 0.046, redWin: 0.904, tie: 0.05),
                    -3: (blueWin: 0.096, redWin: 0.823, tie: 0.081),
                    -2: (blueWin: 0.177, redWin: 0.711, tie: 0.113),
                    -1: (blueWin: 0.289, redWin: 0.573, tie: 0.137),
                    0: (blueWin: 0.427, redWin: 0.427, tie: 0.147),
                    1: (blueWin: 0.573, redWin: 0.289, tie: 0.137),
                    2: (blueWin: 0.711, redWin: 0.177, tie: 0.113),
                    3: (blueWin: 0.823, redWin: 0.096, tie: 0.081),
                    4: (blueWin: 0.904, redWin: 0.046, tie: 0.05),
                    5: (blueWin: 0.954, redWin: 0.019, tie: 0.027),
                    6: (blueWin: 0.981, redWin: 0.007, tie: 0.012),
                ],
                8: [
                    -7: (blueWin: 0.001, redWin: 0.995, tie: 0.004),
                    -6: (blueWin: 0.005, redWin: 0.985, tie: 0.01),
                    -5: (blueWin: 0.015, redWin: 0.961, tie: 0.024),
                    -4: (blueWin: 0.039, redWin: 0.914, tie: 0.048),
                    -3: (blueWin: 0.086, redWin: 0.834, tie: 0.08),
                    -2: (blueWin: 0.166, redWin: 0.719, tie: 0.115),
                    -1: (blueWin: 0.281, redWin: 0.576, tie: 0.142),
                    0: (blueWin: 0.424, redWin: 0.424, tie: 0.153),
                    1: (blueWin: 0.576, redWin: 0.281, tie: 0.142),
                    2: (blueWin: 0.719, redWin: 0.166, tie: 0.115),
                    3: (blueWin: 0.834, redWin: 0.086, tie: 0.08),
                    4: (blueWin: 0.914, redWin: 0.039, tie: 0.048),
                    5: (blueWin: 0.961, redWin: 0.015, tie: 0.024),
                    6: (blueWin: 0.985, redWin: 0.005, tie: 0.01),
                    7: (blueWin: 0.995, redWin: 0.001, tie: 0.004),
                ],
                9: [
                    -8: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                    -7: (blueWin: 0.001, redWin: 0.997, tie: 0.002),
                    -6: (blueWin: 0.003, redWin: 0.989, tie: 0.008),
                    -5: (blueWin: 0.011, redWin: 0.968, tie: 0.021),
                    -4: (blueWin: 0.032, redWin: 0.924, tie: 0.044),
                    -3: (blueWin: 0.076, redWin: 0.845, tie: 0.079),
                    -2: (blueWin: 0.155, redWin: 0.728, tie: 0.117),
                    -1: (blueWin: 0.272, redWin: 0.58, tie: 0.148),
                    0: (blueWin: 0.42, redWin: 0.42, tie: 0.16),
                    1: (blueWin: 0.58, redWin: 0.272, tie: 0.148),
                    2: (blueWin: 0.728, redWin: 0.155, tie: 0.117),
                    3: (blueWin: 0.845, redWin: 0.076, tie: 0.079),
                    4: (blueWin: 0.924, redWin: 0.032, tie: 0.044),
                    5: (blueWin: 0.968, redWin: 0.011, tie: 0.021),
                    6: (blueWin: 0.989, redWin: 0.003, tie: 0.008),
                    7: (blueWin: 0.997, redWin: 0.001, tie: 0.002),
                    8: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
                ],
                10: [
                    -9: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                    -8: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                    -7: (blueWin: 0.0, redWin: 0.998, tie: 0.001),
                    -6: (blueWin: 0.002, redWin: 0.992, tie: 0.006),
                    -5: (blueWin: 0.008, redWin: 0.975, tie: 0.017),
                    -4: (blueWin: 0.025, redWin: 0.935, tie: 0.041),
                    -3: (blueWin: 0.065, redWin: 0.858, tie: 0.077),
                    -2: (blueWin: 0.142, redWin: 0.739, tie: 0.119),
                    -1: (blueWin: 0.261, redWin: 0.584, tie: 0.155),
                    0: (blueWin: 0.416, redWin: 0.416, tie: 0.169),
                    1: (blueWin: 0.584, redWin: 0.261, tie: 0.155),
                    2: (blueWin: 0.739, redWin: 0.142, tie: 0.119),
                    3: (blueWin: 0.858, redWin: 0.065, tie: 0.077),
                    4: (blueWin: 0.935, redWin: 0.025, tie: 0.041),
                    5: (blueWin: 0.975, redWin: 0.008, tie: 0.017),
                    6: (blueWin: 0.992, redWin: 0.002, tie: 0.006),
                    7: (blueWin: 0.998, redWin: 0.0, tie: 0.001),
                    8: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
                    9: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
                ],
                11: [
                    -8: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                    -7: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                    -6: (blueWin: 0.001, redWin: 0.995, tie: 0.004),
                    -5: (blueWin: 0.005, redWin: 0.982, tie: 0.014),
                    -4: (blueWin: 0.018, redWin: 0.946, tie: 0.036),
                    -3: (blueWin: 0.054, redWin: 0.872, tie: 0.074),
                    -2: (blueWin: 0.128, redWin: 0.751, tie: 0.121),
                    -1: (blueWin: 0.249, redWin: 0.589, tie: 0.162),
                    0: (blueWin: 0.411, redWin: 0.411, tie: 0.178),
                    1: (blueWin: 0.589, redWin: 0.249, tie: 0.162),
                    2: (blueWin: 0.751, redWin: 0.128, tie: 0.121),
                    3: (blueWin: 0.872, redWin: 0.054, tie: 0.074),
                    4: (blueWin: 0.946, redWin: 0.018, tie: 0.036),
                    5: (blueWin: 0.982, redWin: 0.005, tie: 0.014),
                    6: (blueWin: 0.995, redWin: 0.001, tie: 0.004),
                    7: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
                    8: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
                ],
                12: [
                    -7: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                    -6: (blueWin: 0.0, redWin: 0.998, tie: 0.002),
                    -5: (blueWin: 0.002, redWin: 0.988, tie: 0.01),
                    -4: (blueWin: 0.012, redWin: 0.958, tie: 0.03),
                    -3: (blueWin: 0.042, redWin: 0.888, tie: 0.07),
                    -2: (blueWin: 0.112, redWin: 0.765, tie: 0.123),
                    -1: (blueWin: 0.235, redWin: 0.595, tie: 0.17),
                    0: (blueWin: 0.405, redWin: 0.405, tie: 0.19),
                    1: (blueWin: 0.595, redWin: 0.235, tie: 0.17),
                    2: (blueWin: 0.765, redWin: 0.112, tie: 0.123),
                    3: (blueWin: 0.888, redWin: 0.042, tie: 0.07),
                    4: (blueWin: 0.958, redWin: 0.012, tie: 0.03),
                    5: (blueWin: 0.988, redWin: 0.002, tie: 0.01),
                    6: (blueWin: 0.998, redWin: 0.0, tie: 0.002),
                    7: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
                ],
                13: [
                    -6: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                    -5: (blueWin: 0.001, redWin: 0.993, tie: 0.006),
                    -4: (blueWin: 0.007, redWin: 0.97, tie: 0.024),
                    -3: (blueWin: 0.03, redWin: 0.906, tie: 0.064),
                    -2: (blueWin: 0.094, redWin: 0.783, tie: 0.123),
                    -1: (blueWin: 0.217, redWin: 0.602, tie: 0.18),
                    0: (blueWin: 0.398, redWin: 0.398, tie: 0.204),
                    1: (blueWin: 0.602, redWin: 0.217, tie: 0.18),
                    2: (blueWin: 0.783, redWin: 0.094, tie: 0.123),
                    3: (blueWin: 0.906, redWin: 0.03, tie: 0.064),
                    4: (blueWin: 0.97, redWin: 0.007, tie: 0.024),
                    5: (blueWin: 0.993, redWin: 0.001, tie: 0.006),
                    6: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
                ],
                14: [
                    -5: (blueWin: 0.0, redWin: 0.998, tie: 0.002),
                    -4: (blueWin: 0.002, redWin: 0.981, tie: 0.016),
                    -3: (blueWin: 0.019, redWin: 0.926, tie: 0.055),
                    -2: (blueWin: 0.074, redWin: 0.804, tie: 0.122),
                    -1: (blueWin: 0.196, redWin: 0.611, tie: 0.192),
                    0: (blueWin: 0.389, redWin: 0.389, tie: 0.223),
                    1: (blueWin: 0.611, redWin: 0.196, tie: 0.192),
                    2: (blueWin: 0.804, redWin: 0.074, tie: 0.122),
                    3: (blueWin: 0.926, redWin: 0.019, tie: 0.055),
                    4: (blueWin: 0.981, redWin: 0.002, tie: 0.016),
                    5: (blueWin: 0.998, redWin: 0.0, tie: 0.002),
                ],
                15: [
                    -4: (blueWin: 0.0, redWin: 0.992, tie: 0.008),
                    -3: (blueWin: 0.008, redWin: 0.949, tie: 0.043),
                    -2: (blueWin: 0.051, redWin: 0.83, tie: 0.119),
                    -1: (blueWin: 0.17, redWin: 0.623, tie: 0.206),
                    0: (blueWin: 0.376, redWin: 0.376, tie: 0.247),
                    1: (blueWin: 0.623, redWin: 0.17, tie: 0.206),
                    2: (blueWin: 0.83, redWin: 0.051, tie: 0.119),
                    3: (blueWin: 0.949, redWin: 0.008, tie: 0.043),
                    4: (blueWin: 0.992, redWin: 0.0, tie: 0.008),
                ],
                16: [
                    -3: (blueWin: 0.0, redWin: 0.973, tie: 0.027),
                    -2: (blueWin: 0.027, redWin: 0.865, tie: 0.108),
                    -1: (blueWin: 0.135, redWin: 0.64, tie: 0.225),
                    0: (blueWin: 0.36, redWin: 0.36, tie: 0.28),
                    1: (blueWin: 0.64, redWin: 0.135, tie: 0.225),
                    2: (blueWin: 0.865, redWin: 0.027, tie: 0.108),
                    3: (blueWin: 0.973, redWin: 0.0, tie: 0.027),
                ],
                17: [
                    -2: (blueWin: 0.0, redWin: 0.91, tie: 0.09),
                    -1: (blueWin: 0.09, redWin: 0.67, tie: 0.24),
                    0: (blueWin: 0.33, redWin: 0.33, tie: 0.34),
                    1: (blueWin: 0.67, redWin: 0.09, tie: 0.24),
                    2: (blueWin: 0.91, redWin: 0.0, tie: 0.09),
                ],
                18: [
                    -1: (blueWin: 0.0, redWin: 0.7, tie: 0.3),
                    0: (blueWin: 0.3, redWin: 0.3, tie: 0.4),
                    1: (blueWin: 0.7, redWin: 0.0, tie: 0.3),
                ]
            ]
    ]
    
    static let bestBallProbabilities: [Int: [Int: [Int: (blueWin: Double, redWin: Double, tie: Double)]]] = [
        9: [
            1: [
                0: (blueWin: 0.415, redWin: 0.415, tie: 0.17),
            ],
            2: [
                -1: (blueWin: 0.247, redWin: 0.59, tie: 0.163),
                0: (blueWin: 0.41, redWin: 0.41, tie: 0.18),
                1: (blueWin: 0.59, redWin: 0.247, tie: 0.163),
            ],
            3: [
                -2: (blueWin: 0.11, redWin: 0.768, tie: 0.123),
                -1: (blueWin: 0.232, redWin: 0.596, tie: 0.172),
                0: (blueWin: 0.404, redWin: 0.404, tie: 0.192),
                1: (blueWin: 0.596, redWin: 0.232, tie: 0.172),
                2: (blueWin: 0.768, redWin: 0.11, tie: 0.123),
            ],
            4: [
                -3: (blueWin: 0.029, redWin: 0.908, tie: 0.063),
                -2: (blueWin: 0.092, redWin: 0.785, tie: 0.123),
                -1: (blueWin: 0.215, redWin: 0.603, tie: 0.182),
                0: (blueWin: 0.397, redWin: 0.397, tie: 0.206),
                1: (blueWin: 0.603, redWin: 0.215, tie: 0.182),
                2: (blueWin: 0.785, redWin: 0.092, tie: 0.123),
                3: (blueWin: 0.908, redWin: 0.029, tie: 0.063),
            ],
            5: [
                -4: (blueWin: 0.002, redWin: 0.982, tie: 0.016),
                -3: (blueWin: 0.018, redWin: 0.928, tie: 0.054),
                -2: (blueWin: 0.072, redWin: 0.806, tie: 0.122),
                -1: (blueWin: 0.194, redWin: 0.612, tie: 0.193),
                0: (blueWin: 0.388, redWin: 0.388, tie: 0.225),
                1: (blueWin: 0.612, redWin: 0.194, tie: 0.193),
                2: (blueWin: 0.806, redWin: 0.072, tie: 0.122),
                3: (blueWin: 0.928, redWin: 0.018, tie: 0.054),
                4: (blueWin: 0.982, redWin: 0.002, tie: 0.016),
            ],
            6: [
                -4: (blueWin: 0.0, redWin: 0.992, tie: 0.008),
                -3: (blueWin: 0.008, redWin: 0.95, tie: 0.042),
                -2: (blueWin: 0.05, redWin: 0.832, tie: 0.118),
                -1: (blueWin: 0.168, redWin: 0.625, tie: 0.208),
                0: (blueWin: 0.375, redWin: 0.375, tie: 0.249),
                1: (blueWin: 0.625, redWin: 0.168, tie: 0.208),
                2: (blueWin: 0.832, redWin: 0.05, tie: 0.118),
                3: (blueWin: 0.95, redWin: 0.008, tie: 0.042),
                4: (blueWin: 0.992, redWin: 0.0, tie: 0.008),
            ],
            7: [
                -3: (blueWin: 0.0, redWin: 0.974, tie: 0.026),
                -2: (blueWin: 0.026, redWin: 0.867, tie: 0.107),
                -1: (blueWin: 0.133, redWin: 0.642, tie: 0.226),
                0: (blueWin: 0.358, redWin: 0.358, tie: 0.283),
                1: (blueWin: 0.642, redWin: 0.133, tie: 0.226),
                2: (blueWin: 0.867, redWin: 0.026, tie: 0.107),
                3: (blueWin: 0.974, redWin: 0.0, tie: 0.026),
            ],
            8: [
                -2: (blueWin: 0.0, redWin: 0.913, tie: 0.087),
                -1: (blueWin: 0.087, redWin: 0.671, tie: 0.242),
                0: (blueWin: 0.329, redWin: 0.329, tie: 0.342),
                1: (blueWin: 0.671, redWin: 0.087, tie: 0.242),
                2: (blueWin: 0.913, redWin: 0.0, tie: 0.087),
            ],
            9: [
                -1: (blueWin: 0.0, redWin: 0.705, tie: 0.295),
                0: (blueWin: 0.295, redWin: 0.295, tie: 0.41),
                1: (blueWin: 0.705, redWin: 0.0, tie: 0.295),
            ]
        ],
        18: [
            1: [
                0: (blueWin: 0.439, redWin: 0.439, tie: 0.121),
            ],
            2: [
                -1: (blueWin: 0.319, redWin: 0.562, tie: 0.119),
                0: (blueWin: 0.438, redWin: 0.438, tie: 0.125),
                1: (blueWin: 0.562, redWin: 0.319, tie: 0.119),
            ],
            3: [
                -2: (blueWin: 0.209, redWin: 0.686, tie: 0.105),
                -1: (blueWin: 0.314, redWin: 0.564, tie: 0.122),
                0: (blueWin: 0.436, redWin: 0.436, tie: 0.129),
                1: (blueWin: 0.564, redWin: 0.314, tie: 0.122),
                2: (blueWin: 0.686, redWin: 0.209, tie: 0.105),
            ],
            4: [
                -3: (blueWin: 0.12, redWin: 0.799, tie: 0.081),
                -2: (blueWin: 0.201, redWin: 0.692, tie: 0.107),
                -1: (blueWin: 0.308, redWin: 0.566, tie: 0.126),
                0: (blueWin: 0.434, redWin: 0.434, tie: 0.133),
                1: (blueWin: 0.566, redWin: 0.308, tie: 0.126),
                2: (blueWin: 0.692, redWin: 0.201, tie: 0.107),
                3: (blueWin: 0.799, redWin: 0.12, tie: 0.081),
            ],
            5: [
                -4: (blueWin: 0.058, redWin: 0.888, tie: 0.054),
                -3: (blueWin: 0.112, redWin: 0.807, tie: 0.081),
                -2: (blueWin: 0.193, redWin: 0.698, tie: 0.109),
                -1: (blueWin: 0.302, redWin: 0.569, tie: 0.129),
                0: (blueWin: 0.431, redWin: 0.431, tie: 0.137),
                1: (blueWin: 0.569, redWin: 0.302, tie: 0.129),
                2: (blueWin: 0.698, redWin: 0.193, tie: 0.109),
                3: (blueWin: 0.807, redWin: 0.112, tie: 0.081),
                4: (blueWin: 0.888, redWin: 0.058, tie: 0.054),
            ],
            6: [
                -5: (blueWin: 0.022, redWin: 0.949, tie: 0.029),
                -4: (blueWin: 0.051, redWin: 0.897, tie: 0.052),
                -3: (blueWin: 0.103, redWin: 0.816, tie: 0.081),
                -2: (blueWin: 0.184, redWin: 0.705, tie: 0.111),
                -1: (blueWin: 0.295, redWin: 0.571, tie: 0.134),
                0: (blueWin: 0.429, redWin: 0.429, tie: 0.142),
                1: (blueWin: 0.571, redWin: 0.295, tie: 0.134),
                2: (blueWin: 0.705, redWin: 0.184, tie: 0.111),
                3: (blueWin: 0.816, redWin: 0.103, tie: 0.081),
                4: (blueWin: 0.897, redWin: 0.051, tie: 0.052),
                5: (blueWin: 0.949, redWin: 0.022, tie: 0.029),
            ],
            7: [
                -6: (blueWin: 0.006, redWin: 0.982, tie: 0.012),
                -5: (blueWin: 0.018, redWin: 0.955, tie: 0.026),
                -4: (blueWin: 0.045, redWin: 0.906, tie: 0.05),
                -3: (blueWin: 0.094, redWin: 0.825, tie: 0.08),
                -2: (blueWin: 0.175, redWin: 0.712, tie: 0.113),
                -1: (blueWin: 0.288, redWin: 0.574, tie: 0.138),
                0: (blueWin: 0.426, redWin: 0.426, tie: 0.148),
                1: (blueWin: 0.574, redWin: 0.288, tie: 0.138),
                2: (blueWin: 0.712, redWin: 0.175, tie: 0.113),
                3: (blueWin: 0.825, redWin: 0.094, tie: 0.08),
                4: (blueWin: 0.906, redWin: 0.045, tie: 0.05),
                5: (blueWin: 0.955, redWin: 0.018, tie: 0.026),
                6: (blueWin: 0.982, redWin: 0.006, tie: 0.012),
            ],
            8: [
                -7: (blueWin: 0.001, redWin: 0.996, tie: 0.003),
                -6: (blueWin: 0.004, redWin: 0.986, tie: 0.01),
                -5: (blueWin: 0.014, redWin: 0.962, tie: 0.023),
                -4: (blueWin: 0.038, redWin: 0.915, tie: 0.047),
                -3: (blueWin: 0.085, redWin: 0.836, tie: 0.08),
                -2: (blueWin: 0.164, redWin: 0.721, tie: 0.115),
                -1: (blueWin: 0.279, redWin: 0.577, tie: 0.143),
                0: (blueWin: 0.423, redWin: 0.423, tie: 0.154),
                1: (blueWin: 0.577, redWin: 0.279, tie: 0.143),
                2: (blueWin: 0.721, redWin: 0.164, tie: 0.115),
                3: (blueWin: 0.836, redWin: 0.085, tie: 0.08),
                4: (blueWin: 0.915, redWin: 0.038, tie: 0.047),
                5: (blueWin: 0.962, redWin: 0.014, tie: 0.023),
                6: (blueWin: 0.986, redWin: 0.004, tie: 0.01),
                7: (blueWin: 0.996, redWin: 0.001, tie: 0.003),
            ],
            9: [
                -8: (blueWin: 0.0, redWin: 0.999, tie: 0.0),
                -7: (blueWin: 0.001, redWin: 0.997, tie: 0.002),
                -6: (blueWin: 0.003, redWin: 0.99, tie: 0.008),
                -5: (blueWin: 0.01, redWin: 0.969, tie: 0.02),
                -4: (blueWin: 0.031, redWin: 0.926, tie: 0.044),
                -3: (blueWin: 0.074, redWin: 0.847, tie: 0.078),
                -2: (blueWin: 0.153, redWin: 0.73, tie: 0.117),
                -1: (blueWin: 0.27, redWin: 0.581, tie: 0.149),
                0: (blueWin: 0.419, redWin: 0.419, tie: 0.162),
                1: (blueWin: 0.581, redWin: 0.27, tie: 0.149),
                2: (blueWin: 0.73, redWin: 0.153, tie: 0.117),
                3: (blueWin: 0.847, redWin: 0.074, tie: 0.078),
                4: (blueWin: 0.926, redWin: 0.031, tie: 0.044),
                5: (blueWin: 0.969, redWin: 0.01, tie: 0.02),
                6: (blueWin: 0.99, redWin: 0.003, tie: 0.008),
                7: (blueWin: 0.997, redWin: 0.001, tie: 0.002),
                8: (blueWin: 0.999, redWin: 0.0, tie: 0.0),
            ],
            10: [
                -9: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -8: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -7: (blueWin: 0.0, redWin: 0.998, tie: 0.001),
                -6: (blueWin: 0.002, redWin: 0.993, tie: 0.006),
                -5: (blueWin: 0.007, redWin: 0.976, tie: 0.017),
                -4: (blueWin: 0.024, redWin: 0.936, tie: 0.04),
                -3: (blueWin: 0.064, redWin: 0.86, tie: 0.076),
                -2: (blueWin: 0.14, redWin: 0.741, tie: 0.119),
                -1: (blueWin: 0.259, redWin: 0.585, tie: 0.156),
                0: (blueWin: 0.415, redWin: 0.415, tie: 0.17),
                1: (blueWin: 0.585, redWin: 0.259, tie: 0.156),
                2: (blueWin: 0.741, redWin: 0.14, tie: 0.119),
                3: (blueWin: 0.86, redWin: 0.064, tie: 0.076),
                4: (blueWin: 0.936, redWin: 0.024, tie: 0.04),
                5: (blueWin: 0.976, redWin: 0.007, tie: 0.017),
                6: (blueWin: 0.993, redWin: 0.002, tie: 0.006),
                7: (blueWin: 0.998, redWin: 0.0, tie: 0.001),
                8: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
                9: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            11: [
                -8: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -7: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                -6: (blueWin: 0.001, redWin: 0.996, tie: 0.004),
                -5: (blueWin: 0.004, redWin: 0.983, tie: 0.013),
                -4: (blueWin: 0.017, redWin: 0.947, tie: 0.035),
                -3: (blueWin: 0.053, redWin: 0.874, tie: 0.073),
                -2: (blueWin: 0.126, redWin: 0.753, tie: 0.121),
                -1: (blueWin: 0.247, redWin: 0.59, tie: 0.163),
                0: (blueWin: 0.41, redWin: 0.41, tie: 0.18),
                1: (blueWin: 0.59, redWin: 0.247, tie: 0.163),
                2: (blueWin: 0.753, redWin: 0.126, tie: 0.121),
                3: (blueWin: 0.874, redWin: 0.053, tie: 0.073),
                4: (blueWin: 0.947, redWin: 0.017, tie: 0.035),
                5: (blueWin: 0.983, redWin: 0.004, tie: 0.013),
                6: (blueWin: 0.996, redWin: 0.001, tie: 0.004),
                7: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
                8: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            12: [
                -7: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -6: (blueWin: 0.0, redWin: 0.998, tie: 0.002),
                -5: (blueWin: 0.002, redWin: 0.989, tie: 0.009),
                -4: (blueWin: 0.011, redWin: 0.959, tie: 0.03),
                -3: (blueWin: 0.041, redWin: 0.89, tie: 0.069),
                -2: (blueWin: 0.11, redWin: 0.768, tie: 0.123),
                -1: (blueWin: 0.232, redWin: 0.596, tie: 0.172),
                0: (blueWin: 0.404, redWin: 0.404, tie: 0.192),
                1: (blueWin: 0.596, redWin: 0.232, tie: 0.172),
                2: (blueWin: 0.768, redWin: 0.11, tie: 0.123),
                3: (blueWin: 0.89, redWin: 0.041, tie: 0.069),
                4: (blueWin: 0.959, redWin: 0.011, tie: 0.03),
                5: (blueWin: 0.989, redWin: 0.002, tie: 0.009),
                6: (blueWin: 0.998, redWin: 0.0, tie: 0.002),
                7: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            13: [
                -6: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                -5: (blueWin: 0.001, redWin: 0.994, tie: 0.005),
                -4: (blueWin: 0.006, redWin: 0.971, tie: 0.023),
                -3: (blueWin: 0.029, redWin: 0.908, tie: 0.063),
                -2: (blueWin: 0.092, redWin: 0.785, tie: 0.123),
                -1: (blueWin: 0.215, redWin: 0.603, tie: 0.182),
                0: (blueWin: 0.397, redWin: 0.397, tie: 0.206),
                1: (blueWin: 0.603, redWin: 0.215, tie: 0.182),
                2: (blueWin: 0.785, redWin: 0.092, tie: 0.123),
                3: (blueWin: 0.908, redWin: 0.029, tie: 0.063),
                4: (blueWin: 0.971, redWin: 0.006, tie: 0.023),
                5: (blueWin: 0.994, redWin: 0.001, tie: 0.005),
                6: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
            ],
            14: [
                -5: (blueWin: 0.0, redWin: 0.998, tie: 0.002),
                -4: (blueWin: 0.002, redWin: 0.982, tie: 0.016),
                -3: (blueWin: 0.018, redWin: 0.928, tie: 0.054),
                -2: (blueWin: 0.072, redWin: 0.806, tie: 0.122),
                -1: (blueWin: 0.194, redWin: 0.612, tie: 0.193),
                0: (blueWin: 0.388, redWin: 0.388, tie: 0.225),
                1: (blueWin: 0.612, redWin: 0.194, tie: 0.193),
                2: (blueWin: 0.806, redWin: 0.072, tie: 0.122),
                3: (blueWin: 0.928, redWin: 0.018, tie: 0.054),
                4: (blueWin: 0.982, redWin: 0.002, tie: 0.016),
                5: (blueWin: 0.998, redWin: 0.0, tie: 0.002),
            ],
            15: [
                -4: (blueWin: 0.0, redWin: 0.992, tie: 0.008),
                -3: (blueWin: 0.008, redWin: 0.95, tie: 0.042),
                -2: (blueWin: 0.05, redWin: 0.832, tie: 0.118),
                -1: (blueWin: 0.168, redWin: 0.625, tie: 0.208),
                0: (blueWin: 0.375, redWin: 0.375, tie: 0.249),
                1: (blueWin: 0.625, redWin: 0.168, tie: 0.208),
                2: (blueWin: 0.832, redWin: 0.05, tie: 0.118),
                3: (blueWin: 0.95, redWin: 0.008, tie: 0.042),
                4: (blueWin: 0.992, redWin: 0.0, tie: 0.008),
            ],
            16: [
                -3: (blueWin: 0.0, redWin: 0.974, tie: 0.026),
                -2: (blueWin: 0.026, redWin: 0.867, tie: 0.107),
                -1: (blueWin: 0.133, redWin: 0.642, tie: 0.226),
                0: (blueWin: 0.358, redWin: 0.358, tie: 0.283),
                1: (blueWin: 0.642, redWin: 0.133, tie: 0.226),
                2: (blueWin: 0.867, redWin: 0.026, tie: 0.107),
                3: (blueWin: 0.974, redWin: 0.0, tie: 0.026),
            ],
            17: [
                -2: (blueWin: 0.0, redWin: 0.913, tie: 0.087),
                -1: (blueWin: 0.087, redWin: 0.671, tie: 0.242),
                0: (blueWin: 0.329, redWin: 0.329, tie: 0.342),
                1: (blueWin: 0.671, redWin: 0.087, tie: 0.242),
                2: (blueWin: 0.913, redWin: 0.0, tie: 0.087),
            ],
            18: [
                -1: (blueWin: 0.0, redWin: 0.705, tie: 0.295),
                0: (blueWin: 0.295, redWin: 0.295, tie: 0.41),
                1: (blueWin: 0.705, redWin: 0.0, tie: 0.295),
            ]
        ]
    
    ]
    
    static let singlesProbabilities: [Int: [Int: [Int: (blueWin: Double, redWin: Double, tie: Double)]]] = [
        9: [
            1: [
                0: (blueWin: 0.421, redWin: 0.421, tie: 0.158),
            ],
            2: [
                -1: (blueWin: 0.263, redWin: 0.583, tie: 0.154),
                0: (blueWin: 0.417, redWin: 0.417, tie: 0.167),
                1: (blueWin: 0.583, redWin: 0.263, tie: 0.154),
            ],
            3: [
                -2: (blueWin: 0.128, redWin: 0.751, tie: 0.121),
                -1: (blueWin: 0.249, redWin: 0.589, tie: 0.162),
                0: (blueWin: 0.411, redWin: 0.411, tie: 0.178),
                1: (blueWin: 0.589, redWin: 0.249, tie: 0.162),
                2: (blueWin: 0.751, redWin: 0.128, tie: 0.121),
            ],
            4: [
                -3: (blueWin: 0.04, redWin: 0.891, tie: 0.069),
                -2: (blueWin: 0.109, redWin: 0.767, tie: 0.123),
                -1: (blueWin: 0.233, redWin: 0.596, tie: 0.171),
                0: (blueWin: 0.404, redWin: 0.404, tie: 0.191),
                1: (blueWin: 0.596, redWin: 0.233, tie: 0.171),
                2: (blueWin: 0.767, redWin: 0.109, tie: 0.123),
                3: (blueWin: 0.891, redWin: 0.04, tie: 0.069),
            ],
            5: [
                -4: (blueWin: 0.005, redWin: 0.974, tie: 0.021),
                -3: (blueWin: 0.026, redWin: 0.911, tie: 0.063),
                -2: (blueWin: 0.089, redWin: 0.788, tie: 0.123),
                -1: (blueWin: 0.212, redWin: 0.604, tie: 0.184),
                0: (blueWin: 0.396, redWin: 0.396, tie: 0.207),
                1: (blueWin: 0.604, redWin: 0.212, tie: 0.184),
                2: (blueWin: 0.788, redWin: 0.089, tie: 0.123),
                3: (blueWin: 0.911, redWin: 0.026, tie: 0.063),
                4: (blueWin: 0.974, redWin: 0.005, tie: 0.021),
            ],
            6: [
                -4: (blueWin: 0.0, redWin: 0.987, tie: 0.013),
                -3: (blueWin: 0.013, redWin: 0.936, tie: 0.05),
                -2: (blueWin: 0.064, redWin: 0.812, tie: 0.124),
                -1: (blueWin: 0.188, redWin: 0.616, tie: 0.195),
                0: (blueWin: 0.384, redWin: 0.384, tie: 0.233),
                1: (blueWin: 0.616, redWin: 0.188, tie: 0.195),
                2: (blueWin: 0.812, redWin: 0.064, tie: 0.124),
                3: (blueWin: 0.936, redWin: 0.013, tie: 0.05),
                4: (blueWin: 0.987, redWin: 0.0, tie: 0.013),
            ],
            7: [
                -3: (blueWin: 0.0, redWin: 0.961, tie: 0.039),
                -2: (blueWin: 0.039, redWin: 0.85, tie: 0.111),
                -1: (blueWin: 0.15, redWin: 0.627, tie: 0.222),
                0: (blueWin: 0.373, redWin: 0.373, tie: 0.255),
                1: (blueWin: 0.627, redWin: 0.15, tie: 0.222),
                2: (blueWin: 0.85, redWin: 0.039, tie: 0.111),
                3: (blueWin: 0.961, redWin: 0.0, tie: 0.039),
            ],
            8: [
                -2: (blueWin: 0.0, redWin: 0.884, tie: 0.116),
                -1: (blueWin: 0.116, redWin: 0.667, tie: 0.218),
                0: (blueWin: 0.333, redWin: 0.333, tie: 0.334),
                1: (blueWin: 0.667, redWin: 0.116, tie: 0.218),
                2: (blueWin: 0.884, redWin: 0.0, tie: 0.116),
            ],
            9: [
                -1: (blueWin: 0.0, redWin: 0.66, tie: 0.34),
                0: (blueWin: 0.34, redWin: 0.34, tie: 0.32),
                1: (blueWin: 0.66, redWin: 0.0, tie: 0.34),
            ]
        ],
        18: [
            1: [
                0: (blueWin: 0.444, redWin: 0.444, tie: 0.113),
            ],
            2: [
                -1: (blueWin: 0.331, redWin: 0.558, tie: 0.111),
                0: (blueWin: 0.442, redWin: 0.442, tie: 0.116),
                1: (blueWin: 0.558, redWin: 0.331, tie: 0.111),
            ],
            3: [
                -2: (blueWin: 0.226, redWin: 0.674, tie: 0.1),
                -1: (blueWin: 0.326, redWin: 0.56, tie: 0.114),
                0: (blueWin: 0.44, redWin: 0.44, tie: 0.12),
                1: (blueWin: 0.56, redWin: 0.326, tie: 0.114),
                2: (blueWin: 0.674, redWin: 0.226, tie: 0.1),
            ],
            4: [
                -3: (blueWin: 0.137, redWin: 0.782, tie: 0.081),
                -2: (blueWin: 0.218, redWin: 0.679, tie: 0.102),
                -1: (blueWin: 0.321, redWin: 0.562, tie: 0.118),
                0: (blueWin: 0.438, redWin: 0.438, tie: 0.123),
                1: (blueWin: 0.562, redWin: 0.321, tie: 0.118),
                2: (blueWin: 0.679, redWin: 0.218, tie: 0.102),
                3: (blueWin: 0.782, redWin: 0.137, tie: 0.081),
            ],
            5: [
                -4: (blueWin: 0.072, redWin: 0.871, tie: 0.057),
                -3: (blueWin: 0.129, redWin: 0.79, tie: 0.081),
                -2: (blueWin: 0.21, redWin: 0.685, tie: 0.104),
                -1: (blueWin: 0.315, redWin: 0.564, tie: 0.121),
                0: (blueWin: 0.436, redWin: 0.436, tie: 0.128),
                1: (blueWin: 0.564, redWin: 0.315, tie: 0.121),
                2: (blueWin: 0.685, redWin: 0.21, tie: 0.104),
                3: (blueWin: 0.79, redWin: 0.129, tie: 0.081),
                4: (blueWin: 0.871, redWin: 0.072, tie: 0.057),
            ],
            6: [
                -5: (blueWin: 0.031, redWin: 0.935, tie: 0.034),
                -4: (blueWin: 0.065, redWin: 0.88, tie: 0.056),
                -3: (blueWin: 0.12, redWin: 0.798, tie: 0.081),
                -2: (blueWin: 0.202, redWin: 0.691, tie: 0.107),
                -1: (blueWin: 0.309, redWin: 0.566, tie: 0.125),
                0: (blueWin: 0.434, redWin: 0.434, tie: 0.132),
                1: (blueWin: 0.566, redWin: 0.309, tie: 0.125),
                2: (blueWin: 0.691, redWin: 0.202, tie: 0.107),
                3: (blueWin: 0.798, redWin: 0.12, tie: 0.081),
                4: (blueWin: 0.88, redWin: 0.065, tie: 0.056),
                5: (blueWin: 0.935, redWin: 0.031, tie: 0.034),
            ],
            7: [
                -6: (blueWin: 0.01, redWin: 0.974, tie: 0.016),
                -5: (blueWin: 0.026, redWin: 0.943, tie: 0.031),
                -4: (blueWin: 0.057, redWin: 0.889, tie: 0.054),
                -3: (blueWin: 0.111, redWin: 0.808, tie: 0.081),
                -2: (blueWin: 0.192, redWin: 0.698, tie: 0.109),
                -1: (blueWin: 0.302, redWin: 0.569, tie: 0.13),
                0: (blueWin: 0.431, redWin: 0.431, tie: 0.137),
                1: (blueWin: 0.569, redWin: 0.302, tie: 0.13),
                2: (blueWin: 0.698, redWin: 0.192, tie: 0.109),
                3: (blueWin: 0.808, redWin: 0.111, tie: 0.081),
                4: (blueWin: 0.889, redWin: 0.057, tie: 0.054),
                5: (blueWin: 0.943, redWin: 0.026, tie: 0.031),
                6: (blueWin: 0.974, redWin: 0.01, tie: 0.016),
            ],
            8: [
                -7: (blueWin: 0.002, redWin: 0.993, tie: 0.005),
                -6: (blueWin: 0.007, redWin: 0.979, tie: 0.013),
                -5: (blueWin: 0.021, redWin: 0.951, tie: 0.028),
                -4: (blueWin: 0.049, redWin: 0.899, tie: 0.052),
                -3: (blueWin: 0.101, redWin: 0.818, tie: 0.081),
                -2: (blueWin: 0.182, redWin: 0.706, tie: 0.112),
                -1: (blueWin: 0.294, redWin: 0.572, tie: 0.135),
                0: (blueWin: 0.428, redWin: 0.428, tie: 0.143),
                1: (blueWin: 0.572, redWin: 0.294, tie: 0.135),
                2: (blueWin: 0.706, redWin: 0.182, tie: 0.112),
                3: (blueWin: 0.818, redWin: 0.101, tie: 0.081),
                4: (blueWin: 0.899, redWin: 0.049, tie: 0.052),
                5: (blueWin: 0.951, redWin: 0.021, tie: 0.028),
                6: (blueWin: 0.979, redWin: 0.007, tie: 0.013),
                7: (blueWin: 0.993, redWin: 0.002, tie: 0.005),
            ],
            9: [
                -8: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                -7: (blueWin: 0.001, redWin: 0.995, tie: 0.004),
                -6: (blueWin: 0.005, redWin: 0.984, tie: 0.011),
                -5: (blueWin: 0.016, redWin: 0.959, tie: 0.025),
                -4: (blueWin: 0.041, redWin: 0.91, tie: 0.049),
                -3: (blueWin: 0.09, redWin: 0.829, tie: 0.081),
                -2: (blueWin: 0.171, redWin: 0.715, tie: 0.114),
                -1: (blueWin: 0.285, redWin: 0.575, tie: 0.14),
                0: (blueWin: 0.425, redWin: 0.425, tie: 0.15),
                1: (blueWin: 0.575, redWin: 0.285, tie: 0.14),
                2: (blueWin: 0.715, redWin: 0.171, tie: 0.114),
                3: (blueWin: 0.829, redWin: 0.09, tie: 0.081),
                4: (blueWin: 0.91, redWin: 0.041, tie: 0.049),
                5: (blueWin: 0.959, redWin: 0.016, tie: 0.025),
                6: (blueWin: 0.984, redWin: 0.005, tie: 0.011),
                7: (blueWin: 0.995, redWin: 0.001, tie: 0.004),
                8: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
            ],
            10: [
                -9: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -8: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                -7: (blueWin: 0.001, redWin: 0.997, tie: 0.002),
                -6: (blueWin: 0.003, redWin: 0.989, tie: 0.008),
                -5: (blueWin: 0.011, redWin: 0.967, tie: 0.022),
                -4: (blueWin: 0.033, redWin: 0.921, tie: 0.046),
                -3: (blueWin: 0.079, redWin: 0.842, tie: 0.079),
                -2: (blueWin: 0.158, redWin: 0.725, tie: 0.117),
                -1: (blueWin: 0.275, redWin: 0.579, tie: 0.146),
                0: (blueWin: 0.421, redWin: 0.421, tie: 0.158),
                1: (blueWin: 0.579, redWin: 0.275, tie: 0.146),
                2: (blueWin: 0.725, redWin: 0.158, tie: 0.117),
                3: (blueWin: 0.842, redWin: 0.079, tie: 0.079),
                4: (blueWin: 0.921, redWin: 0.033, tie: 0.046),
                5: (blueWin: 0.967, redWin: 0.011, tie: 0.022),
                6: (blueWin: 0.989, redWin: 0.003, tie: 0.008),
                7: (blueWin: 0.997, redWin: 0.001, tie: 0.002),
                8: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
                9: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            11: [
                -8: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -7: (blueWin: 0.0, redWin: 0.998, tie: 0.001),
                -6: (blueWin: 0.002, redWin: 0.993, tie: 0.006),
                -5: (blueWin: 0.007, redWin: 0.975, tie: 0.018),
                -4: (blueWin: 0.025, redWin: 0.933, tie: 0.041),
                -3: (blueWin: 0.067, redWin: 0.856, tie: 0.077),
                -2: (blueWin: 0.144, redWin: 0.737, tie: 0.119),
                -1: (blueWin: 0.263, redWin: 0.583, tie: 0.154),
                0: (blueWin: 0.417, redWin: 0.417, tie: 0.167),
                1: (blueWin: 0.583, redWin: 0.263, tie: 0.154),
                2: (blueWin: 0.737, redWin: 0.144, tie: 0.119),
                3: (blueWin: 0.856, redWin: 0.067, tie: 0.077),
                4: (blueWin: 0.933, redWin: 0.025, tie: 0.041),
                5: (blueWin: 0.975, redWin: 0.007, tie: 0.018),
                6: (blueWin: 0.993, redWin: 0.002, tie: 0.006),
                7: (blueWin: 0.998, redWin: 0.0, tie: 0.001),
                8: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            12: [
                -7: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                -6: (blueWin: 0.001, redWin: 0.996, tie: 0.003),
                -5: (blueWin: 0.004, redWin: 0.983, tie: 0.013),
                -4: (blueWin: 0.017, redWin: 0.946, tie: 0.036),
                -3: (blueWin: 0.054, redWin: 0.872, tie: 0.074),
                -2: (blueWin: 0.128, redWin: 0.751, tie: 0.121),
                -1: (blueWin: 0.249, redWin: 0.589, tie: 0.162),
                0: (blueWin: 0.411, redWin: 0.411, tie: 0.178),
                1: (blueWin: 0.589, redWin: 0.249, tie: 0.162),
                2: (blueWin: 0.751, redWin: 0.128, tie: 0.121),
                3: (blueWin: 0.872, redWin: 0.054, tie: 0.074),
                4: (blueWin: 0.946, redWin: 0.017, tie: 0.036),
                5: (blueWin: 0.983, redWin: 0.004, tie: 0.013),
                6: (blueWin: 0.996, redWin: 0.001, tie: 0.003),
                7: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
            ],
            13: [
                -6: (blueWin: 0.0, redWin: 0.998, tie: 0.002),
                -5: (blueWin: 0.002, redWin: 0.99, tie: 0.009),
                -4: (blueWin: 0.01, redWin: 0.96, tie: 0.03),
                -3: (blueWin: 0.04, redWin: 0.891, tie: 0.069),
                -2: (blueWin: 0.109, redWin: 0.767, tie: 0.123),
                -1: (blueWin: 0.233, redWin: 0.596, tie: 0.171),
                0: (blueWin: 0.404, redWin: 0.404, tie: 0.191),
                1: (blueWin: 0.596, redWin: 0.233, tie: 0.171),
                2: (blueWin: 0.767, redWin: 0.109, tie: 0.123),
                3: (blueWin: 0.891, redWin: 0.04, tie: 0.069),
                4: (blueWin: 0.96, redWin: 0.01, tie: 0.03),
                5: (blueWin: 0.99, redWin: 0.002, tie: 0.009),
                6: (blueWin: 0.998, redWin: 0.0, tie: 0.002),
            ],
            14: [
                -5: (blueWin: 0.0, redWin: 0.995, tie: 0.005),
                -4: (blueWin: 0.005, redWin: 0.974, tie: 0.021),
                -3: (blueWin: 0.026, redWin: 0.911, tie: 0.063),
                -2: (blueWin: 0.089, redWin: 0.788, tie: 0.123),
                -1: (blueWin: 0.212, redWin: 0.604, tie: 0.184),
                0: (blueWin: 0.396, redWin: 0.396, tie: 0.207),
                1: (blueWin: 0.604, redWin: 0.212, tie: 0.184),
                2: (blueWin: 0.788, redWin: 0.089, tie: 0.123),
                3: (blueWin: 0.911, redWin: 0.026, tie: 0.063),
                4: (blueWin: 0.974, redWin: 0.005, tie: 0.021),
                5: (blueWin: 0.995, redWin: 0.0, tie: 0.005),
            ],
            15: [
                -4: (blueWin: 0.0, redWin: 0.987, tie: 0.013),
                -3: (blueWin: 0.013, redWin: 0.936, tie: 0.05),
                -2: (blueWin: 0.064, redWin: 0.812, tie: 0.124),
                -1: (blueWin: 0.188, redWin: 0.616, tie: 0.195),
                0: (blueWin: 0.384, redWin: 0.384, tie: 0.233),
                1: (blueWin: 0.616, redWin: 0.188, tie: 0.195),
                2: (blueWin: 0.812, redWin: 0.064, tie: 0.124),
                3: (blueWin: 0.936, redWin: 0.013, tie: 0.05),
                4: (blueWin: 0.987, redWin: 0.0, tie: 0.013),
            ],
            16: [
                -3: (blueWin: 0.0, redWin: 0.961, tie: 0.039),
                -2: (blueWin: 0.039, redWin: 0.85, tie: 0.111),
                -1: (blueWin: 0.15, redWin: 0.627, tie: 0.222),
                0: (blueWin: 0.373, redWin: 0.373, tie: 0.255),
                1: (blueWin: 0.627, redWin: 0.15, tie: 0.222),
                2: (blueWin: 0.85, redWin: 0.039, tie: 0.111),
                3: (blueWin: 0.961, redWin: 0.0, tie: 0.039),
            ],
            17: [
                -2: (blueWin: 0.0, redWin: 0.884, tie: 0.116),
                -1: (blueWin: 0.116, redWin: 0.667, tie: 0.218),
                0: (blueWin: 0.333, redWin: 0.333, tie: 0.334),
                1: (blueWin: 0.667, redWin: 0.116, tie: 0.218),
                2: (blueWin: 0.884, redWin: 0.0, tie: 0.116),
            ],
            18: [
                -1: (blueWin: 0.0, redWin: 0.66, tie: 0.34),
                0: (blueWin: 0.34, redWin: 0.34, tie: 0.32),
                1: (blueWin: 0.66, redWin: 0.0, tie: 0.34),
            ]
        ]
    ]
    
    static let twoManScrambleProbabilities: [Int: [Int: [Int: (blueWin: Double, redWin: Double, tie: Double)]]] = [
        9: [
            1: [
                0: (blueWin: 0.413, redWin: 0.413, tie: 0.173),
            ],
            2: [
                -1: (blueWin: 0.243, redWin: 0.592, tie: 0.165),
                0: (blueWin: 0.408, redWin: 0.408, tie: 0.183),
                1: (blueWin: 0.592, redWin: 0.243, tie: 0.165),
            ],
            3: [
                -2: (blueWin: 0.106, redWin: 0.772, tie: 0.123),
                -1: (blueWin: 0.228, redWin: 0.598, tie: 0.174),
                0: (blueWin: 0.402, redWin: 0.402, tie: 0.195),
                1: (blueWin: 0.598, redWin: 0.228, tie: 0.174),
                2: (blueWin: 0.772, redWin: 0.106, tie: 0.123),
            ],
            4: [
                -3: (blueWin: 0.027, redWin: 0.912, tie: 0.061),
                -2: (blueWin: 0.088, redWin: 0.789, tie: 0.123),
                -1: (blueWin: 0.211, redWin: 0.605, tie: 0.184),
                0: (blueWin: 0.395, redWin: 0.395, tie: 0.21),
                1: (blueWin: 0.605, redWin: 0.211, tie: 0.184),
                2: (blueWin: 0.789, redWin: 0.088, tie: 0.123),
                3: (blueWin: 0.912, redWin: 0.027, tie: 0.061),
            ],
            5: [
                -4: (blueWin: 0.002, redWin: 0.984, tie: 0.014),
                -3: (blueWin: 0.016, redWin: 0.932, tie: 0.052),
                -2: (blueWin: 0.068, redWin: 0.81, tie: 0.121),
                -1: (blueWin: 0.19, redWin: 0.614, tie: 0.196),
                0: (blueWin: 0.386, redWin: 0.386, tie: 0.229),
                1: (blueWin: 0.614, redWin: 0.19, tie: 0.196),
                2: (blueWin: 0.81, redWin: 0.068, tie: 0.121),
                3: (blueWin: 0.932, redWin: 0.016, tie: 0.052),
                4: (blueWin: 0.984, redWin: 0.002, tie: 0.014),
            ],
            6: [
                -4: (blueWin: 0.0, redWin: 0.993, tie: 0.007),
                -3: (blueWin: 0.007, redWin: 0.954, tie: 0.04),
                -2: (blueWin: 0.046, redWin: 0.837, tie: 0.117),
                -1: (blueWin: 0.163, redWin: 0.627, tie: 0.21),
                0: (blueWin: 0.373, redWin: 0.373, tie: 0.254),
                1: (blueWin: 0.627, redWin: 0.163, tie: 0.21),
                2: (blueWin: 0.837, redWin: 0.046, tie: 0.117),
                3: (blueWin: 0.954, redWin: 0.007, tie: 0.04),
                4: (blueWin: 0.993, redWin: 0.0, tie: 0.007),
            ],
            7: [
                -3: (blueWin: 0.0, redWin: 0.977, tie: 0.023),
                -2: (blueWin: 0.023, redWin: 0.872, tie: 0.105),
                -1: (blueWin: 0.128, redWin: 0.645, tie: 0.228),
                0: (blueWin: 0.355, redWin: 0.355, tie: 0.289),
                1: (blueWin: 0.645, redWin: 0.128, tie: 0.228),
                2: (blueWin: 0.872, redWin: 0.023, tie: 0.105),
                3: (blueWin: 0.977, redWin: 0.0, tie: 0.023),
            ],
            8: [
                -2: (blueWin: 0.0, redWin: 0.919, tie: 0.081),
                -1: (blueWin: 0.081, redWin: 0.674, tie: 0.245),
                0: (blueWin: 0.326, redWin: 0.326, tie: 0.347),
                1: (blueWin: 0.674, redWin: 0.081, tie: 0.245),
                2: (blueWin: 0.919, redWin: 0.0, tie: 0.081),
            ],
            9: [
                -1: (blueWin: 0.0, redWin: 0.715, tie: 0.285),
                0: (blueWin: 0.285, redWin: 0.285, tie: 0.43),
                1: (blueWin: 0.715, redWin: 0.0, tie: 0.285),
            ]
        ],
        18: [
            1: [
                0: (blueWin: 0.438, redWin: 0.438, tie: 0.123),
            ],
            2: [
                -1: (blueWin: 0.316, redWin: 0.563, tie: 0.121),
                0: (blueWin: 0.437, redWin: 0.437, tie: 0.127),
                1: (blueWin: 0.563, redWin: 0.316, tie: 0.121),
            ],
            3: [
                -2: (blueWin: 0.205, redWin: 0.69, tie: 0.106),
                -1: (blueWin: 0.31, redWin: 0.565, tie: 0.124),
                0: (blueWin: 0.435, redWin: 0.435, tie: 0.131),
                1: (blueWin: 0.565, redWin: 0.31, tie: 0.124),
                2: (blueWin: 0.69, redWin: 0.205, tie: 0.106),
            ],
            4: [
                -3: (blueWin: 0.116, redWin: 0.803, tie: 0.081),
                -2: (blueWin: 0.197, redWin: 0.695, tie: 0.108),
                -1: (blueWin: 0.305, redWin: 0.568, tie: 0.128),
                0: (blueWin: 0.432, redWin: 0.432, tie: 0.135),
                1: (blueWin: 0.568, redWin: 0.305, tie: 0.128),
                2: (blueWin: 0.695, redWin: 0.197, tie: 0.108),
                3: (blueWin: 0.803, redWin: 0.116, tie: 0.081),
            ],
            5: [
                -4: (blueWin: 0.055, redWin: 0.892, tie: 0.053),
                -3: (blueWin: 0.108, redWin: 0.811, tie: 0.081),
                -2: (blueWin: 0.189, redWin: 0.701, tie: 0.11),
                -1: (blueWin: 0.299, redWin: 0.57, tie: 0.132),
                0: (blueWin: 0.43, redWin: 0.43, tie: 0.14),
                1: (blueWin: 0.57, redWin: 0.299, tie: 0.132),
                2: (blueWin: 0.701, redWin: 0.189, tie: 0.11),
                3: (blueWin: 0.811, redWin: 0.108, tie: 0.081),
                4: (blueWin: 0.892, redWin: 0.055, tie: 0.053),
            ],
            6: [
                -5: (blueWin: 0.021, redWin: 0.952, tie: 0.028),
                -4: (blueWin: 0.048, redWin: 0.901, tie: 0.051),
                -3: (blueWin: 0.099, redWin: 0.82, tie: 0.081),
                -2: (blueWin: 0.18, redWin: 0.708, tie: 0.112),
                -1: (blueWin: 0.292, redWin: 0.572, tie: 0.136),
                0: (blueWin: 0.428, redWin: 0.428, tie: 0.145),
                1: (blueWin: 0.572, redWin: 0.292, tie: 0.136),
                2: (blueWin: 0.708, redWin: 0.18, tie: 0.112),
                3: (blueWin: 0.82, redWin: 0.099, tie: 0.081),
                4: (blueWin: 0.901, redWin: 0.048, tie: 0.051),
                5: (blueWin: 0.952, redWin: 0.021, tie: 0.028),
            ],
            7: [
                -6: (blueWin: 0.006, redWin: 0.983, tie: 0.011),
                -5: (blueWin: 0.017, redWin: 0.958, tie: 0.025),
                -4: (blueWin: 0.042, redWin: 0.91, tie: 0.049),
                -3: (blueWin: 0.09, redWin: 0.83, tie: 0.08),
                -2: (blueWin: 0.17, redWin: 0.716, tie: 0.114),
                -1: (blueWin: 0.284, redWin: 0.575, tie: 0.14),
                0: (blueWin: 0.425, redWin: 0.425, tie: 0.151),
                1: (blueWin: 0.575, redWin: 0.284, tie: 0.14),
                2: (blueWin: 0.716, redWin: 0.17, tie: 0.114),
                3: (blueWin: 0.83, redWin: 0.09, tie: 0.08),
                4: (blueWin: 0.91, redWin: 0.042, tie: 0.049),
                5: (blueWin: 0.958, redWin: 0.017, tie: 0.025),
                6: (blueWin: 0.983, redWin: 0.006, tie: 0.011),
            ],
            8: [
                -7: (blueWin: 0.001, redWin: 0.996, tie: 0.003),
                -6: (blueWin: 0.004, redWin: 0.987, tie: 0.009),
                -5: (blueWin: 0.013, redWin: 0.965, tie: 0.022),
                -4: (blueWin: 0.035, redWin: 0.919, tie: 0.046),
                -3: (blueWin: 0.081, redWin: 0.84, tie: 0.079),
                -2: (blueWin: 0.16, redWin: 0.724, tie: 0.116),
                -1: (blueWin: 0.276, redWin: 0.579, tie: 0.146),
                0: (blueWin: 0.421, redWin: 0.421, tie: 0.157),
                1: (blueWin: 0.579, redWin: 0.276, tie: 0.146),
                2: (blueWin: 0.724, redWin: 0.16, tie: 0.116),
                3: (blueWin: 0.84, redWin: 0.081, tie: 0.079),
                4: (blueWin: 0.919, redWin: 0.035, tie: 0.046),
                5: (blueWin: 0.965, redWin: 0.013, tie: 0.022),
                6: (blueWin: 0.987, redWin: 0.004, tie: 0.009),
                7: (blueWin: 0.996, redWin: 0.001, tie: 0.003),
            ],
            9: [
                -8: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -7: (blueWin: 0.0, redWin: 0.998, tie: 0.002),
                -6: (blueWin: 0.002, redWin: 0.991, tie: 0.007),
                -5: (blueWin: 0.009, redWin: 0.972, tie: 0.019),
                -4: (blueWin: 0.028, redWin: 0.929, tie: 0.042),
                -3: (blueWin: 0.071, redWin: 0.852, tie: 0.077),
                -2: (blueWin: 0.148, redWin: 0.734, tie: 0.118),
                -1: (blueWin: 0.266, redWin: 0.582, tie: 0.151),
                0: (blueWin: 0.418, redWin: 0.418, tie: 0.164),
                1: (blueWin: 0.582, redWin: 0.266, tie: 0.151),
                2: (blueWin: 0.734, redWin: 0.148, tie: 0.118),
                3: (blueWin: 0.852, redWin: 0.071, tie: 0.077),
                4: (blueWin: 0.929, redWin: 0.028, tie: 0.042),
                5: (blueWin: 0.972, redWin: 0.009, tie: 0.019),
                6: (blueWin: 0.991, redWin: 0.002, tie: 0.007),
                7: (blueWin: 0.998, redWin: 0.0, tie: 0.002),
                8: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            10: [
                -9: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -8: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -7: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                -6: (blueWin: 0.001, redWin: 0.994, tie: 0.005),
                -5: (blueWin: 0.006, redWin: 0.978, tie: 0.016),
                -4: (blueWin: 0.022, redWin: 0.94, tie: 0.038),
                -3: (blueWin: 0.06, redWin: 0.865, tie: 0.075),
                -2: (blueWin: 0.135, redWin: 0.745, tie: 0.12),
                -1: (blueWin: 0.255, redWin: 0.587, tie: 0.158),
                0: (blueWin: 0.413, redWin: 0.413, tie: 0.173),
                1: (blueWin: 0.587, redWin: 0.255, tie: 0.158),
                2: (blueWin: 0.745, redWin: 0.135, tie: 0.12),
                3: (blueWin: 0.865, redWin: 0.06, tie: 0.075),
                4: (blueWin: 0.94, redWin: 0.022, tie: 0.038),
                5: (blueWin: 0.978, redWin: 0.006, tie: 0.016),
                6: (blueWin: 0.994, redWin: 0.001, tie: 0.005),
                7: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
                8: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
                9: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            11: [
                -8: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -7: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                -6: (blueWin: 0.001, redWin: 0.996, tie: 0.003),
                -5: (blueWin: 0.004, redWin: 0.984, tie: 0.012),
                -4: (blueWin: 0.016, redWin: 0.951, tie: 0.034),
                -3: (blueWin: 0.049, redWin: 0.879, tie: 0.072),
                -2: (blueWin: 0.121, redWin: 0.757, tie: 0.122),
                -1: (blueWin: 0.243, redWin: 0.592, tie: 0.165),
                0: (blueWin: 0.408, redWin: 0.408, tie: 0.183),
                1: (blueWin: 0.592, redWin: 0.243, tie: 0.165),
                2: (blueWin: 0.757, redWin: 0.121, tie: 0.122),
                3: (blueWin: 0.879, redWin: 0.049, tie: 0.072),
                4: (blueWin: 0.951, redWin: 0.016, tie: 0.034),
                5: (blueWin: 0.984, redWin: 0.004, tie: 0.012),
                6: (blueWin: 0.996, redWin: 0.001, tie: 0.003),
                7: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
                8: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            12: [
                -7: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -6: (blueWin: 0.0, redWin: 0.998, tie: 0.002),
                -5: (blueWin: 0.002, redWin: 0.99, tie: 0.008),
                -4: (blueWin: 0.01, redWin: 0.962, tie: 0.028),
                -3: (blueWin: 0.038, redWin: 0.894, tie: 0.067),
                -2: (blueWin: 0.106, redWin: 0.772, tie: 0.123),
                -1: (blueWin: 0.228, redWin: 0.598, tie: 0.174),
                0: (blueWin: 0.402, redWin: 0.402, tie: 0.195),
                1: (blueWin: 0.598, redWin: 0.228, tie: 0.174),
                2: (blueWin: 0.772, redWin: 0.106, tie: 0.123),
                3: (blueWin: 0.894, redWin: 0.038, tie: 0.067),
                4: (blueWin: 0.962, redWin: 0.01, tie: 0.028),
                5: (blueWin: 0.99, redWin: 0.002, tie: 0.008),
                6: (blueWin: 0.998, redWin: 0.0, tie: 0.002),
                7: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            13: [
                -6: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                -5: (blueWin: 0.001, redWin: 0.995, tie: 0.005),
                -4: (blueWin: 0.005, redWin: 0.973, tie: 0.022),
                -3: (blueWin: 0.027, redWin: 0.912, tie: 0.061),
                -2: (blueWin: 0.088, redWin: 0.789, tie: 0.123),
                -1: (blueWin: 0.211, redWin: 0.605, tie: 0.184),
                0: (blueWin: 0.395, redWin: 0.395, tie: 0.21),
                1: (blueWin: 0.605, redWin: 0.211, tie: 0.184),
                2: (blueWin: 0.789, redWin: 0.088, tie: 0.123),
                3: (blueWin: 0.912, redWin: 0.027, tie: 0.061),
                4: (blueWin: 0.973, redWin: 0.005, tie: 0.022),
                5: (blueWin: 0.995, redWin: 0.001, tie: 0.005),
                6: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
            ],
            14: [
                -5: (blueWin: 0.0, redWin: 0.998, tie: 0.002),
                -4: (blueWin: 0.002, redWin: 0.984, tie: 0.014),
                -3: (blueWin: 0.016, redWin: 0.932, tie: 0.052),
                -2: (blueWin: 0.068, redWin: 0.81, tie: 0.121),
                -1: (blueWin: 0.19, redWin: 0.614, tie: 0.196),
                0: (blueWin: 0.386, redWin: 0.386, tie: 0.229),
                1: (blueWin: 0.614, redWin: 0.19, tie: 0.196),
                2: (blueWin: 0.81, redWin: 0.068, tie: 0.121),
                3: (blueWin: 0.932, redWin: 0.016, tie: 0.052),
                4: (blueWin: 0.984, redWin: 0.002, tie: 0.014),
                5: (blueWin: 0.998, redWin: 0.0, tie: 0.002),
            ],
            15: [
                -4: (blueWin: 0.0, redWin: 0.993, tie: 0.007),
                -3: (blueWin: 0.007, redWin: 0.954, tie: 0.04),
                -2: (blueWin: 0.046, redWin: 0.837, tie: 0.117),
                -1: (blueWin: 0.163, redWin: 0.627, tie: 0.21),
                0: (blueWin: 0.373, redWin: 0.373, tie: 0.254),
                1: (blueWin: 0.627, redWin: 0.163, tie: 0.21),
                2: (blueWin: 0.837, redWin: 0.046, tie: 0.117),
                3: (blueWin: 0.954, redWin: 0.007, tie: 0.04),
                4: (blueWin: 0.993, redWin: 0.0, tie: 0.007),
            ],
            16: [
                -3: (blueWin: 0.0, redWin: 0.977, tie: 0.023),
                -2: (blueWin: 0.023, redWin: 0.872, tie: 0.105),
                -1: (blueWin: 0.128, redWin: 0.645, tie: 0.228),
                0: (blueWin: 0.355, redWin: 0.355, tie: 0.289),
                1: (blueWin: 0.645, redWin: 0.128, tie: 0.228),
                2: (blueWin: 0.872, redWin: 0.023, tie: 0.105),
                3: (blueWin: 0.977, redWin: 0.0, tie: 0.023),
            ],
            17: [
                -2: (blueWin: 0.0, redWin: 0.919, tie: 0.081),
                -1: (blueWin: 0.081, redWin: 0.674, tie: 0.245),
                0: (blueWin: 0.326, redWin: 0.326, tie: 0.347),
                1: (blueWin: 0.674, redWin: 0.081, tie: 0.245),
                2: (blueWin: 0.919, redWin: 0.0, tie: 0.081),
            ],
            18: [
                -1: (blueWin: 0.0, redWin: 0.715, tie: 0.285),
                0: (blueWin: 0.285, redWin: 0.285, tie: 0.43),
                1: (blueWin: 0.715, redWin: 0.0, tie: 0.285),
            ]
        ]
    ]
    
    static let shambleProbabilities: [Int: [Int: [Int: (blueWin: Double, redWin: Double, tie: Double)]]] = [
        9: [
            1: [
                0: (blueWin: 0.415, redWin: 0.415, tie: 0.17),
            ],
            2: [
                -1: (blueWin: 0.247, redWin: 0.59, tie: 0.163),
                0: (blueWin: 0.41, redWin: 0.41, tie: 0.18),
                1: (blueWin: 0.59, redWin: 0.247, tie: 0.163),
            ],
            3: [
                -2: (blueWin: 0.11, redWin: 0.768, tie: 0.123),
                -1: (blueWin: 0.232, redWin: 0.596, tie: 0.172),
                0: (blueWin: 0.404, redWin: 0.404, tie: 0.192),
                1: (blueWin: 0.596, redWin: 0.232, tie: 0.172),
                2: (blueWin: 0.768, redWin: 0.11, tie: 0.123),
            ],
            4: [
                -3: (blueWin: 0.029, redWin: 0.908, tie: 0.063),
                -2: (blueWin: 0.092, redWin: 0.785, tie: 0.123),
                -1: (blueWin: 0.215, redWin: 0.603, tie: 0.182),
                0: (blueWin: 0.397, redWin: 0.397, tie: 0.206),
                1: (blueWin: 0.603, redWin: 0.215, tie: 0.182),
                2: (blueWin: 0.785, redWin: 0.092, tie: 0.123),
                3: (blueWin: 0.908, redWin: 0.029, tie: 0.063),
            ],
            5: [
                -4: (blueWin: 0.002, redWin: 0.982, tie: 0.016),
                -3: (blueWin: 0.018, redWin: 0.928, tie: 0.054),
                -2: (blueWin: 0.072, redWin: 0.806, tie: 0.122),
                -1: (blueWin: 0.194, redWin: 0.612, tie: 0.193),
                0: (blueWin: 0.388, redWin: 0.388, tie: 0.225),
                1: (blueWin: 0.612, redWin: 0.194, tie: 0.193),
                2: (blueWin: 0.806, redWin: 0.072, tie: 0.122),
                3: (blueWin: 0.928, redWin: 0.018, tie: 0.054),
                4: (blueWin: 0.982, redWin: 0.002, tie: 0.016),
            ],
            6: [
                -4: (blueWin: 0.0, redWin: 0.992, tie: 0.008),
                -3: (blueWin: 0.008, redWin: 0.95, tie: 0.042),
                -2: (blueWin: 0.05, redWin: 0.832, tie: 0.118),
                -1: (blueWin: 0.168, redWin: 0.625, tie: 0.208),
                0: (blueWin: 0.375, redWin: 0.375, tie: 0.249),
                1: (blueWin: 0.625, redWin: 0.168, tie: 0.208),
                2: (blueWin: 0.832, redWin: 0.05, tie: 0.118),
                3: (blueWin: 0.95, redWin: 0.008, tie: 0.042),
                4: (blueWin: 0.992, redWin: 0.0, tie: 0.008),
            ],
            7: [
                -3: (blueWin: 0.0, redWin: 0.974, tie: 0.026),
                -2: (blueWin: 0.026, redWin: 0.867, tie: 0.107),
                -1: (blueWin: 0.133, redWin: 0.642, tie: 0.226),
                0: (blueWin: 0.358, redWin: 0.358, tie: 0.283),
                1: (blueWin: 0.642, redWin: 0.133, tie: 0.226),
                2: (blueWin: 0.867, redWin: 0.026, tie: 0.107),
                3: (blueWin: 0.974, redWin: 0.0, tie: 0.026),
            ],
            8: [
                -2: (blueWin: 0.0, redWin: 0.913, tie: 0.087),
                -1: (blueWin: 0.087, redWin: 0.671, tie: 0.242),
                0: (blueWin: 0.329, redWin: 0.329, tie: 0.342),
                1: (blueWin: 0.671, redWin: 0.087, tie: 0.242),
                2: (blueWin: 0.913, redWin: 0.0, tie: 0.087),
            ],
            9: [
                -1: (blueWin: 0.0, redWin: 0.705, tie: 0.295),
                0: (blueWin: 0.295, redWin: 0.295, tie: 0.41),
                1: (blueWin: 0.705, redWin: 0.0, tie: 0.295),
            ]
        ],
        18: [
            1: [
                0: (blueWin: 0.439, redWin: 0.439, tie: 0.121),
            ],
            2: [
                -1: (blueWin: 0.319, redWin: 0.562, tie: 0.119),
                0: (blueWin: 0.438, redWin: 0.438, tie: 0.125),
                1: (blueWin: 0.562, redWin: 0.319, tie: 0.119),
            ],
            3: [
                -2: (blueWin: 0.209, redWin: 0.686, tie: 0.105),
                -1: (blueWin: 0.314, redWin: 0.564, tie: 0.122),
                0: (blueWin: 0.436, redWin: 0.436, tie: 0.129),
                1: (blueWin: 0.564, redWin: 0.314, tie: 0.122),
                2: (blueWin: 0.686, redWin: 0.209, tie: 0.105),
            ],
            4: [
                -3: (blueWin: 0.12, redWin: 0.799, tie: 0.081),
                -2: (blueWin: 0.201, redWin: 0.692, tie: 0.107),
                -1: (blueWin: 0.308, redWin: 0.566, tie: 0.126),
                0: (blueWin: 0.434, redWin: 0.434, tie: 0.133),
                1: (blueWin: 0.566, redWin: 0.308, tie: 0.126),
                2: (blueWin: 0.692, redWin: 0.201, tie: 0.107),
                3: (blueWin: 0.799, redWin: 0.12, tie: 0.081),
            ],
            5: [
                -4: (blueWin: 0.058, redWin: 0.888, tie: 0.054),
                -3: (blueWin: 0.112, redWin: 0.807, tie: 0.081),
                -2: (blueWin: 0.193, redWin: 0.698, tie: 0.109),
                -1: (blueWin: 0.302, redWin: 0.569, tie: 0.129),
                0: (blueWin: 0.431, redWin: 0.431, tie: 0.137),
                1: (blueWin: 0.569, redWin: 0.302, tie: 0.129),
                2: (blueWin: 0.698, redWin: 0.193, tie: 0.109),
                3: (blueWin: 0.807, redWin: 0.112, tie: 0.081),
                4: (blueWin: 0.888, redWin: 0.058, tie: 0.054),
            ],
            6: [
                -5: (blueWin: 0.022, redWin: 0.949, tie: 0.029),
                -4: (blueWin: 0.051, redWin: 0.897, tie: 0.052),
                -3: (blueWin: 0.103, redWin: 0.816, tie: 0.081),
                -2: (blueWin: 0.184, redWin: 0.705, tie: 0.111),
                -1: (blueWin: 0.295, redWin: 0.571, tie: 0.134),
                0: (blueWin: 0.429, redWin: 0.429, tie: 0.142),
                1: (blueWin: 0.571, redWin: 0.295, tie: 0.134),
                2: (blueWin: 0.705, redWin: 0.184, tie: 0.111),
                3: (blueWin: 0.816, redWin: 0.103, tie: 0.081),
                4: (blueWin: 0.897, redWin: 0.051, tie: 0.052),
                5: (blueWin: 0.949, redWin: 0.022, tie: 0.029),
            ],
            7: [
                -6: (blueWin: 0.006, redWin: 0.982, tie: 0.012),
                -5: (blueWin: 0.018, redWin: 0.955, tie: 0.026),
                -4: (blueWin: 0.045, redWin: 0.906, tie: 0.05),
                -3: (blueWin: 0.094, redWin: 0.825, tie: 0.08),
                -2: (blueWin: 0.175, redWin: 0.712, tie: 0.113),
                -1: (blueWin: 0.288, redWin: 0.574, tie: 0.138),
                0: (blueWin: 0.426, redWin: 0.426, tie: 0.148),
                1: (blueWin: 0.574, redWin: 0.288, tie: 0.138),
                2: (blueWin: 0.712, redWin: 0.175, tie: 0.113),
                3: (blueWin: 0.825, redWin: 0.094, tie: 0.08),
                4: (blueWin: 0.906, redWin: 0.045, tie: 0.05),
                5: (blueWin: 0.955, redWin: 0.018, tie: 0.026),
                6: (blueWin: 0.982, redWin: 0.006, tie: 0.012),
            ],
            8: [
                -7: (blueWin: 0.001, redWin: 0.996, tie: 0.003),
                -6: (blueWin: 0.004, redWin: 0.986, tie: 0.01),
                -5: (blueWin: 0.014, redWin: 0.962, tie: 0.023),
                -4: (blueWin: 0.038, redWin: 0.915, tie: 0.047),
                -3: (blueWin: 0.085, redWin: 0.836, tie: 0.08),
                -2: (blueWin: 0.164, redWin: 0.721, tie: 0.115),
                -1: (blueWin: 0.279, redWin: 0.577, tie: 0.143),
                0: (blueWin: 0.423, redWin: 0.423, tie: 0.154),
                1: (blueWin: 0.577, redWin: 0.279, tie: 0.143),
                2: (blueWin: 0.721, redWin: 0.164, tie: 0.115),
                3: (blueWin: 0.836, redWin: 0.085, tie: 0.08),
                4: (blueWin: 0.915, redWin: 0.038, tie: 0.047),
                5: (blueWin: 0.962, redWin: 0.014, tie: 0.023),
                6: (blueWin: 0.986, redWin: 0.004, tie: 0.01),
                7: (blueWin: 0.996, redWin: 0.001, tie: 0.003),
            ],
            9: [
                -8: (blueWin: 0.0, redWin: 0.999, tie: 0.0),
                -7: (blueWin: 0.001, redWin: 0.997, tie: 0.002),
                -6: (blueWin: 0.003, redWin: 0.99, tie: 0.008),
                -5: (blueWin: 0.01, redWin: 0.969, tie: 0.02),
                -4: (blueWin: 0.031, redWin: 0.926, tie: 0.044),
                -3: (blueWin: 0.074, redWin: 0.847, tie: 0.078),
                -2: (blueWin: 0.153, redWin: 0.73, tie: 0.117),
                -1: (blueWin: 0.27, redWin: 0.581, tie: 0.149),
                0: (blueWin: 0.419, redWin: 0.419, tie: 0.162),
                1: (blueWin: 0.581, redWin: 0.27, tie: 0.149),
                2: (blueWin: 0.73, redWin: 0.153, tie: 0.117),
                3: (blueWin: 0.847, redWin: 0.074, tie: 0.078),
                4: (blueWin: 0.926, redWin: 0.031, tie: 0.044),
                5: (blueWin: 0.969, redWin: 0.01, tie: 0.02),
                6: (blueWin: 0.99, redWin: 0.003, tie: 0.008),
                7: (blueWin: 0.997, redWin: 0.001, tie: 0.002),
                8: (blueWin: 0.999, redWin: 0.0, tie: 0.0),
            ],
            10: [
                -9: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -8: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -7: (blueWin: 0.0, redWin: 0.998, tie: 0.001),
                -6: (blueWin: 0.002, redWin: 0.993, tie: 0.006),
                -5: (blueWin: 0.007, redWin: 0.976, tie: 0.017),
                -4: (blueWin: 0.024, redWin: 0.936, tie: 0.04),
                -3: (blueWin: 0.064, redWin: 0.86, tie: 0.076),
                -2: (blueWin: 0.14, redWin: 0.741, tie: 0.119),
                -1: (blueWin: 0.259, redWin: 0.585, tie: 0.156),
                0: (blueWin: 0.415, redWin: 0.415, tie: 0.17),
                1: (blueWin: 0.585, redWin: 0.259, tie: 0.156),
                2: (blueWin: 0.741, redWin: 0.14, tie: 0.119),
                3: (blueWin: 0.86, redWin: 0.064, tie: 0.076),
                4: (blueWin: 0.936, redWin: 0.024, tie: 0.04),
                5: (blueWin: 0.976, redWin: 0.007, tie: 0.017),
                6: (blueWin: 0.993, redWin: 0.002, tie: 0.006),
                7: (blueWin: 0.998, redWin: 0.0, tie: 0.001),
                8: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
                9: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            11: [
                -8: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -7: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                -6: (blueWin: 0.001, redWin: 0.996, tie: 0.004),
                -5: (blueWin: 0.004, redWin: 0.983, tie: 0.013),
                -4: (blueWin: 0.017, redWin: 0.947, tie: 0.035),
                -3: (blueWin: 0.053, redWin: 0.874, tie: 0.073),
                -2: (blueWin: 0.126, redWin: 0.753, tie: 0.121),
                -1: (blueWin: 0.247, redWin: 0.59, tie: 0.163),
                0: (blueWin: 0.41, redWin: 0.41, tie: 0.18),
                1: (blueWin: 0.59, redWin: 0.247, tie: 0.163),
                2: (blueWin: 0.753, redWin: 0.126, tie: 0.121),
                3: (blueWin: 0.874, redWin: 0.053, tie: 0.073),
                4: (blueWin: 0.947, redWin: 0.017, tie: 0.035),
                5: (blueWin: 0.983, redWin: 0.004, tie: 0.013),
                6: (blueWin: 0.996, redWin: 0.001, tie: 0.004),
                7: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
                8: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            12: [
                -7: (blueWin: 0.0, redWin: 1.0, tie: 0.0),
                -6: (blueWin: 0.0, redWin: 0.998, tie: 0.002),
                -5: (blueWin: 0.002, redWin: 0.989, tie: 0.009),
                -4: (blueWin: 0.011, redWin: 0.959, tie: 0.03),
                -3: (blueWin: 0.041, redWin: 0.89, tie: 0.069),
                -2: (blueWin: 0.11, redWin: 0.768, tie: 0.123),
                -1: (blueWin: 0.232, redWin: 0.596, tie: 0.172),
                0: (blueWin: 0.404, redWin: 0.404, tie: 0.192),
                1: (blueWin: 0.596, redWin: 0.232, tie: 0.172),
                2: (blueWin: 0.768, redWin: 0.11, tie: 0.123),
                3: (blueWin: 0.89, redWin: 0.041, tie: 0.069),
                4: (blueWin: 0.959, redWin: 0.011, tie: 0.03),
                5: (blueWin: 0.989, redWin: 0.002, tie: 0.009),
                6: (blueWin: 0.998, redWin: 0.0, tie: 0.002),
                7: (blueWin: 1.0, redWin: 0.0, tie: 0.0),
            ],
            13: [
                -6: (blueWin: 0.0, redWin: 0.999, tie: 0.001),
                -5: (blueWin: 0.001, redWin: 0.994, tie: 0.005),
                -4: (blueWin: 0.006, redWin: 0.971, tie: 0.023),
                -3: (blueWin: 0.029, redWin: 0.908, tie: 0.063),
                -2: (blueWin: 0.092, redWin: 0.785, tie: 0.123),
                -1: (blueWin: 0.215, redWin: 0.603, tie: 0.182),
                0: (blueWin: 0.397, redWin: 0.397, tie: 0.206),
                1: (blueWin: 0.603, redWin: 0.215, tie: 0.182),
                2: (blueWin: 0.785, redWin: 0.092, tie: 0.123),
                3: (blueWin: 0.908, redWin: 0.029, tie: 0.063),
                4: (blueWin: 0.971, redWin: 0.006, tie: 0.023),
                5: (blueWin: 0.994, redWin: 0.001, tie: 0.005),
                6: (blueWin: 0.999, redWin: 0.0, tie: 0.001),
            ],
            14: [
                -5: (blueWin: 0.0, redWin: 0.998, tie: 0.002),
                -4: (blueWin: 0.002, redWin: 0.982, tie: 0.016),
                -3: (blueWin: 0.018, redWin: 0.928, tie: 0.054),
                -2: (blueWin: 0.072, redWin: 0.806, tie: 0.122),
                -1: (blueWin: 0.194, redWin: 0.612, tie: 0.193),
                0: (blueWin: 0.388, redWin: 0.388, tie: 0.225),
                1: (blueWin: 0.612, redWin: 0.194, tie: 0.193),
                2: (blueWin: 0.806, redWin: 0.072, tie: 0.122),
                3: (blueWin: 0.928, redWin: 0.018, tie: 0.054),
                4: (blueWin: 0.982, redWin: 0.002, tie: 0.016),
                5: (blueWin: 0.998, redWin: 0.0, tie: 0.002),
            ],
            15: [
                -4: (blueWin: 0.0, redWin: 0.992, tie: 0.008),
                -3: (blueWin: 0.008, redWin: 0.95, tie: 0.042),
                -2: (blueWin: 0.05, redWin: 0.832, tie: 0.118),
                -1: (blueWin: 0.168, redWin: 0.625, tie: 0.208),
                0: (blueWin: 0.375, redWin: 0.375, tie: 0.249),
                1: (blueWin: 0.625, redWin: 0.168, tie: 0.208),
                2: (blueWin: 0.832, redWin: 0.05, tie: 0.118),
                3: (blueWin: 0.95, redWin: 0.008, tie: 0.042),
                4: (blueWin: 0.992, redWin: 0.0, tie: 0.008),
            ],
            16: [
                -3: (blueWin: 0.0, redWin: 0.974, tie: 0.026),
                -2: (blueWin: 0.026, redWin: 0.867, tie: 0.107),
                -1: (blueWin: 0.133, redWin: 0.642, tie: 0.226),
                0: (blueWin: 0.358, redWin: 0.358, tie: 0.283),
                1: (blueWin: 0.642, redWin: 0.133, tie: 0.226),
                2: (blueWin: 0.867, redWin: 0.026, tie: 0.107),
                3: (blueWin: 0.974, redWin: 0.0, tie: 0.026),
            ],
            17: [
                -2: (blueWin: 0.0, redWin: 0.913, tie: 0.087),
                -1: (blueWin: 0.087, redWin: 0.671, tie: 0.242),
                0: (blueWin: 0.329, redWin: 0.329, tie: 0.342),
                1: (blueWin: 0.671, redWin: 0.087, tie: 0.242),
                2: (blueWin: 0.913, redWin: 0.0, tie: 0.087),
            ],
            18: [
                -1: (blueWin: 0.0, redWin: 0.705, tie: 0.295),
                0: (blueWin: 0.295, redWin: 0.295, tie: 0.41),
                1: (blueWin: 0.705, redWin: 0.0, tie: 0.295),
            ]
        ]
    ]
    
    
    // Combine all probabilities into a single dictionary
        static var matchProbabilities: [String: [Int: [Int: [Int: (blueWin: Double, redWin: Double, tie: Double)]]]] {
            return [
                "Alternate Shot": alternateShotProbabilities,
                "Best Ball": bestBallProbabilities,
                "Singles": singlesProbabilities,
                "Two Man Scramble": twoManScrambleProbabilities,
                "Shamble": shambleProbabilities
                // Add other formats here
            ]
        }
    
    
    fileprivate var matches: [Match]
    fileprivate var name: String
    fileprivate var numOfRounds: Int
    fileprivate var currentRound: Int
    //fileprivate var matchLength: Int
    fileprivate var drinkCartAvailable: Bool
    fileprivate var drinkCartNumber: String?
    fileprivate var players: [Player]
    fileprivate var courses: [Course]
    fileprivate var roundCourses: [(round: Int, course: String)]
    fileprivate var maxhandicap: Int
    fileprivate var commishPassword: String
    fileprivate var owner: String
    //fileprivate var tournamentCKRecord: CKRecord?
    
    init() {
        self.matches = [Match]()
        self.name = String()
        self.numOfRounds = Int()
        self.currentRound = Int()
        //self.matchLength = Int()
        self.drinkCartAvailable = false
        self.players = [Player]()
        self.courses = [Course]()
        self.roundCourses = [(round: Int, course: String)]()
        self.maxhandicap = Int()
        self.commishPassword = String()
        self.owner = String()
    }
    
    init(matches: [Match], name: String, numOfRounds: Int, currentRound: Int, /*matchLength: Int,*/ drinkCartAvailable: Bool, playersInit: [Player], roundCourses: [(round: Int, course: String)], maxhandicap: Int, commishPassword: String) {
        self.matches = matches
        self.name = name
        self.numOfRounds = numOfRounds
        self.currentRound = currentRound
        //self.matchLength = matchLength
        self.drinkCartAvailable = drinkCartAvailable
        self.players = playersInit
        self.courses = [Course]()
        self.roundCourses = roundCourses
        self.maxhandicap = maxhandicap
        self.commishPassword = commishPassword
        self.owner = String()
    }
    
    init(name: String, password: String, owner: String) {
        self.matches = [Match]()
        self.name = name
        self.numOfRounds = 4
        self.currentRound = 1
        //self.matchLength = 9
        self.drinkCartAvailable = false
        self.drinkCartNumber = "9999999999"
        self.players = [Player]()
        self.courses = [Course]()
        self.roundCourses = [(round: Int, course: String)]()
        self.maxhandicap = 30
        self.commishPassword = password
        self.owner = owner
    }
    
    func getProbability(forFormat: String, matchLength: Int, startingHole: Int, hole: Int, scoreDifference: Int) -> (blueWin: Double, redWin: Double, tie: Double)? {
        return Tournament.matchProbabilities[forFormat]?[matchLength]?[(hole - startingHole + 1)]?[scoreDifference]
        }
    
    func getMatchWinProbabilities(forFormat: String, matchLength: Int, startingHole: Int, scoreDiffs: [Int]) -> [(hole: Int, blueWinProbability: Double, redWinProbability: Double, tieProbability: Double)] {
        
        var probabilities: [(hole: Int, blueWinProbability: Double, redWinProbability: Double, tieProbability: Double)] = []
        
        if scoreDiffs.count > 0 {
            for hole in startingHole...(startingHole + scoreDiffs.count - 1) {
                if let probability = getProbability(forFormat: forFormat, matchLength: matchLength, startingHole: startingHole, hole: hole, scoreDifference: scoreDiffs[hole-startingHole]) {
                    probabilities.append((hole,probability.blueWin,probability.redWin,probability.tie))
                }
            }
        }
        else {
            if let probability = getProbability(forFormat: forFormat, matchLength: matchLength, startingHole: 1,hole: 1, scoreDifference: 0) {
                probabilities.append((startingHole,probability.blueWin,probability.redWin,probability.tie))
            }
        }
        
        return probabilities
    }
    
    func getCommissionerPassword() -> String {
        return commishPassword
    }
    
    func setCommissionerPassword(_ newPassword: String) {
        self.commishPassword = newPassword
    }
    
    func getNumberOfMatches() -> Int {
        return matches.count
    }
    
    /*func setMatchLength(_ length: Int) {
        self.matchLength = length
    }*/
    
    func setNumberOfRounds(_ rounds: Int) {
        self.numOfRounds = rounds
    }
    func getCourseForRound(round: Int) -> String? {
        for eachRound in roundCourses {
            if eachRound.round == round {
                return eachRound.course
            }
        }
        return nil
    }
    
    func getCourseNames() -> [String] {
        var names = [String]()
        for course in courses {
            names.append(course.getName())
        }
        return names
    }
    
    func getTeesForCourse(_ courseName: String) -> [String] {
        var tees = [String]()
        
        for course in self.courses {
            if course.getName() == courseName {
                tees.append(course.getTees())
            }
        }
        
        return tees
    }
    func setDrinkCart(_ on: Bool) {
        self.drinkCartAvailable = on
    }
    func setDrinkCartNumber(_ number: String) {
        self.drinkCartNumber = number
    }
    
    func getDrinkCartNumber() -> String? {
        return drinkCartNumber
    }
    func getMaxHandicap() -> Int {
        return maxhandicap
    }
    func getOwner() -> String {
        return owner
    }
    
    func setMaxHandicap(_ handicap: Int) {
        self.maxhandicap = handicap
    }
    
    func setPlayers(_ setPlayers:[Player]) {
        players = setPlayers
    }
    func addPlayer(_ playerToAdd: Player) {
        var add = true
        for p in players {
            if playerToAdd == p {
                add = false
            }
        }
        
        if add { players.append(playerToAdd)}
    }
    func getPlayers() -> [Player] {
        return players
    }
    
    func getPlayerWithName(_ name: String) -> Player? {
        
        for player in players {
            if player.getName() == name {
                return player
            }
        }
        return nil
    }
    
    func getBluePlayerNames() -> [String] {
        
        var bluePlayerNames = [String]()
        var tournamentPlayers = players
        
        tournamentPlayers.sort(by: { $0.getHandicap() < $1.getHandicap() })
        
        for player in tournamentPlayers {
            if player.getTeam() == "Blue" {
                bluePlayerNames.append(player.getName())
            }
        }
        
        return bluePlayerNames
    }
    
    func getRedPlayerNames() -> [String] {
        
        var redPlayerNames = [String]()
        var tournamentPlayers = players
        
        tournamentPlayers.sort(by: { $0.getHandicap() < $1.getHandicap() })
        
        for player in tournamentPlayers {
            if player.getTeam() == "Red" {
                redPlayerNames.append(player.getName())
            }
        }
        
        return redPlayerNames
    }
    
    func getMatches() -> [Match] {
        return matches
    }
    func deleteMatches() {
        
        matches = [Match]()
        
        for player in players {
            player.deleteHoleResults()
        }
    }
    
    func deletePlayer(_ player: Player) -> Bool {
        
        if matches.count != 0 {
            for match in matches {
                if match.blueTeamPlayerOne() == player || match.redTeamPlayerOne() == player {
                    return false
                }
                else {
                    if match.getFormat() == "Doubles" {
                        if match.blueTeamPlayerTwo()! == player || match.redTeamPlayerTwo()! == player {
                            return false
                        }
                    }
                    
                }
            }
            for i in 0...(players.count-1) {
                if players[i] == player {
                    players.remove(at: i)
                    return true
                }
            }
        }
        else {
            for i in 0...(players.count-1) {
                if players[i] == player {
                    players.remove(at: i)
                    return true
                }
            }
            return false
        }
        return false
    }
    
    func deleteMatch(_ match: Match) -> Bool {
        
        if (match.getMatchLength() == 9 && (match.getCurrentHole() != 1 && match.getCurrentHole() != 10)) || (match.getMatchLength() == 18 && match.getCurrentHole() > 1){
            return false
        }
        
        for i in 0...(matches.count-1) {
            if matches[i] == match {
                matches.remove(at: i)
                return true
            }
        }
        return false
    }
    
    func getName() -> String {
        return name
    }
    
    func getNumberOfRounds() -> Int {
        return numOfRounds
    }
    
    func getCurrentRound() -> Int {
        return currentRound
    }
    
    /*func getMatchLength() -> Int {
        return matchLength
    }*/
    
    func appendPlayer(player: Player) {
        players.append(player)
    }
    func appendMatch(match: Match) {
        matches.append(match)
    }
    
    func matchesStarted() -> Bool {
        for eachMatch in matches {
            if eachMatch.getCurrentHole() > 1 {
                return true
            }
        }
        return false
    }
    
    func playerAlreadyInMatchInRound(playerName: String, round: Int) -> Bool {
        let matches = self.getRoundMatches(round)
        
        for match in matches {
            if match.getFormat() == "Singles" {
                if match.blueTeamPlayerOne().getName() == playerName || match.redTeamPlayerOne().getName() == playerName {
                    return true
                }
            }
            else if match.getFormat() == "Four Man Scramble" {
                if match.blueTeamPlayerOne().getName() == playerName || match.redTeamPlayerOne().getName() == playerName || match.blueTeamPlayerTwo()?.getName() == playerName || match.redTeamPlayerTwo()?.getName() == playerName ||
                    match.blueTeamPlayerThree()?.getName() == playerName || match.redTeamPlayerThree()?.getName() == playerName || match.blueTeamPlayerFour()?.getName() == playerName || match.redTeamPlayerFour()?.getName() == playerName{
                    return true
                }
            }
            else {
                if match.blueTeamPlayerOne().getName() == playerName || match.redTeamPlayerOne().getName() == playerName || match.blueTeamPlayerTwo()?.getName() == playerName || match.redTeamPlayerTwo()?.getName() == playerName {
                    return true
                }
            }
        }
        
        return false
    }
    
    func getCurrentMatch(_ player: Player) -> Match? {
        
        var playerMatches = self.getPlayerMatches(player)
        
        playerMatches.sort(by: { $0.getRound() < $1.getRound() })
        
        for eachMatch in playerMatches {
            if !eachMatch.isCompleted() {
                return eachMatch
            }
        }
        
        return nil
    }
    
    func getPlayerMatches(_ player: Player) -> [Match] {
        var playerMatches = [Match]()
        
        for eachMatch in self.matches {
            if eachMatch.getFormat() == "Singles" {
                if eachMatch.blueTeamPlayerOne().getName() == player.getName() || eachMatch.redTeamPlayerOne().getName() == player.getName() {
                    playerMatches.append(eachMatch)
                }
            }
            else if eachMatch.getFormat() == "Four Man Scramble" {
                if eachMatch.blueTeamPlayerOne().getName() == player.getName() || eachMatch.redTeamPlayerOne().getName() == player.getName() || eachMatch.blueTeamPlayerTwo()!.getName() == player.getName() || eachMatch.redTeamPlayerTwo()!.getName() == player.getName() ||
                    eachMatch.blueTeamPlayerThree()!.getName() == player.getName() || eachMatch.redTeamPlayerThree()!.getName() == player.getName() || eachMatch.blueTeamPlayerFour()!.getName() == player.getName() || eachMatch.redTeamPlayerFour()!.getName() == player.getName() {
                    playerMatches.append(eachMatch)
                }
            }
            else {
                if eachMatch.blueTeamPlayerOne().getName() == player.getName() || eachMatch.redTeamPlayerOne().getName() == player.getName() || eachMatch.blueTeamPlayerTwo()!.getName() == player.getName() || eachMatch.redTeamPlayerTwo()!.getName() == player.getName() {
                    playerMatches.append(eachMatch)
                }
            }
        }
        
        return playerMatches
    }
    
    func getPlayerLastRound(_ player: Player) -> Int {
        var maxRound = 100
        for m in getMatchesSorted() {
            if (m.blueTeamPlayerOne() == player || m.redTeamPlayerOne() == player) {
                if m.getRound() < maxRound  && !m.isCompleted() {
                    maxRound = m.getRound()
                }
            }
        }
        
        return maxRound
    }
    
    func getSinglesGroupMatches(_ player: Player, round: Int) -> [Match] {
        var group = Int()
        for m in getMatchesSorted() {
            if (m.blueTeamPlayerOne() == player || m.redTeamPlayerOne() == player) && (m.getRound() == round) {
                group = m.getGroup()
            }
        }
        
        var groupMatches = [Match]()
        
        for m in getMatchesSorted() {
            if (m.getGroup() == group) && (m.getRound() == round) {
                groupMatches.append(m)
            }
        }
        
        
        
        return groupMatches
    }
    
    
    func getCourseRounds() -> [(round: Int,course: String)] {
        return self.roundCourses
    }
    func getRoundMatches(_ round: Int) -> [Match] {
        var roundMatches = [Match]()
        
        for m in matches {
            if m.getRound() == round {
                roundMatches.append(m)
            }
        }
        
        roundMatches.sort(by: { $0.getGroup() < $1.getGroup() })
        
        return roundMatches
    }
    
    func getMatchesSorted() -> [Match] {
        
        var sortedMatches = self.matches
        
        sortedMatches.sort(by:{
            if $0.getRound() != $1.getRound() {
                return $0.getRound() < $1.getRound()
            }
            else {
                //last names are the same, break ties by first name
                return $0.getMatchNumber() < $1.getMatchNumber()
            }
        })
        
        return sortedMatches
    }
    
    func getMatchesSortedForTable() -> [Match] {
        var sortedMatches = self.matches
        
        sortedMatches.sort(by:{
            if $0.getRound() != $1.getRound() {
                return $0.getRound() < $1.getRound()
            }
            else {
                return $0.getMatchNumber() < $1.getMatchNumber()
            }
        })
        
        var matchesNotStarted = [Match]()
        var matchesFinished = [Match]()
        var matchesUnderway = [Match]()
        for match in sortedMatches {
            if match.getStartingHole() == match.getCurrentHole() {
                matchesNotStarted.append(match)
            }
            else if match.isCompleted() {
                matchesFinished.append(match)
            }
            else {
                matchesUnderway.append(match)
            }
        }
        
        var tableMatches = [Match]()
        for match in matchesUnderway {
            tableMatches.append(match)
        }
        for match in matchesNotStarted {
            tableMatches.append(match)
        }
        for match in matchesFinished {
            tableMatches.append(match)
        }
        
        return tableMatches
    }
    
    func sortPlayersByTeamAndHandicap() -> [Player] {
        var sortedPlayers = self.players
        
        sortedPlayers.sort(by:{
            if $0.getTeam() != $1.getTeam() {
                return $0.getTeam() < $1.getTeam()
            }
            else {
                //last names are the same, break ties by first name
                return $0.getHandicap() < $1.getHandicap()
            }
        })
        
        return sortedPlayers
    }
    
    
    func liveScores() -> (Double,Double) {
        
        var blueScore: Double = 0
        var redScore: Double = 0
        
        for m in getMatches() //getRoundMatches(currentRound)
        {
            if m.winningTeam() == "Blue" {
                blueScore += m.getPoints()
            }
            else if m.winningTeam() == "Red" {
                redScore += m.getPoints()
            }
            else {
                blueScore = blueScore + (m.getPoints() / 2.0)
                redScore = redScore + (m.getPoints() / 2.0)
            }
        }
        
        let (blueCompletedScores,redCompletedScores) = self.getCompletedScores()
        
        return (blueScore-blueCompletedScores,redScore-redCompletedScores)
    }
    
    func getCompletedScores() -> (blueScore: Double, redScore: Double) {
        var blueScore = 0.0
        var redScore = 0.0
        
        for match in matches {
            
            if match.isCompleted() {
                if match.winningTeam() == "Blue" {
                    blueScore = blueScore + match.getPoints()
                }
                else if match.winningTeam() == "Red" {
                    redScore = redScore + match.getPoints()
                }
                else if match.winningTeam() == "AS" {
                    blueScore = blueScore + (match.getPoints() / 2.0)
                    redScore = redScore + (match.getPoints() / 2.0)
                }
            }
        }
        
        return (blueScore,redScore)
    }
    
    
    
    func isDrinkCartAvailable() -> Bool {
        return drinkCartAvailable
    }
    
    func getCourseWithName(name: String) -> Course {
        
        for course in self.courses {
            if course.getName() == name {
                return course
            }
        }
        
        return Course()
        
    }
    
    func appendCourse(course: Course) {
        self.courses.append(course)
    }
    
    func holeWinner(_ matchIn: Match, hole: Int) -> String {
        
        let course = getCourseWithName(name: matchIn.getCourseName())
        
        let lowestHandicap = matchIn.getLowestHandicap()
        
        let holeHandicap = course.getHole(hole).getHandicap()
        let courseSlope = matchIn.getCourseSlope()
        let coursePar = matchIn.getCoursePar()
        let courseRating = matchIn.getCourseRating()
        
        var blueScore = Int()
        var redScore = Int()
        
        let blueP1ActualScore = matchIn.blueTeamPlayerOne().getHoleScore(hole, round: matchIn.getRound())
        
        let redP1ActualScore = matchIn.redTeamPlayerOne().getHoleScore(hole, round: matchIn.getRound())
        
        
        if matchIn.getFormat() == "Alternate Shot" {
            var blue_team_handicap = Int()
            if matchIn.blueTeamPlayerTwo() != nil {
                blue_team_handicap = getTeamHandicap(format: matchIn.getFormat(), player1Handicap: matchIn.blueTeamPlayerOne().handicap, player2Handicap: matchIn.blueTeamPlayerTwo()!.getHandicap(), courseSlope: courseSlope,rating: courseRating, par: coursePar)
                //Int(round(Double(matchIn.blueTeamPlayerOne().handicap) * 0.6 + Double(matchIn.blueTeamPlayerTwo()!.getHandicap()) * 0.4))
            }
            else {
                blue_team_handicap = matchIn.blueTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar)
            }
            
            var red_team_handicap = Int()
            if matchIn.redTeamPlayerTwo() != nil {
                red_team_handicap = getTeamHandicap(format: matchIn.getFormat(), player1Handicap: matchIn.redTeamPlayerOne().handicap, player2Handicap: matchIn.redTeamPlayerTwo()!.getHandicap(), courseSlope: courseSlope,rating: courseRating, par: coursePar)
            }
            else {
                red_team_handicap = matchIn.redTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar)
            }
            
            if blue_team_handicap < red_team_handicap {
                red_team_handicap = red_team_handicap - blue_team_handicap
                blue_team_handicap = 0
            }
            else {
                blue_team_handicap = blue_team_handicap - red_team_handicap
                red_team_handicap = 0
            }
            
            blueScore = self.handicapScore(blueP1ActualScore, playerHandicap: blue_team_handicap, holeHandicap: holeHandicap)
            redScore = self.handicapScore(redP1ActualScore, playerHandicap: red_team_handicap, holeHandicap: holeHandicap)
        }
        else if matchIn.getFormat() == "Best Ball" {
            
            let blue_P1_handicap = matchIn.blueTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
            var blue_P2_handicap = Int()
            let red_P1_handicap = matchIn.redTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
            var red_P2_handicap = Int()
            
            let blueScoreP1 = handicapScore(blueP1ActualScore, playerHandicap: blue_P1_handicap, holeHandicap: holeHandicap)
            var blueScoreP2 = 0
            let redScoreP1 = handicapScore(redP1ActualScore, playerHandicap: red_P1_handicap, holeHandicap: holeHandicap)
            var redScoreP2 = 0
            
            
            if matchIn.blueTeamPlayerTwo() != nil {
                blue_P2_handicap = matchIn.blueTeamPlayerTwo()!.singlesHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
                let blueP2ActualScore = matchIn.blueTeamPlayerTwo()!.getHoleScore(hole, round: matchIn.getRound())
                blueScoreP2 = handicapScore(blueP2ActualScore, playerHandicap: blue_P2_handicap, holeHandicap: holeHandicap)
            }
            
            if matchIn.redTeamPlayerTwo() != nil {
                red_P2_handicap = matchIn.redTeamPlayerTwo()!.singlesHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
                let redP2ActualScore = matchIn.redTeamPlayerTwo()!.getHoleScore(hole, round: matchIn.getRound())
                redScoreP2 = handicapScore(redP2ActualScore, playerHandicap: red_P2_handicap, holeHandicap: holeHandicap)
            }
            
            
            if blueScoreP1 == 0 && blueScoreP2 == 0 {
                blueScore = 0
            }
            else if blueScoreP1 == 0 {
                blueScore = blueScoreP2
            }
            else if blueScoreP2 == 0 {
                blueScore = blueScoreP1
            }
            else {
                if blueScoreP1 > blueScoreP2 {
                    blueScore = blueScoreP2
                }
                else {
                    blueScore = blueScoreP1
                }
            }
            
            if redScoreP1 == 0 && redScoreP2 == 0 {
                redScore = 0
            }
            else if redScoreP1 == 0 {
                redScore = redScoreP2
            }
            else if redScoreP2  == 0 {
                redScore = redScoreP1
            }
            else {
                if redScoreP1 > redScoreP2 {
                    redScore = redScoreP2
                }
                else {
                    redScore = redScoreP1
                }
            }
            
        }
        else if matchIn.getFormat() == "Shamble" {
            
            let blue_P1_handicap = matchIn.blueTeamPlayerOne().shambleHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
            var blue_P2_handicap = Int()
            let red_P1_handicap = matchIn.redTeamPlayerOne().shambleHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
            var red_P2_handicap = Int()
            
            let blueScoreP1 = handicapScore(blueP1ActualScore, playerHandicap: blue_P1_handicap, holeHandicap: holeHandicap)
            var blueScoreP2 = 0
            let redScoreP1 = handicapScore(redP1ActualScore, playerHandicap: red_P1_handicap, holeHandicap: holeHandicap)
            var redScoreP2 = 0
            
            
            if matchIn.blueTeamPlayerTwo() != nil {
                blue_P2_handicap = matchIn.blueTeamPlayerTwo()!.shambleHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
                let blueP2ActualScore = matchIn.blueTeamPlayerTwo()!.getHoleScore(hole, round: matchIn.getRound())
                blueScoreP2 = handicapScore(blueP2ActualScore, playerHandicap: blue_P2_handicap, holeHandicap: holeHandicap)
            }
            
            if matchIn.redTeamPlayerTwo() != nil {
                red_P2_handicap = matchIn.redTeamPlayerTwo()!.shambleHandicap(courseSlope,rating: courseRating,par: coursePar) - lowestHandicap
                let redP2ActualScore = matchIn.redTeamPlayerTwo()!.getHoleScore(hole, round: matchIn.getRound())
                redScoreP2 = handicapScore(redP2ActualScore, playerHandicap: red_P2_handicap, holeHandicap: holeHandicap)
            }
            
            
            if blueScoreP1 == 0 && blueScoreP2 == 0 {
                blueScore = 0
            }
            else if blueScoreP1 == 0 {
                blueScore = blueScoreP2
            }
            else if blueScoreP2 == 0 {
                blueScore = blueScoreP1
            }
            else {
                if blueScoreP1 > blueScoreP2 {
                    blueScore = blueScoreP2
                }
                else {
                    blueScore = blueScoreP1
                }
            }
            
            if redScoreP1 == 0 && redScoreP2 == 0 {
                redScore = 0
            }
            else if redScoreP1 == 0 {
                redScore = redScoreP2
            }
            else if redScoreP2  == 0 {
                redScore = redScoreP1
            }
            else {
                if redScoreP1 > redScoreP2 {
                    redScore = redScoreP2
                }
                else {
                    redScore = redScoreP1
                }
            }
            
        }
        else if matchIn.getFormat() == "Two Man Scramble" {
            var blue_team_handicap = getTeamHandicap(format: matchIn.getFormat(), player1Handicap: matchIn.blueTeamPlayerOne().handicap, player2Handicap: matchIn.blueTeamPlayerTwo()!.getHandicap(), courseSlope: courseSlope,rating: courseRating, par: coursePar)
            var red_team_handicap = getTeamHandicap(format: matchIn.getFormat(), player1Handicap: matchIn.redTeamPlayerOne().handicap, player2Handicap: matchIn.redTeamPlayerTwo()!.getHandicap(), courseSlope: courseSlope,rating: courseRating, par: coursePar)
            
            if blue_team_handicap < red_team_handicap {
                red_team_handicap = red_team_handicap - blue_team_handicap
                blue_team_handicap = 0
            }
            else {
                blue_team_handicap = blue_team_handicap - red_team_handicap
                red_team_handicap = 0
            }
            
            blueScore = handicapScore(blueP1ActualScore, playerHandicap: blue_team_handicap, holeHandicap: holeHandicap)
            redScore = handicapScore(redP1ActualScore, playerHandicap: red_team_handicap, holeHandicap: holeHandicap)
        }
        else if matchIn.getFormat() == "Singles" {
            var bP1Handicap = matchIn.blueTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar)
            var rP1Handicap = matchIn.redTeamPlayerOne().singlesHandicap(courseSlope,rating: courseRating,par: coursePar)
            
            if bP1Handicap < rP1Handicap {
                rP1Handicap = rP1Handicap - bP1Handicap
                bP1Handicap = 0
            }
            else {
                bP1Handicap = bP1Handicap - rP1Handicap
                rP1Handicap = 0
            }
            
            blueScore = handicapScore(blueP1ActualScore, playerHandicap: bP1Handicap, holeHandicap: holeHandicap)
            redScore = handicapScore(redP1ActualScore, playerHandicap: rP1Handicap, holeHandicap: holeHandicap)
        }
        else if matchIn.getFormat() == "Four Man Scramble" {
            var blue_team_handicap = getTeamHandicap4ManScramble(format: matchIn.getFormat(), player1Handicap: matchIn.blueTeamPlayerOne().handicap, player2Handicap: matchIn.blueTeamPlayerTwo()!.getHandicap(), player3Handicap: matchIn.blueTeamPlayerThree()!.getHandicap(), player4Handicap: matchIn.blueTeamPlayerFour()!.getHandicap(), courseSlope: courseSlope)
            var red_team_handicap = getTeamHandicap4ManScramble(format: matchIn.getFormat(), player1Handicap: matchIn.redTeamPlayerOne().handicap, player2Handicap: matchIn.redTeamPlayerTwo()!.getHandicap(), player3Handicap: matchIn.redTeamPlayerThree()!.getHandicap(), player4Handicap: matchIn.redTeamPlayerFour()!.getHandicap(), courseSlope: courseSlope)
            
            if blue_team_handicap < red_team_handicap {
                red_team_handicap = red_team_handicap - blue_team_handicap
                blue_team_handicap = 0
            }
            else {
                blue_team_handicap = blue_team_handicap - red_team_handicap
                red_team_handicap = 0
            }
            
            blueScore = handicapScore(blueP1ActualScore, playerHandicap: blue_team_handicap, holeHandicap: holeHandicap)
            redScore = handicapScore(redP1ActualScore, playerHandicap: red_team_handicap, holeHandicap: holeHandicap)
        }
        
        if blueP1ActualScore == 0 && redP1ActualScore == 0 {
            return "AS"
        }
        else if blueScore < redScore {
            return "Blue"
        }
        else if blueScore > redScore {
            return "Red"
        }
        else { return "AS" }
        
    }
    
    func updateUserMatchHoleScores() {
        if User.sharedInstance.isScorekeeper() {
            let userPlayer = getPlayerWithName(User.sharedInstance.getName())
            
            let userMatches = getPlayerMatches(userPlayer!)
            
            for eachMatch in userMatches {
                if eachMatch.getCurrentHole() == 1 || (eachMatch.getCurrentHole() == 10 && eachMatch.getMatchLength() == 9) { }
                else {
                    if eachMatch.getMatchLength() == 9 && (eachMatch.getCurrentHole() >= 10) {
                        if eachMatch.getCurrentHole() != 10 {
                            for i in 10...(eachMatch.getCurrentHole()-1) {
                                
                                if holeWinner(eachMatch, hole: i) == "Blue" {
                                    eachMatch.setHoleWinner(hole: i, winner: "Blue")
                                }
                                else if holeWinner(eachMatch, hole: i) == "Red" {
                                    eachMatch.setHoleWinner(hole: i, winner: "Red")
                                }
                                else {
                                    eachMatch.setHoleWinner(hole: i, winner: "Halved")
                                }
                            }
                        }
                        else { eachMatch.setHoleWinner(hole: 10, winner: "Halved") }
                    }
                    else {
                        for i in 1...(eachMatch.getCurrentHole()-1) {
                            
                            if holeWinner(eachMatch, hole: i) == "Blue" {
                                eachMatch.setHoleWinner(hole: i, winner: "Blue")
                            }
                            else if holeWinner(eachMatch, hole: i) == "Red" {
                                eachMatch.setHoleWinner(hole: i, winner: "Red")
                            }
                            else {
                                eachMatch.setHoleWinner(hole: i, winner: "Halved")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func handicapScore(_ actualScore: Int, playerHandicap: Int, holeHandicap: Int) -> Int {
        var handicapScore = Int()
        
        if playerHandicap >= 36 {
            if (playerHandicap - 36) >= holeHandicap {
                handicapScore = actualScore - 3
            }
            else {
                handicapScore = actualScore - 2
            }
        }
        else if playerHandicap >= 18 {
            if (playerHandicap - 18) >= holeHandicap {
                handicapScore = actualScore - 2
            }
            else {
                handicapScore = actualScore - 1
            }
        }
        else {
            if playerHandicap >= holeHandicap {
                handicapScore = actualScore - 1
            }
            else {
                handicapScore = actualScore
            }
        }
        
        return handicapScore
    }
    
    func checkScorekeeper(_ name: String) -> Bool {
        
        for eachMatch in matches {
            if !eachMatch.isCompleted() {
                if eachMatch.getScorekeeperName() == name {
                    return true
                }
            }
        }
        return false
    }
    
    func setMatches(_ newMatches: [Match]) {
        self.matches = newMatches
    }
    
    func getTeamHandicap4ManScramble(format: String, player1Handicap: Double, player2Handicap: Double, player3Handicap: Double, player4Handicap: Double, courseSlope: Int) -> Int {
        let slopeFactor = Double(courseSlope) / 113.0
        
        let maxhandicap = Double(self.maxhandicap)
        let P1Handicap = min(Darwin.round(Double(player1Handicap) * slopeFactor),maxhandicap)
        let P2Handicap = min(Darwin.round(Double(player2Handicap) * slopeFactor),maxhandicap)
        let P3Handicap = min(Darwin.round(Double(player3Handicap) * slopeFactor),maxhandicap)
        let P4Handicap = min(Darwin.round(Double(player4Handicap) * slopeFactor),maxhandicap)
        
        return Int(Darwin.round(P1Handicap * 0.20 + P2Handicap * 0.15 + P3Handicap * 0.10 + P4Handicap * 0.05))
    }
    
    func getTeamHandicap(format: String, player1Handicap: Double, player2Handicap: Double, courseSlope: Int, rating: Double, par: Double) -> Int {
        let slopeFactor = Double(courseSlope) / 113.0
        
        /*
        if format == "Alternate Shot" {
            //return Int(round((Double(player1Handicap) * 0.6 + Double(player2Handicap) * 0.4) * Double(courseSlope / 113)))
            return min(Int(Darwin.round((Double(player1Handicap) * 0.6 + Double(player2Handicap) * 0.4) * slopeFactor)),self.maxhandicap)
        }
        else if format == "Two Man Scramble" {
            //return Int(round((Double(player1Handicap) * 0.35 + Double(player2Handicap) * 0.15) * Double(courseSlope / 113)))
            return min(Int(Darwin.round((Double(player1Handicap) * 0.35 + Double(player2Handicap) * 0.15) * slopeFactor)),self.maxhandicap)
        }
        else {
            return 0
        }
 */
        //min(Int(Darwin.round((Double(self.handicap) * slopeFactor) + (rating - par))),maxhandicap)
        let maxhandicap = Double(self.maxhandicap)
        //let P1Handicap = min(Darwin.round(Double(player1Handicap) * slopeFactor),maxhandicap)
        //let P2Handicap = min(Darwin.round(Double(player2Handicap) * slopeFactor),maxhandicap)
        let P1FullHandicap = Int(Darwin.round((Double(player1Handicap) * slopeFactor) + (rating - par)))
        let P2FullHandicap = Int(Darwin.round((Double(player2Handicap) * slopeFactor) + (rating - par)))

        
        let P1Handicap = min(P1FullHandicap,Int(maxhandicap))
        let P2Handicap = min(P2FullHandicap,Int(maxhandicap))

        if format == "Alternate Shot" {
            return Int(Darwin.round(Double(P1Handicap) * 0.5 + Double(P2Handicap) * 0.5))
        }
        else if format == "Two Man Scramble" {
            return Int(Darwin.round(Double(P1Handicap) * 0.35 + Double(P2Handicap) * 0.15))
        }
        else if format == "Four Man Scramble" {
            return 0
        }
        else {
            return 0
        }
    }
    
}
