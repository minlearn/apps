[演示与特性](#演示与特性) | [下载安装及用法](#下载安装及用法) | [服务及支持](#服务及支持)

discuss: 省事一键轻量可联合社交化平台(可cf部署)🚀🎉
=====


鉴于现在的主机论很难玩又融入奇特化
发布这个新的创新选择小玩具

> 全称为discuss，省事一键轻量可联合社交化平台 ..  

项目地址：[https://github.com/minlearn/appp/tree/master/_build/discuss](https://github.com/minlearn/appp/tree/master/_build/discuss)

演示与特性✨
-----


![](https://github.com/minlearn/appp/raw/master/_build/discuss/assets/discuss.png)



下载安装及用法📄
-----

共3步

### 第一步. Fork本仓库到你的GitHub帐号

登你的github，然后点击 https://github.com/minlearn/appp/fork 把仓库fork到你的github帐号

### 第二步. 在你fork到的仓库里面加几个部署相关的密码变量

进入你fork到的仓库的 [Settings -> Secrets -> Actions](../../settings/secrets/actions), 创建几个部署相关的密码变量，共3个（最后2个r2相关的不需要），如何获取这些变量及如何复制为变量(请展开查看细节)：  

![](https://user-images.githubusercontent.com/1719237/205524410-268abf92-af61-467a-8883-78b8d4de3c56.png)

<details>
<summary><b>如何获得CLOUDFLARE_ACCOUNT_ID变量</b></summary>
登录cf面板会自动跳到:https://dash.cloudflare.com/[你的帐号id]  ，比如这样：https://dash.cloudflare.com/fff88980eeeeedcc3ffffd4f555f4999，  后面的 * fff88980eeeeedcc3ffffd4f555f4999 * 就是帐号id  
将其复制到仓库的[Settings -> Secrets -> Actions](../../settings/secrets/actions) 处即可，注意复制到不要有多余字符，会显示为星号，
<IMG src="https://user-images.githubusercontent.com/1719237/208216752-56f00f51-29cb-43ea-b720-75244719898d.png"/>
</details>

<details>
<summary><b>如何获得CLOUDFLARE_API_TOKEN变量</b></summary>
登录cf，定位到: https://dash.cloudflare.com/profile/api-tokens  创建一个custom token:  
<IMG src="https://user-images.githubusercontent.com/1719237/205525627-14da54ae-1733-4db5-b65d-94f5ec48f360.png"/>
修改token的权限，放行Cloudflare Pages 和 D1:
<IMG src="https://user-images.githubusercontent.com/1719237/205525675-4c8a6bce-21a8-45e3-bf0c-28981f123da3.png"/>
像复制帐号id一样复制为仓库的对应名字变量
</details>


<details>
<summary><b>给要部署到cf的整套应用取一个名字前缀CLOUDFLARE_PROJECT_NAME</b></summary>
随便都可以，就是不要带._等特殊符号，比如你取名为discuss，或discussmyxxxdomain都可以
像复制帐号id一样复制为仓库的对应名字变量
</details>


### 第三步. 在你fork到的仓库里面运行名为updatebuilddiscuss的部署

前往 [Actions -> Deploy to Cloudflare Pages](../../actions/workflows/deploy.yml) 运行deploy  
![](https://user-images.githubusercontent.com/1719237/205526856-05ea0ff4-703a-4d08-bc7f-4ae2dfc07cfe.png)


### 最后，检查结果

等部署完毕, 绿点表示成功. 你可以在 [Cloudflare dashboard](https://dash.cloudflare.com/sign-up/pages) 处看到已生成形式为 CLOUDFLARE_PROJECT_NAME变量.pages.dev 的pages应用，点击即可访问


### 更新/修改设置：

在fork的git仓库里编辑dist/_workers.js源码，找到以下并修改，注意格式，比如，public后面的默认on改成off可打开邀请及关闭公开浏览贴子

```
{"sitetitle":"Discuss","dismissmessage":"第一款能在cf上运行的自建轻量联合主机社区程序,自带主机管理前端https://github.com/minlearn/appp/tree/master/_build/discuss, 相关咨询联系tg：https://t.me/minlearn_1keydd","public":"on"}
```

然后覆盖部署即可

常规操作在论坛界面上即可操作。其它的将用户设为仲裁员和增加注册码的工作，请直接在d1数据库中操作。

regcodes:  

| body            | isredeemed | redeemedto |
| :------:        | :-:        | :-: |
| 你要发放的邀请码   |  0         | 留空，邀请码被使用时会自动变成1 |

users:  

| ...            | roletags |
| :------:       | :-:        |
| ...            |  admin为超管,mod为仲裁,留空为普通成员         |


* 部署到本地或vps  

参照项目顶层的discuss_install.sh，在装有debian的vps上运行此脚本即可。  

> Wrangler v3 默认使用了Miniflare v3,而Miniflare v3使用了workerd, workerd不仅是支持wrangler本地调试的worker模拟环境，而且是产品级的nodejs runtime，所以可供本地直接部署worker/pages用。  

服务及支持👀
-----

项目及项目关联（见文尾），可为分免费部分和服务性收费部分，大部分免费公益性服务，仅对要求作者动手的服务收费，项目和社区维护需要长期付出大量精力，请捐助或付费支持作者：  

如何支持：

 * 本人长期接有偿付费dd含解决疑难机型DD问题和定制dd镜像服务/定制pve lxc app服务，价格各60元起，不成功不收费，附加10元可加群：  
`怎么联系: 点击如下作者个人tg地址，简单说明需求或说明来意即可，不要说你好，在吗。直接说事`  
[minlearn_1keydd](https://t.me/minlearn_1keydd)

 * 本人维护有一个tg群和一个内部论坛，直接捐赠打赏60元/10U起加群,可终身免费咨询inst+1kdd技术支持+给discuss提issue+更多不定期福利，你可任意捐助打赏我任意数值虚拟币：  
`怎么捐助/付款: 用支持tron链的钱包或交易所APP扫描下列钱包地址(走链将u转成trx手续费最低，交易所内转0手续)，将支付截图或交易HASH发送到上面tg地址后，等待作者将你tg邀入群和内部社区`  
BINA: [TTdYbcFMBLHSsw9yrrdRn8jMAFFC7U4Byp](https://tronscan.io/#/address/TTdYbcFMBLHSsw9yrrdRn8jMAFFC7U4Byp)，内部id：878248518  
OKEX: [TPvrETkN21H8fagFjyYAECihyRhrRAMCTR](https://tronscan.io/#/address/TPvrETkN21H8fagFjyYAECihyRhrRAMCTR)，内部id：292251340602744832  
![](https://github.com/minlearn/minlearnprogramming/raw/master/_build/assets/donate.png)

* 项目买断
`10000u = inst+1kdd+discuss全套ci构建源码, 全部协助转让`

-----

此项目关联 https://github.com/minlearn/ 下所有项目，主体为 https://github.com/minlearn/minlearnprogramming/ 和 https://github.com/minlearn/1kdd ，这是一套为配合我在《minlearnprogramming》最小编程/统一开发的想法的综合项目。  
本项目长期保存





