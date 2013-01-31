---
layout: post
title: "利用Bitbucket与Jenkins为Rails工程提供持续集成"
date: 2013-01-30 01:55
comments: true
categories: bitbucket jenkins rails ci centos

---
最近看到不少持续集成(CI，Continuous Integration)的东西，觉得挺有意思，就自己也搭了一个。主要就是每次push代码到Bitbucket后，CI server自动运行工程的rspec测试。

本文针对的环境是Jenkins 1.5, Centos 6.2, Rails 3。这里我结合自己基本上从零开始在Centos上部署Jenkins，的过程给个参考。此过程多少有些坑，不过网上搜搜基本能解决。不同环境可能有些差异，主要目的还是抛砖引玉:)

这里CI server选的是Jenkins，其他用得比较多的有像[CruiseControl](http://cruisecontrol.sourceforge.net/)和TeamCity等。选Jenkins主要是它现在用得比较多，社区比较活跃，各种你能想到或想不到的插件都有~lol

跟Github的集成不必多说，网上有很多，相信大家使用Bitbucket的原因，大概跟我一样：是它的私有库是免费的，而且是逆天的unlimited!!，不用都对不住人家了:P 

<!-- more -->

## Jenkins安装

## 依赖包安装
一些基本的包安装

	yum update
	yum install -y gcc automake autoconf libtool make patch httpd ruby ruby-devel readline-devel zlib-devel

## Java安装
Jenkins的官方文档说RHEL/Centos通过`yum`安装的Java有问题，最好直接到Oracle官网下个rpm包。我发现Oracle官网相当烦人，到其他地方找了一个:)

	wget http://uni-smr.ac.ru/archive/dev/java/SDKs/sun/j2se/7/jdk-7u11-linux-i586.rpm
	sudo rpm -Uvh jdk-7u11-linux-i586.rpm

装完后用`java -version`看看是否安装成功。


	
## NodeJs安装
Rails Asset Pipeline要求Javascript Runtime， 这里通过安装NodeJS来提供
	
	wget http://nodejs.org/dist/v0.8.18/node-v0.8.18.tar.gz
	tar xf node-v0.8.18.tar.gz
	cd node-v0.8.18
	./configure
	make
	sudo make install
	
	
## Jenkins安装
	wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
	rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
	yum install jenkins	
	
启动Jenkins

	chkconfig jenkins on
	service jenkins start
	
这时不出意外的话，已经可以通过`http://localhost:8080`访问Jenkins了。

### 安装Git Plugin
我看网上其他人都是在Jenkins里的Available Plugin里可以找到Git Plugin，在上面点几下鼠标就能装上，结果我找了几次都没找到 =_= 后来用Jenkins CLI在命令行下装的。

通过浏览器进去Jenkins，点Jenkins CLI后下载它那个`jenkins-cli.jar`，然后运行以下命令安装Git Plugin:

	java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin git

>有人知道为什么我在available plugins里找不到Git Plugin的话，请务必告诉我一下！


### Apache代理配置（可选）
这步是可选的，主要是让Jenkins可以直接通过http默认的80端口访问。新建`/etc/httpd/conf.d/jenkins.conf`，并加入以下内容：

	<VirtualHost *:80>
    	ServerAdmin webmaster@localhost
	    ServerName ci.infused.org
	    ServerAlias ci
	    ProxyRequests Off
	    <Proxy *>
	    Order deny,allow
	    Allow from all
	    </Proxy>
	    ProxyPreserveHost on
    	ProxyPass / http://localhost:8080/
	</VirtualHost>	

重启Apache

	chkconfig httpd on
	service	httpd restart
	
## RVM安装
安装Jenkins的时候，已经自动帮我们添加了`jenkins`用户，其Home目录位于`/var/lib/jenkins/`。但是不能登录。先修改用户属性让`jenkins`用户可登录，用`bash`作为默认shell
	
	sudo usermod -s /bin/bash jenkins

以`jenkins`用户登录系统，安装`rvm`以及`ruby 1.9.3`	
	
	sudo su - jenkins
	\curl -L https://get.rvm.io | bash -s stable
	rvm install 1.9.3
	gem install bundler
	
