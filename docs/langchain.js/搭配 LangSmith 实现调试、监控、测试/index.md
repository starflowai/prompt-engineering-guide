---
slug: /langchain-js/langsmith
---

# 搭配 LangSmith 实现调试、监控、测试

[LangSmith](https://smith.langchain.com/) 是 LangChain 推出的 AI 应用调试、监控和测试平台。


![1704177470416](images/f7043cd495df65f8574ed14cf3026f2be168fe638cd6f81e10387b6cc70e24e1.png)


LangSmith 会记录大模型发起的所有请求，除了输入输出，还能看到具体的所有细节，包括：
1. 请求的大模型、模型名、模型参数
2. 请求的时间、消耗的 token 数量
3. 请求中的所有上下文消息，包括系统消息

![](https://img-blog.csdnimg.cn/direct/c41c394b430e4a7196fc3ebf015f58aa.png)

比较亮眼的功能是，LangSmith 可以把某条请求添加进 Playground，然后直接调试修改，重放该请求：

选中某条请求，点击「Playground」：


![1704177585318](images/bd2e23b64d68dc7290970af1fa6c587bebbf00748041a203af6a22ba1d854aab.png) 



进入 Playground 后，这条请求会包括原本的所有消息上下文、使用的模型、参数等等，我们就可以直接修改对应的提示词，点击「Start」去重放测试：


![1704177547822](images/5e84eaa75ed08682865fcb3af01e165292603ad9e634d03075f8ca5d0b37d85b.png)  



有这个重放功能，对于某些测试 case，就不需要费心先为这个 case 构建请求环境模拟，再调试提示词，直接在 Playground 就能直接调试提示词，相当方便了。

LangSmith 的集成挺简单的，只需要一个 API 和 URL 即可，我们直接进入官网：[https://smith.langchain.com/](https://smith.langchain.com)


![1704177599829](images/13eb507fa7a2bfa7b48414d8e0dbadd1101ecca27da4900c68df8dfc283b4e37.png)  





点击「Sign Up」，选择账号登录：



![1704177614327](images/b90f51777a1052ce0f120ab122fd644579b8d862f84c204a643e4498007c8a3c.png)  


LangSmith 目前还处于 **Beta** 阶段，可以免费使用，但是会有白名单使用机制，如下就是 LangSmith 审核你的名单，还不能使用：


![1704177626053](images/cbd3d0ac25ab98076129b27f7ab5c80d486ae139acc4ffcad544d309e6879896.png)  


静候 LangSmith 的审核，或者去 LangSmith 的仓库里请求一个邀请码：
[Request for Invitation Code - LangSmith](https://github.com/langchain-ai/langsmith-sdk/issues/246)


> 试过让已经进入 LangSmith 的朋友邀请进组织，不过不行
> ![1704177635837](images/1f065ae6f827b3de52358006b3693624cbe0d3c5f5e7801db66b49f9cbfa2e96.png)  


进入之后创建一个 API key：


![1704177648152](images/cb64ff2cfd160ec4b15fe054f143b6c4701317650ea1d2cd870c578fcde527ab.png)  


然后在项目下设置这几个环境变量：

```bash
LANGCHAIN_TRACING_V2="true"
# 请求的 URL
LANGCHAIN_ENDPOINT="https://api.smith.langchain.com"
# API key
LANGCHAIN_API_KEY="YOUR_API_KEY"
# 项目名称
LANGCHAIN_PROJECT="YOUR_PROJECT_NAME"
```

其中 `LANGCHAIN_PROJECT` 可以不用设置，它会默认记录到一个叫做 `default` 的项目下。

设置之后，调用 LangChain 的方法：[
LangChain.js 实战系列：入门介绍](https://blog.csdn.net/YopenLang/article/details/135307578)

发送的请求就都会记录到 LangSmith 上了：


![1704177659534](images/d0c2cc8b4fb6e7c2186783cc87b5db8a3d60dc6821a683e736ea17f86e179bae.png)  


其他的一些创建组织、创建项目等的常见功能可以自行体验，总的来说，LangSmith 目前对于开发调试一个 AI 应用来说很方便，不过这个项目属于闭源，并且会记录 API Key 一些敏感信息，因此是否使用 LangSmith 具体看自己的项目情况。