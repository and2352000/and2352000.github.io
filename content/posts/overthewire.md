---
title: "Overthewire"
date: 2019-02-07T14:01:30+08:00
draft: false
category: "Other"
tags: [ "hack", "secure", "wargame" ]
---
## Bandit
### Level0
```
Password : bandit0
```
### Level0->Level1
```
Password : boJ9jbbUNNfktd78OOpsqOltutMc3MY1
```
### Level1->Level2
```

```
### Level2->Level3
```

```
### Level3->Level4
```

```
### Level4->Level5
```
Password : pIwrPrtPN36QITSp3EQaw936yaFoFgAB
```
### Level5->Level6
```
Password : koReBOKuIDDepwhWk7jZC0RTdopnAYKh
```
### Level6->Level7
```
Password : DXjZPULLxYr17uwoI01bNLQbtFemEgo7
```
### Level7->Level8
```
Password : HKBPTKQnIay4Fw76bEy8PVxKEDQRKTzs
```
### Level8->Level9
```
Password : cvX2JJa4CFALtqS87jk27qwqGhBM9plV
```
### Level9->Level10
```
Password : UsvVyFSfZZWbi6wgC7dAFyFuR6jQQUhR
```
### Level10->Level11
```
Password : truKLdjsbJ5g7yyJ2X2R0o3a5HQJFuLk
```
|
|
|
|
|

### Level17->Level18
```
Password : kfBf3eYk5BPBRzwjqutbbfE887SVc5Yd
```
### Level18->Level19
```
$ ssh bandit18@bandit.labs.overthewire.org cat readme
IueksS7Ubh8G3DCwVzrTd8rAVOwq3M5x

Password : IueksS7Ubh8G3DCwVzrTd8rAVOwq3M5x
```
:::info
:mag:ssh後面可以接指令，當ssh執行指令完成後，預設會中斷連線。

:::

### Level19->Level20
```
$ ./bandit20-do cat /etc/bandit_pass/bandit20

Password : GbKksEFF4yrVs6il55v6gwY5aVje5f0j
```
:::info
:mag: setuid : 在執行程式時，程式執行的身份為啟動該程式的user，若設為setuid，則該程式在執行身份就改為該程式的Owner。
:::
### Level20->Level21
```
//使用tmux 開啟兩的terminal
$ tmux

//進入terminal 0,並進入terminal 1
$tmux new-window

//使用nc -l 開啟一個port,並把要傳輸的檔案放入
$ nc -l 32123 < /etc/bandit_pass/bandit20

// ctrl+b 再按0,進入termainal 0
$./suconnect 32123

Password : gE269g2h3mw3pwgrj0Ha9Uoqen1c9DGr
```
:::info
:mag: 指令tmux 可以在同一個視窗管理不同session的terminal
:::

### Level21->Level22
```
Password : Yk7owGAcWjwMVRwrTesJEwB7WVOiILLI
```
:::info
:mag: 學會cron排程使用方法
:::

### Level22->Level23

```
Password : 
```