local config = [====[{
    "id": 3,
    "points": [
        {
            "id": 1,
            "position": {
                "x": -3.2890000343322756,
                "y": 0.0,
                "z": 17.010000228881837
            },
            "adjPoints": [
                2,
                5
            ]
        },
        {
            "id": 2,
            "position": {
                "x": -6.875,
                "y": 0.0,
                "z": 16.71500015258789
            },
            "adjPoints": [
                1,
                3
            ]
        },
        {
            "id": 3,
            "position": {
                "x": -9.89900016784668,
                "y": 0.0,
                "z": 17.628000259399415
            },
            "adjPoints": [
                2,
                4
            ]
        },
        {
            "id": 4,
            "position": {
                "x": -12.034000396728516,
                "y": 0.0,
                "z": 16.663000106811525
            },
            "adjPoints": [
                3
            ]
        },
        {
            "id": 5,
            "position": {
                "x": -2.815000057220459,
                "y": 0.0,
                "z": 21.11400032043457
            },
            "adjPoints": [
                6,
                1
            ]
        },
        {
            "id": 6,
            "position": {
                "x": -2.5380001068115236,
                "y": 0.0,
                "z": 25.760000228881837
            },
            "adjPoints": [
                5,
                7
            ]
        },
        {
            "id": 7,
            "position": {
                "x": -3.6570000648498537,
                "y": 0.0,
                "z": 28.270000457763673
            },
            "adjPoints": [
                6
            ]
        }
    ],
    "containsMapRegion": [
        3
    ],
    "bornPoints": [
        {
            "id": 1,
            "inSatArea": 0,
            "forwardAngle": 115.69999694824219
        },
        {
            "id": 3,
            "inSatArea": 0,
            "forwardAngle": 100.0
        },
        {
            "id": 5,
            "inSatArea": 0,
            "forwardAngle": 178.8800048828125
        },
        {
            "id": 7,
            "inSatArea": 0,
            "forwardAngle": 93.5999984741211
        }
    ]
}]====]
return table.deserialize(config)