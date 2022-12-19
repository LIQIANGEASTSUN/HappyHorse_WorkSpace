local config = [====[{
    "id": 2,
    "points": [
        {
            "id": 1,
            "position": {
                "x": -13.829000473022461,
                "y": 0.0,
                "z": -6.089000225067139
            },
            "adjPoints": [
                2,
                5
            ]
        },
        {
            "id": 2,
            "position": {
                "x": -18.35700035095215,
                "y": 0.0,
                "z": -5.651000022888184
            },
            "adjPoints": [
                1,
                3,
                4
            ]
        },
        {
            "id": 3,
            "position": {
                "x": -21.201000213623048,
                "y": 0.0,
                "z": -6.072000026702881
            },
            "adjPoints": [
                2
            ]
        },
        {
            "id": 4,
            "position": {
                "x": -18.402000427246095,
                "y": 0.0,
                "z": -3.996000051498413
            },
            "adjPoints": [
                2
            ]
        },
        {
            "id": 5,
            "position": {
                "x": -11.755000114440918,
                "y": 0.0,
                "z": -5.572000026702881
            },
            "adjPoints": [
                6,
                1
            ]
        },
        {
            "id": 6,
            "position": {
                "x": -11.821000099182129,
                "y": 0.0,
                "z": -2.950000047683716
            },
            "adjPoints": [
                5,
                7
            ]
        },
        {
            "id": 7,
            "position": {
                "x": -11.729000091552735,
                "y": 0.0,
                "z": 0.0
            },
            "adjPoints": [
                6
            ]
        }
    ],
    "containsMapRegion": [
        2
    ],
    "bornPoints": [
        {
            "id": 7,
            "inSatArea": 0,
            "forwardAngle": 115.69999694824219
        },
        {
            "id": 6,
            "inSatArea": 0,
            "forwardAngle": 100.0
        },
        {
            "id": 4,
            "inSatArea": 0,
            "forwardAngle": 93.5999984741211
        }
    ]
}]====]
return table.deserialize(config)