---
layout: post
title: "从Mac OS Finder获取Photo Stream里的照片"
date: 2012-07-16 11:40
comments: true
categories: 
---
此帖源自[Access the iOS Photo Stream from the Mac OS X Finder](http://osxdaily.com/2012/05/18/access-ios-photo-stream-from-mac-os-x-finder/)，我觉得应该有不少人有这样的需要，所以大致翻译过来方便英文苦手:) 不过本人的系统也是英文的，有些还是保留了英文，因为我实在不知道中文系统里叫什么:P

很多情况下我们要把Iphone上的照片传到Mac上，最原始的方法就是用数据线，或者用其他支持多客户端的网盘，如Dropbox，坚果云等。但就我个人经验来看，直接使用苹果的Icloud的PhotoStream应该是最方便的。

<!-- more -->

但即便用PhotoStream也有一个问题，就是同步到Mac后要用Iphoto软件获取，只能在这软件里操作。很多情况下你大概跟我一样想在Finder里找到这张照片，以便上传到其他地方，或是用其他软件润色。这时候，你还要从Iphoto里导出来，不甚方便。

本文介绍的方法就是直接在Finder里找到从iOS设备的PhotoStream同步过来的照片，不用额外额外导出。其原理就是，实际上，iPhoto从PhotoStream里获取这些照片的时候已经把他们下载到本地，而文件夹名称都是哈希码，一般情况下很难找到你想要的。这个方法是利用Mac OS自带的搜索功能。

使用本方法前有些基本要求：

* Mac OS X 10.7.2以上，并配置了iCloud
* 要同步的iOS设备也配置了iClooud，并且开启PhotoStream

## 具体步骤 ##
打开iPhoto软件，点PhotoStream刷新一下，让它把PhotoStream里最新的照片下载下来。然后你就可以关掉它了。

1、在Finder里，用快捷键"Command + Shift + G"呼出"Go To Folder"对话框，输入以下路径：
    ~/Library/Application Support/iLifeAssetManagement/assets/sub/

![PhotoStream Folder](/images/2012-7-photostream-folder.jpg)

2、按"Command + F"，在右上方的搜索选择"Kind:Image"，也就是搜索图片类型。这时你应该可以在窗口中看到你PhotoStream里的照片了。
**注意**：不要让搜索范围在"This Mac"上，要选当前目录"sub"，不然会把本机上所有图片都搜索出来的。

![Image Search](/images/2012-7-image-search.jpg)

3、你当然不希望每次要找这些照片的时候搞这么多操作，可以点"save"来保存这次搜索，为它起个名字，如"PhotoStream"，再点"Add To Sidebar"把它添加到侧边栏。以后只要点侧边栏的"PhotoStream"就可以找到PhotoStream里的照片了！当然你还是要用iPhoto来下载PhotoStream里的照片才能在这里找到它们。

大功告成！



