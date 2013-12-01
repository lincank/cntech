---
layout: post
title: "Install Linux Driver For FAST FW150US"
date: 2013-12-01 15:25
comments: true
categories: [linux, 8188eu, FW150US]
---

#  FAST FW150US USB无线网卡Linux驱动安装


我是Ubuntu环境，其他Linux的安装方便应该都一样。


首先插入网卡，用`lsusb`找到设备ID，后面有Realtek那个就是，如：`0bda:8179`。可能出现`0bda:8176`的情况，网上已经有针对`0bda:8176`的文章，这里主要写给`0bda:8179`的情况。`8179`对应的是RTL8188EUS芯片，坑爹的Realtek官网上竟然没有给Linux的驱动，不过还好有人在Github上放出来。
<!-- more -->
前往[Github](https://github.com/lwfinger/rtl8188eu/archive/master.zip)下载驱动，解压后进入文件夹，运行以下命令：

	make
	
如没有出错，进行安装：

	sudo make install
	
没出错的话，重启后就可以用了。不过也可以让它立刻生效：

	sudo modprobe 8188eu
	
这里运行`ifconfig`应该可以看到`wlan0`无线连接。
	

> 参考文献：[RTL8188EUS wireless devices in Linux Mint 13](http://community.linuxmint.com/tutorial/view/1344)