local config = [====[{
    "id": 5,
    "points": [
        {
            "id": 1,
            "position": {
                "x": -1.0010000467300416,
                "y": 0.0,
                "z": 33.999000549316409
            },
            "adjPoints": [
                2,
                8
            ]
        },
        {
            "id": 2,
            "position": {
                "x": -8.416000366210938,
                "y": 0.0,
                "z": 33.444000244140628
            },
            "adjPoints": [
                1,
                3
            ]
        },
        {
            "id": 3,
            "position": {
                "x": -11.128000259399414,
                "y": 0.0,
                "z": 33.76900100708008
            },
            "adjPoints": [
                2,
                4
            ]
        },
        {
            "id": 4,
            "position": {
                "x": -16.472000122070314,
                "y": 0.0,
                "z": 34.42300033569336
            },
            "adjPoints": [
                5,
                3
            ]
        },
        {
            "id": 5,
            "position": {
                "x": -16.770000457763673,
                "y": 0.0,
                "z": 37.14500045776367
            },
            "adjPoints": [
                6,
                4
            ]
        },
        {
            "id": 6,
            "position": {
                "x": -17.552000045776368,
                "y": 0.0,
                "z": 39.979000091552737
            },
            "adjPoints": [
                5,
                7
            ]
        },
        {
            "id": 7,
            "position": {
                "x": -17.23900032043457,
                "y": 0.0,
                "z": 42.47600173950195
            },
            "adjPoints": [
                6
            ]
        },
        {
            "id": 8,
            "position": {
                "x": 0.6520000100135803,
                "y": 0.0,
                "z": 36.21500015258789
            },
            "adjPoints": [
                1,
                9
            ]
        },
        {
            "id": 9,
            "position": {
                "x": 0.8330000042915344,
                "y": 0.0,
                "z": 41.319000244140628
            },
            "adjPoints": [
                8
            ]
        }
    ],
    "containsMapRegion": [
        5
    ],
    "bornPoints": [
        {
            "id": 8,
            "inSatArea": 0,
            "forwardAngle": 0.0
        },
        {
            "id": 1,
            "inSatArea": 0,
            "forwardAngle": 0.0
        },
        {
            "id": 4,
            "inSatArea": 0,
            "forwardAngle": 0.0
        },
        {
            "id": 5,
            "inSatArea": 0,
            "forwardAngle": 0.0
        },
        {
            "id": 7,
            "inSatArea": 0,
            "forwardAngle": 0.0
        }
    ]
}]====]
return table.deserialize(config)