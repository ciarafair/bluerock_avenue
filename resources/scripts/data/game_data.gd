extends Node
class_name GameData

var has_emitted_loaded

var Time_Hour: int = 11
var Time_Minute: int = 30
var Time_String: String = "11:30am"

var Is_Monster_Active: bool = false

var Monster_Current_Room: String = ""
var Monster_Room_Window: String = ""
var Monster_Current_Stage: int = 0
var Monster_Room_Number: int = 0

var Is_Flashlight_On: bool = false

var Current_Block: Block = null
var Current_Room: Block = null

var Current_Event: String = ""
var Current_Room_Number = 1

var Television_State: bool = true
var Current_Task: Global.task = Global.task.TASK_ONE

var PlayerInventory: Array = []

func _process(_delta):
	if has_emitted_loaded == false:
		has_emitted_loaded = true
		SignalManager.game_data_instance_loaded.emit()
