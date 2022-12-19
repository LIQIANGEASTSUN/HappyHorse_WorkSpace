local config = [====[{
    "id": 7,
    "points": [
        {
            "id": 1,
            "position": {
                "x": -16.363000869750978,
                "y": 0.0,
                "z": 60.09700012207031
            },
            "adjPoints": [
                2,
                3
            ]
        },
        {
            "id": 2,
            "position": {
                "x": -16.468000411987306,
                "y": 0.0,
                "z": 53.16400146484375
            },
            "adjPoints": [
                1
            ]
        },
        {
            "id": 3,
            "position": {
                "x": -16.461000442504884,
                "y": 0.0,
                "z": 64.29100036621094
            },
            "adjPoints": [
                1
            ]
        }
    ],
    "containsMapRegion": [
        7
    ],
    "bornPoints": [
        {
            "id": 2,
            "inSatArea": 0,
            "forwardAngle": 0.0
        },
        {
            "id": 3,
            "inSatArea": 0,
            "forwardAngle": 0.0
        }
    ]
}]====]
return table.deserialize(config)