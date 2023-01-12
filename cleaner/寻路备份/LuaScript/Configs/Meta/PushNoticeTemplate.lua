local config = [====[{
"1":{"id":"1","title":"empty","content":"push_normal_1","type":1,"value":0,"order":1,"priority":3,"timing_types":[3,12,0]},
"2":{"id":"2","title":"empty","content":"push_normal_2","type":1,"value":0,"order":2,"priority":3,"timing_types":[3,19,0]},
"3":{"id":"3","title":"empty","content":"push_lives_full","type":2,"value":0,"order":3,"priority":2,"timing_types":[]},
"4":{"id":"4","title":"empty","content":"push_building_ready","type":3,"value":0,"order":4,"priority":2,"timing_types":[]},
"5":{"id":"5","title":"empty","content":"push_dragon_ready","type":4,"value":0,"order":5,"priority":2,"timing_types":[]},
"6":{"id":"6","title":"empty","content":"push_timeOrder_ready","type":5,"value":0,"order":6,"priority":2,"timing_types":[]},
"7":{"id":"7","title":"empty","content":"push_grasselement_ready","type":6,"value":1,"order":8,"priority":2,"timing_types":[]},
"8":{"id":"8","title":"empty","content":"push_woodelement_ready","type":6,"value":2,"order":9,"priority":2,"timing_types":[]},
"9":{"id":"9","title":"empty","content":"push_stoneelement_ready","type":6,"value":3,"order":10,"priority":2,"timing_types":[]},
"10":{"id":"10","title":"empty","content":"push_oreelement_ready","type":6,"value":4,"order":11,"priority":2,"timing_types":[]},
"11":{"id":"11","title":"empty","content":"push_goldpass_start","type":7,"value":1,"order":7,"priority":1,"timing_types":[]}
}]====]
return table.deserialize(config)