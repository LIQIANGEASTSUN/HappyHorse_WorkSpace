local config = [====[{
    "id": 1,
    "points": [
        {
            "id": 5,
            "position": {
                "x": -11.279000282287598,
                "y": 0.0,
                "z": 2.3010001182556154
            },
            "adjPoints": [
                6,
                8
            ]
        },
        {
            "id": 6,
            "position": {
                "x": -7.769000053405762,
                "y": 0.0,
                "z": 2.492000102996826
            },
            "adjPoints": [
                5,
                7
            ]
        },
        {
            "id": 7,
            "position": {
                "x": -5.326000213623047,
                "y": 0.0,
                "z": 2.6470000743865969
            },
            "adjPoints": [
                6
            ]
        },
        {
            "id": 8,
            "position": {
                "x": -11.48900032043457,
                "y": 0.0,
                "z": -0.23100000619888307
            },
            "adjPoints": [
                5,
                9
            ]
        },
        {
            "id": 9,
            "position": {
                "x": -11.487000465393067,
                "y": 0.0,
                "z": -3.2820000648498537
            },
            "adjPoints": [
                8
            ]
        }
    ],
    "containsMapRegion": [
        1
    ],
    "bornPoints": [
        {
            "id": 7,
            "inSatArea": 0,
            "forwardAngle": 23.0
        },
        {
            "id": 6,
            "inSatArea": 0,
            "forwardAngle": 116.0
        }
    ]
}]====]
return table.deserialize(config)