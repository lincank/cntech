---
layout: post
title: "修改dd-wrt固件来释放Jffs空间"
date: 2012-07-19 12:36
comments: true
categories: ddwrt autoddvpn
---

在给自己的Netgear WNDR3400刷dd-wrt固件并实现[autoddvpn](https://code.google.com/p/autoddvpn/)的gracemode的时候，遇到一个问题，就是刷完这个固件的时候，8M的空间已经用完。也就是说就算启用了Jffs，这个地方也没任务空间来给你放启动autoddvpn的脚本。先不管Jffs是什么东西，简单来说，就是让ROM的剩余空间可利用，能放一些自己的程序和脚本。把东西放在这里的好处就是路由器断电后你的东西依然在那里，不像RAM里的东西会丢失。前面说过，前面提到我这里用到Jffs主要是放autoddwrt的脚本用的，以实现全自动化。
<!-- more -->

在帮WNDR3400刷完ddwrt后发现它里面没空间让我放这些脚本后，我就在网上找有啥办法解决，因为若是每次断电都要手动设置一次的话就太麻烦了。我在网上找到以下两种方法：

* 如果你的路由刚好支持USB口的话, 就用U盘或者移动硬盘扩充容量, 这个很容易做到, 因为ddwrt本来就支持USB。但缺点是不是所有路由都支持USB。
* 修改固件，把一些你用不到的东西删除，就有多余的空间了。实际上你所要的空间并不是很多，只要几百kb就够用了，只是放几个脚本文件而已。

有USB的当然可以选择第一种方法，但其实在我看来第二种方法更加可取，因为它可以让你的autoddvpn离开USB也能使用，更加自成一体。修改固体听起来很玄，但如果有一点Linux基础就够了，只是敲几个命令而已，因为ddwrt官网上就有很详细的[修改固件教程](http://www.dd-wrt.com/wiki/index.php/Development). 英文好的人直接看原文就好了，这里只是方便一下英文苦手:)

### 步骤
在你选定了一个ddwrt固件版本并确保其能够在你的路由器上正常工作后，你就可以进行下列操作来修改固件了，我主要是删除一些没用的模块来释放一些空间给Jffs用。以下操作都是在Ubuntu下进行，你也可以选择其他Linux版本或者Mac OS X。


#### 先前准备 ####
Ubuntu下就很简单了，输入以下命令：

    sudo apt-get install gcc g++ binutils patch bzip2 flex bison make gettext unzip  zlib1g-dev libc6 subversion

再把用来修改固件的程序从SVN上下载下来：

    mkdir firmware_mod_kit
    cd firmware_mod_kit
    svn checkout http://firmware-mod-kit.googlecode.com/svn/trunk/ firmware-mod-kit-read-only
    cd firmware-mod-kit-read-only/trunk/
    
这样就准备好了工具。

#### 抽取固件 ####
用以下命令把`firmware.bin`的内容解压到`working_directory`当中.

    ./extract_firmware.sh firmware.bin working_directory/

#### 修改固件 ####
完成上一步后，就可以开始修改固件了。我这里是删除了里面几个没什么用的程序。我不确定自己是对的，所以就不放上来了，以免误导，但我的路由至今已经正常工作几个月了。如果也跟我一样不知道要删除哪里东西，可以像我一样用笨办法：在系统下的`bin`目录中挑几个，然后Google一下它是干什么用的，你就大概知道你要不要用到这个程序了。你删除多少也取决于你到底要多少空间。

此外也可以用`ipkg_install.sh`来安装软件包，OpenWrt网站上有很多可以选择的软件包。下载后用以下命令就可以安装：

    ./ipkg_install.sh some_package-1.2.5.ipk working_directory/
其中：

* **some_package-1.2.5.ipk**: 这是你下载的软件包
* **working_directory**: 你解压后的固件所在目录

#### 重新生成固件 ####
当你完成你想要的之后，就可以生成新的固件了。用以下命令：

    ./build_firmware.sh output_directory/ working_directory/

其中：

* **output_directory**: 这是新固件输出文件夹，如果原来里面有东西的话会被覆盖掉
* **working_directory**: 原来那个被修改的固件所在文件夹

它完成后会输出一些信息，其中之一就是`free space`，这个就是刷了这个固件并启动Jffs时，在Jffs上的可利用空间了。

