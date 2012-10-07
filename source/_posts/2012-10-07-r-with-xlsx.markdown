---
layout: post
title: "R with xlsx"
date: 2012-10-07 21:27
comments: true
categories: R
---

R语言在统计学上用得比较多，它是开源的，再配合上做的非常棒的开源IDE--[RStudio](http://rstudio.org/)，确实是一个很强大的工具。以前在学校的时候用Matlab比较多，但一接触R这个工具，还是觉得非常强大的。

很多时候数据都是以Excel文档的形式出现的，而在[CRAN](http://cran.r-project.org/)上有一个专门处理xlsx文档的库，就叫`xlsx`。

下面是我帮朋友写的一个用来合并多个格式一样的xlsx文档的。可看看`xlsx`这个库的基本用法。第一次用R，写的不算太好，大家将就一下，抛砖引玉:)

代码可以在[Github](https://gist.github.com/3847275)上找到，我在Windows跟Mac下测试过没问题，Linux虽然没测但相信也应该没问题的。


