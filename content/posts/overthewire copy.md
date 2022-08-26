---
title: "Linux Tips"
date: 2020-04-07T14:01:30+08:00
draft: false
category: "Linux"
tags: [ "hack", "os", "Linux" ]
---

## tmux(切割終端視窗＆保存工作狀態)

按任何快捷鍵之前要先按 Ctrl + b

Pane
|指令|說明|
|------|-------|
|%|水平分割|
|"|垂直分割|
|方向鍵|切換pane|
|x|刪除當前的pane|

Pane內操作
|指令|說明|
|------|-------|
|[|Scroll in pane (q to Quit)|

修改Pane分配比例，按下Ctrl+B，之後放開B並按上下左右調整視窗分配比
Ｍac的部分如果無法使用則可以參考[這篇](https://superuser.com/questions/660013/resizing-pane-is-not-working-for-tmux-on-mac)(mac可以改輸出的Acsii)

Window
|指令|說明|
|------|-------|
|c|創建新的window|
|&|關閉目前的window|
|p|切換到上一個window|
|n|切換到下一個window|

Session

| 指令 | 說明 |
| -------- | -------- |
| tmux     | 開啟一個新的session     |
|tmux ls|查看所有session|
|tmux attach -t 0|重新連線到session 0|
|tmux kill-session -t 0 |刪除 session 0|
|d|跳出並保存當前session|
|s|切換session|



## Ubuntu 關閉 window
- Stop windows of ubuntu(節省資源)
```shell=
sudo service lightdm stop
```

## User 換 shell
```shell=
chsh -s [/bin/bash]
```


## Ubuntu apt 檢查version&安裝
```shell=
#check
apt-cache madison <<package name>>

#install
apt-get install <<package name>>=<<version>>
```
https://www.cnblogs.com/EasonJim/p/7144017.html

## 把application 放進 Lancher

如果有自己寫的程式想透過Lancher來執行可以用以下設定來達成
- 首先到以下路徑：cd .local/share/applications/ or global /usr/share/applications/
- 裡有很多 *.desktop 的文件隨便找一份來參考
```shell=
#!/usr/bin/env xdg-open
[Desktop Entry]
Type=Application
Name=robo 3T Linux
Exec="/home/aaron/robo3t/bin/robo3t"
Icon=/home/aaron/robo3t/icon.png
Categories=Application;

```
## Monitor Setting

```
xrandr
```

ref: https://p501lab.blogspot.com/2015/12/xrandr.html