有些工程里用`.rvmrc`文件来指定rvm配置，比如使用哪一版本的ruby，在`/var/lib/jenkins/.rvmrc`加上以下这句，方便自动信任工程`.rvmrc`里的内容

	export rvm_trust_rvmrcs_flag=1
	
最后确保有以下类似内容`/var/lib/jenkins/.bashrc`，主要用来初始化rvm环境：

	PATH=$PATH:/usr/local/bin:$HOME/.rvm/bin # Add RVM to PATH for scripting
	if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then . "$HOME/.rvm/scripts/rvm"; fi
	

	


## Bitbucket设置
为`jenkins`用户生成`ssh key`

	ssh-keygen -t rsa

打开Bitbucket，找到你想运用Jenkins的repository，把刚刚生成的公钥（在`~/.ssh/id_rsa.pub`里）添加到相应repositroy的Deployment Keys。所谓Deployment Keys只有读取权限，没有push权限。

以`jenkins`用户运行一次以下命令，首次连接系统会问是否信任此host，回答`yes`将Bitbucket加入ssh信任host里。
>将[username]和[repository]换成你Bitbucket上相应的用户及代码库。
	
	git ls-remote -h git@bitbucket.org:[username]/[repository].git HEAD 

不出错就表示可以了。

## 连接Jenkins与Bitbucket
### Jenkins安全设置
Jenkins刚安装完，是允许所有访问Jenkins的人进行所有操作的，这样当然不安全，不过Jenkins提供了相当全面的权限控制，稍微设置下即可。

* 进入*Manage Jenkins -> Configure Global Security*，选上*Enable Security*，在出现的选项中，再选上*Jenkins's own user database*以及下面的*Allow users to sign up*和*Logged-in users can do anything*，保存

* 返回Jenkins主页面，这时右上角会有*sign up*，点击进去注册一个新用户
* 注册完成后再进入设置，把那个*Allow users to sign up*取消掉，不再让其他人注册
* 进入这个用户的设置界面，会有API Token，点*Show API Token*，记下这个token，在Bitbucket的设置上会用到


### Jenkins项目设置
* 点*New job*新建一个*free style*的。
* SCM那里选Git，在*Repository URL*里填上Bitbucket上这个工程的地址。
* *Build Triggers*那里选*Trigger builds remotely*，在*Authentication Token*填入随机字串，这个token呆会在Bitbucket设置的时候会用到，记下。

### Bitbucket项目设置
* 进入工程的*admin*，选Services，在Service下拉框中选**Jenkins**，按以下填入：
	* **Module name**：留空
	* **Token**：这就是在Jenkins的项目里，你自己填入随机字串的那个**Authentication Token**
	* **Project name**：Jenkins上的工程名字
	* **Endpoint**：`http://[Jenkins User]:[API Token]@[hostname]/`，如：`http://admin:xxxxxxxxxxx@jenkins.company.com/`

这样一来，每次你push代码到Bitbucket，它都会通知Jenkins去做你要让它帮你做的事情！

> 确保**Authentication Token**与**API Token**都跟你在Jenkins上的一致。

### Execute Shell
在Jenkins那个job configure下的**execute shell**里面的东西，就是你让Jenkins帮你做的事！以下例子，是每次push代码到Bitbucket，Jenkins都会帮你在新代码下执行rspec测试


	#!/bin/bash -x
	source ~/.bashrc		# load rvm environment
	rvm use 1.9.3			# use ruby 1.9.3
	bundle install			
	rake db:schema:load		# load database schema
	rake 					# run specs			
	
## Tips
* Jenkins的*Security Configure*在选择*Logged-in users can do anything*的情况下，虽然没登录不能进行相关操作，但还是能浏览到工程的信息，包括代码。如果你想更安全一些，可以选*Matrix-based security*，然后把你自己注册的那个用户加进去。这种安全模式下，权限管理更为灵活。
* 可以为你的注册的用户加上ssh key，这样使用Jenkins CLI就不用输入账号密码。


## 参考资料

* [Jenkins With RVM](https://gist.github.com/1464429)
* [Hooking Bitbucket Up With Jenkins](http://felixleong.com/blog/2012/02/hooking-bitbucket-up-with-jenkins)
* [Rails Jenkins](http://rails-jenkins.danseaver.com/#1)