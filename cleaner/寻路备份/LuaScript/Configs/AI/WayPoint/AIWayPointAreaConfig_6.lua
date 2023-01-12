local config = [====[{
    "id": 6,
    "points": [
        {
            "id": 1,
            "position": {
                "x": -19.552000045776368,
                "y": 0.0,
                "z": 36.70600128173828
            },
            "adjPoints": [
                2,
                3
            ]
        },
        {
            "id": 2,
            "position": {
                "x": -28.45400047302246,
                "y": 0.0,
                "z": 36.777000427246097
            },
            "adjPoints": [
                1
            ]
        },
        {
            "id": 3,
            "position": {
                "x": -17.069000244140626,
                "y": 0.0,
                "z": 36.832000732421878
            },
            "adjPoints": [
                1,
                4
            ]
        },
        {
            "id": 4,
            "position": {
                "x": -16.75200080871582,
                "y": 0.0,
                "z": 39.729000091552737
            },
            "adjPoints": [
                3
            ]
        }
    ],
    "containsMapRegion": [
        6
    ],
    "bornPoints": [
        {
            "id": 1,
            "inSatArea": 0,
            "forwardAngle": 0.0
        }
    ]
}]====]
return table.deserialize(config)