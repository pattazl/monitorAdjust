#Requires AutoHotkey v2.0
#SingleInstance Force
;================ 改变显示器亮度 ， ahk下载地址和思路：https://github.com/tigerlily-dev/Monitor-Configuration-Class
#Include  ".\lib\Monitor Class.ahk"  ;包含当下目录的某AHK文件
; 全局通用变量和函数
global APPName:="monitorAdjust", ver:="1.3" 
     , IniFile := "monitorAdjust.ini"
step := 5
mon := Monitor() ; Create new class instance
MonitorIndex := 0 ; 默认选中的显示器,从配置文件中读取

if not FileExist(IniFile){
	FileObj := FileOpen(IniFile, "w")
	FileObj.write("[setting]`n" .
	"; 每次按键调节的步长`n" . 
	"step = 10`n" . 
	"; 定义快捷键, !表示Alt , #表示windows, +表示shift, ^ 表示Ctrl, 比如 ^#F5 表示同时按下 ctrl+win+F5键，修改后重启程序生效`n" .
	"BrightnessDecrease = #F5`n" .
	"BrightnessIncrease = #F6`n" .
	"ContrastDecrease = #F7`n" .
	"ContrastIncrease = #F8`n")
   FileObj.Close()
}
;气泡提示框
; 参考：ToolTip - AutoHotkey 中文手册
; ToolTip - Syntax & Usage
MonitorGet(MonitorIndex, &Left, &Top, &Right, &Bottom)
tipX := Left+(Right-Left)/2
tipY := Top+(Bottom-Top)/2
tooltips(str, ms)  ;参数：显示的字符串，显示多少毫秒后消失
{
	CoordMode "ToolTip"  ;为多个命令设置坐标模式，相对于活动窗口还是屏幕。
	ToolTip(str, tipX, tipY)
	
	ms := 0 - ms
	SetTimer () => ToolTip(), ms
	return
}

AddBright(num){
	try{
		Bright := mon.GetBrightness(MonitorIndex)["Current"]
		mon.SetBrightness(Bright + num ,MonitorIndex)
		
		;显示当前亮度
		Bright := mon.GetBrightness(MonitorIndex)["Current"]
		tooltips("亮度：" . Bright, 2000)  ; 【 . 】表示连接字符串
		UpdateMenuInfo()
	}catch{
	}
}
AddBright1(ThisHotkey)
{
    AddBright(-step)
}
AddBright2(ThisHotkey)
{
    AddBright(step)
}
AddContrast(num){
	try{
		Contrast := mon.GetContrast(MonitorIndex)["Current"]
		mon.SetContrast(Contrast + num ,MonitorIndex)
		
		;显示当前对比度
		Contrast := mon.GetContrast(MonitorIndex)["Current"]
		tooltips("对比度：" . Contrast, 2000)  ; 【 . 】表示连接字符串
		UpdateMenuInfo()
	}catch{
	}
}
AddContrast1(ThisHotkey)
{
    AddContrast(-step)
}
AddContrast2(ThisHotkey)
{
    AddContrast(step)
}
MCount := 0
MCountErr := Map()
MonitorInfo := Array()
;用于获取多个显示器的亮度和对比度
GetMonitorInfo(){
    MInfo := []
    global MCount := MonitorGetCount()
    loop MCount {
        try{
            data1 := mon.GetBrightness(A_Index)["Current"]  ; "\\.\DISPLAY" 
            data2 := mon.GetContrast(A_Index)["Current"]     ;"\\.\DISPLAY" 
        }catch {
            ; MCount := A_Index -1  ; 出现异常则跳过
			MCountErr.set(A_Index,0) 
			; 如果保存的默认显示器序号已经不存在，则清空
            if(MonitorIndex = A_Index){
			     global MonitorIndex := 0
		    }
			data1 := 0
			data2 := 0
        }
        MInfo.push("亮度:" data1 "%对比度:" data2 "%")
        ;MInfo.push("亮度:")
    }
    return MInfo
}
; 更新菜单上的数据
UpdateMenuInfo(){
    Minfo := GetMonitorInfo()
    loop MCount {
	    if(MCountErr.Has(A_Index)){
		   Continue 
		}
        A_TrayMenu.rename(L_menu_monitor A_Index MonitorInfo[A_Index] , L_menu_monitor A_Index Minfo[A_Index] )
    }
    global MonitorInfo := Minfo
}
; 托盘相关
global L_menu_startup:="开机启动"
global L_menu_reload:="重启程序"
global L_menu_monitor:="显示器#"
global L_menu_set:="打开配置"
global L_menu_pause:="暂停运行"
global L_menu_bright1:="亮度-"
global L_menu_bright2:="亮度+"
global L_menu_contrast1:="对比度-"
global L_menu_contrast2:="对比度+"

