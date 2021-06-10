---
layout: post
title: Streaming birds using Raspberry Pi
author: czheo
---

最近几天，我家阳台经常出现了一只哀鸽(mourning dove)。
这是北美常见的一种鸟，它一大早就来，停在那里像是观察什么。

![dove1](/static/img/dove1.jpg)

前天，忽然出现了两只鸽子，一只趴在壁灯上，另一只衔来树枝给它，想必是要筑巢。
然而一天下来再去观察，由于壁灯上空间太小，树枝一根不剩全掉落在地上。

![dove2](/static/img/dove2.jpg)

于是昨天一大早，我用包装鸡蛋的纸盒，给它们搭了一个宽敞些的台子。
它们看起来甚是喜欢，雄鸟不断衔来新的树枝，雌鸟负责做窝，一整天下来鸟巢有了不少起色。

![dove nest](/static/img/dove_nest.jpg)

可是好景不长，傍晚时分我再去看时，地上树枝散落一地，还有一个碎掉的鸟蛋。
鸟巢还没造好，就失去一个未出世的孩子，想必非常可怜。
晚上，雌鸟在那里一动不动地趴了一夜。

![broken egg](/static/img/broken_egg.jpg)

今天一大早，我早早起床，看那雌鸟还在那里趴着。
不久，雄鸟飞来把它接走，我开始担心它们不会回来了。
不过趁它们不在，我又稍微加固了平台。
把原先三面围合的平台，做成了四面围合，希望这样鸟蛋不要再掉下来了。

几天下来，我和家人都非常牵挂这两只小鸟，希望它们能在阳台住下，抚育后代。
于是，我腾出手头的一台Raspberry Pi，搭设了一个观鸟的直播流，来更好地近距离观察它们的动静。

![raspberry](/static/img/rpi.jpg)

不一会后，它们终于回来了。
于是我美滋滋地看起了直播。

附录. 直播耗材：

1. Raspberry Pi 3B+ with Camera Module。用ffmpeg推送摄像头信号给Nginx。
2. 特地买了个6刀的DigitalOcean服务器，装上Nginx + rtmp-module，用来接收Raspberry Pi的视频信号，并作为直播服务器推送给最终客户端。
3. 在Github Page上添加了一个[新页面](http://czheo.github.io/bird)，用hls.js做客户端直播。