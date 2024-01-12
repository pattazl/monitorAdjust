### 介绍

通过软件控制多个外置显示器的亮度和对比度，显示器需要支持 DDC/CI 协议 。注意：市面上很多type-C扩展坞转hdmi接口时候会去掉DDC/CI协议的支持，从而导致无法使用。

基于 https://github.com/tigerlily-dev/Monitor-Configuration-Class 进行开发，发现其在特定笔记本扩展显示器上有一些bug，跳过异常只处理外置显示器

使用 Autohotkey v2.0.3  开发和编译，内存占用低

对笔记本等有内置显示屏，扩展外置显示器时，可能有一些问题

### 使用说明

1. 托盘右键菜单选择要修改的显示器
2. 右键菜单点击操作
3. 快捷键操作如下：

默认window+F5 降低亮度

默认window+F6 增加亮度

默认window+F7 降低对比度

默认window+F8 增加对比度

默认步长为 10 

以上可在 monitorAdjust.ini 文件(如不存在，设置时会自动创建) 中修改

; 定义快捷键, !表示Alt , #表示windows, +表示shift, ^ 表示Ctrl, 比如 ^#F5 表示同时按下 ctrl+win+F5键，可以用按键名或 VKnn(其中为键位数) 定义按键，修改后重启程序生效