global L_menu_exit:="退出程序"
LinkPath := A_Startup "\" APPName ".Lnk"
MenuHandler(ItemName , ItemPos, MyMenu){
  if(ItemName = L_menu_startup)
  {
    If FileExist(LinkPath)
    {
      FileDelete LinkPath
      MyMenu.Uncheck(L_menu_startup)
    }
    else
    {
      FileCreateShortcut A_ScriptFullPath, A_Startup "\" APPName ".Lnk", A_ScriptDir
      MyMenu.Check(L_menu_startup)
    }
  }
  if(ItemName = L_menu_reload)
  {
	Reload()
  }
  if(ItemName = L_menu_exit)
  {
	ExitApp()
  }
  if(ItemName = L_menu_set)
  {
	Run IniFile
  }
  ; 清空全部
  if( InStr(ItemName, L_menu_monitor) > 0 )
  {
    loop MCount {
	    if(MCountErr.Has(A_Index)){
		   Continue 
		}
        MyMenu.UnCheck(L_menu_monitor A_Index MonitorInfo[A_Index])
    }
    MyMenu.Check(ItemName)
    if( RegExMatch(ItemName, "#(\d+)", &SubPat) > 0){
        global MonitorIndex := Integer(SubPat[1])
    }
  }
  if( InStr(ItemName, L_menu_bright1) > 0 )
  {
    AddBright(-step)
  }
  if( InStr(ItemName, L_menu_bright2) > 0 )
  {
    AddBright(step)
  }
  if( InStr(ItemName, L_menu_contrast1) > 0 )
  {
    AddContrast(-step)
  }
  if( InStr(ItemName, L_menu_contrast2) > 0 )
  {
    AddContrast(step)
  }
}

CreateMenu()
{
  ; 获取初始化信息并赋值
  global step := Integer(IniRead(IniFile,"setting","step","10"))
  global MonitorIndex := Integer(IniRead(IniFile,"setting","MonitorIndex","1"))
  key1 := IniRead(IniFile,"setting","BrightnessDecrease","#F5")
  key2 := IniRead(IniFile,"setting","BrightnessIncrease","#F6")
  key3 := IniRead(IniFile,"setting","ContrastDecrease","#F7")
  key4 := IniRead(IniFile,"setting","ContrastIncrease","#F8")
  ; 获取显示器信息,可能会有一些延时，尝试10次
  loop 10 {
    global MonitorInfo := GetMonitorInfo()
    if MonitorInfo.Length = 0{
        sleep(1000)
    }else{
        break
    }
  }
  if MonitorInfo.Length = 0 {
    MsgBox("未获取到任何显示器信息，请重启程序")
    ExitApp
    return
  }
  if (MonitorIndex > MonitorInfo.Length){
    MonitorIndex := MonitorInfo.Length  ; 找一个最近的作为默认值
  }
  ;减小亮度
  Hotkey key1, AddBright1
  ;增大亮度
  Hotkey key2, AddBright2
  ;减小对比度
  Hotkey key3, AddContrast1
  ;增大对比度
  Hotkey key4, AddContrast2
  A_IconTip := APPName " v" ver
  TrayTip(A_IconTip)                ; 托盘提示信息
  MyMenu := A_TrayMenu 
  ; 清空默认菜单
  MyMenu.Delete()
  MyMenu.Add(L_menu_startup, MenuHandler)
  MyMenu.Add(L_menu_reload, MenuHandler)
  MyMenu.Add(L_menu_set, MenuHandler)
  MyMenu.Add(L_menu_exit, MenuHandler)
  MyMenu.Add()
  ; 动态创建显示器清单
  loop MCount {
     if(MCountErr.Has(A_Index)){
		   Continue 
	}
	MyMenu.Add(L_menu_monitor A_Index MonitorInfo[A_Index], MenuHandler)
	; 如果默认显示器编号不存在则用有效的显示器编号
	if MonitorIndex = 0 {
		MonitorIndex := A_Index
	}
  }
  ; 有可能菜单不存在
  try{
       MyMenu.Check(L_menu_monitor MonitorIndex MonitorInfo[MonitorIndex])
  }catch{
  }
  if(MonitorIndex=0){
      MyMenu.Add('无可调整监视器，请确认硬件后重启',MenuHandler)
  }else{
  MyMenu.Add(L_menu_bright1 step ',快捷键' key1, MenuHandler)
  MyMenu.Add(L_menu_bright2 step ',快捷键' key2, MenuHandler)
  MyMenu.Add(L_menu_contrast1 step ',快捷键' key3, MenuHandler)
  MyMenu.Add(L_menu_contrast2 step ',快捷键' key4, MenuHandler)
  }
  
  ; 初始化默认状态
  If FileExist(LinkPath)
  {
    MyMenu.Check(L_menu_startup)
  }
}
CreateMenu()
; 退出时候保存选择的显示器序号
OnExit ExitFunc
ExitFunc(ExitReason, ExitCode)
{
    IniWrite MonitorIndex , IniFile, "setting", "MonitorIndex"
}

