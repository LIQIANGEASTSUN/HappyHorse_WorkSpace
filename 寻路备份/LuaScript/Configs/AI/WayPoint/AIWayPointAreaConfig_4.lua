local config = [====[{
    "id": 4,
    "points": [
        {
            "id": 1,
            "position": {
                "x": -16.672000885009767,
                "y": 0.0,
                "z": 21.631000518798829
            },
            "adjPoints": [
                2,
                5
            ]
        },
        {
            "id": 2,
            "position": {
                "x": -16.624000549316408,
                "y": 0.0,
                "z": 26.69700050354004
            },
            "adjPoints": [
                1,
                3
            ]
        },
        {
            "id": 3,
            "position": {
                "x": -16.617000579833986,
                "y": 0.0,
                "z": 30.385000228881837
            },
            "adjPoints": [
                2
            ]
        },
        {
            "id": 4,
            "position": {
                "x": -20.065000534057618,
                "y": 0.0,
                "z": 15.6850004196167
            },
            "adjPoints": [
                5
            ]
        },
        {
            "id": 5,
            "position": {
                "x": -16.59000015258789,
                "y": 0.0,
                "z": 15.847000122070313
            },
            "adjPoints": [
                4,
                1
            ]
        }
    ],
    "containsMapRegion": [
        4
    ],
    "bornPoints": [
        {
            "id": 4,
            "inSatArea": 0,
            "forwardAngle": 89.4800033569336
        },
        {
            "id": 3,
            "inSatArea": 0,
            "forwardAngle": 178.9459991455078
        }
    ]
}]====]
return table.deserialize(config)