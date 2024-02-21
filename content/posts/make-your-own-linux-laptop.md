---
title: "Make your own linux laptop"
date: 2021-06-07T14:01:30+08:00
draft: false
category: "linux"
tags: [ "linux", "laptop" ]
---
# Make XPS13 Linux laptop 

## 筆電挑選
Dell XPS13 支援 通過 Ubuntu 認證
## 灌系統 選擇版本 顯示卡驅動 wifi驅動
待補...
## 雙系統 dual os
- https://medium.com/@josef.andersson/dual-boot-windows-10-and-ubuntu-18-10-on-dell-xps-9370-1a77ae9716bc
- https://estl.tech/dual-boot-ubuntu-on-dell-xps-1365df21b947
## leagcy vs uefi
## 磁區分割
itread01.com/content/1549288804.html?fbclid=IwAR17jW3QC2M0FJjNWrbI5p_BFYBmQFN4g7kmvYqyfwR7IUKzFF_5BNEz7DY

## Grub
The Dell XPS 13 came with a 4K screen. Unfortunately, the GRUB bootloader does not scale the text so everything was really tiny. It was really hard to see what operating system was selected for boot.
This AskUbuntu page has the solution. Similar to the comment by Bernard Wei, the videoinfo command did not work for me. 1024x768 and 1280x1024 were both okay but not 1920x1080.

```shell=
sudo vim /etc/default/grub

# Add two line
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_GFXMODE=1024x768

sudo update-grub
```

Ref: https://estl.tech/dual-boot-ubuntu-on-dell-xps-1365df21b947
## 開機選單
- refind
## 與mac一樣手勢 
- https://medium.com/@dgviranmalaka/how-to-enhance-touch-pad-gestures-like-mac-in-ubuntu-18-04-laptop-f5f25d5a0b4f
## workspace 橫化 gnome extention
## 電源管理

在我灌好設定好筆電之後，也測試了一下睡眠功能發現可以正常喚醒，這下我也可以跟mac一樣不用關機了，於是我合上筆電洗洗睡。

你以為到這裡就沒了嗎....

隔天工作回家打開我心愛的筆電發現電量剩下22%，靠而且機台還熱熱的。
不行不行 我立刻上網查，發現原來18.04版本的睡眠(suspend)預設只有螢幕關掉...

```shell=
mem_sleep_default=      [SUSPEND] Default system suspend mode:
                        s2idle  - Suspend-To-Idle
                        shallow - Power-On Suspend or equivalent (if supported)
                        deep    - Suspend-To-RAM or equivalent (if supported)
                        See Documentation/admin-guide/pm/sleep-states.rst.
```

Ref: https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html

似乎在linux kernel 有這三種模式可以選擇，於是我查到這行指令可以查看當前的模式
```shell=
cat /sys/power/mem_sleep
```
我們可以發現目前是運行在 s2idle, 必須修改設定到deep
```shell=
echo deep > /sys/power/mem_sleep
```
到這裡可以先測試一下睡眠的效果，不過這個設定只要重新開機就會reset，假設你已經讓筆電睡眠了好幾小時，你會發現耗電量大量降低，因為這時候只有ram被供電，接下來我們意設定 grub 來永久化此設定。


Ref: https://hant.helplib.com/ubuntu/article_156236
- https://askubuntu.com/questions/1029474/ubuntu-18-04-dell-xps13-9370-no-longer-suspends-on-lid-close


# Can I get a awesome linux laptop ?(番外篇)

## i3 window management
## screen resolution
## i3lock
## natural scroll
## power management
## albert

