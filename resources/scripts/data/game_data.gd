extends Node
class_name GameData

var Time_Hour: int = 11
var Time_Minute: int = 30
var Time_String: String = "11:30am"

var Is_Monster_Active: bool = true
var Monster_Current_Room: RoomBlock = null
var Monster_Current_Stage: int = 0
var Monster_Room_Number: int = 0

var Current_Task: Global.task = Global.task.TURN_OFF_TV
var Current_Active_Block: Block = null
var Current_Block_Name: String = ""
var Current_Event: String = ""
var Current_Room: Block = null
var Current_Room_Number = 1
var Is_Flashlight_On: bool = false
