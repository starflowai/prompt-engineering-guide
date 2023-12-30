---
slug: /langchain-js/how-to-count-the-token-usage-and-cost-of-a-large-model
---


# 如何统计大模型使用的 token 使用量和花费


统计调用大模型的 token 使用量，进而统计整体的账单花费，是一个非常基础的需求，在 LangChain.js 中统计 token 的方式有两种，一种是方法的返回，一种是利用回调函数：

1️⃣ 在[方法](https://js.langchain.com/docs/modules/model_io/models/chat/#generate)中返回 token 的使用情况，比如 `generate()`：

```js
const chat = new ChatOpenAI({
  modelName: 'gpt-4',
  openAIApiKey: 'YOUR_KEY',
})

const response = await chat.generate([
  [
    new SystemMessage(
      "你是一个翻译专家，可以将中文翻译成法语。"
    ),
    new HumanMessage(
      "把这个句子翻译从中文翻译成法语：我特别喜欢上班"
    ),
  ]
]);
```

`generate()` 方法会返回如下：
```json
{
  "generations": [
    [
      {
        "text": "J'aime beaucoup travailler."
        //...
      }
    ]
  ],
  "llmOutput": {
    "tokenUsage": {
      "completionTokens": 16,
      "promptTokens": 17,
      "totalTokens": 33
    }
  }
}
```

 `llmOutput` 字段包含我们整个的 token 使用量，其中 `promptTokens` 对应的是**输入**的 token，`completionTokens` 对应的是**输出**的 token，对于 OpenAI 来说，输入输出的[价格](https://openai.com/pricing)是不一的，如下表：

|  模型名                          |  输入                   | 输出                  |
|--------------------------------|-------------------------|-------------------------|
| gpt-4    | &#36;0.03 &#47; 1K tokens | &#36;0.06 &#47; 1K tokens |
| gpt-3.5-turbo-1106  | &#36;0.0010 &#47; 1K tokens | &#36;0.0020 &#47; 1K tokens |
| gpt-4-1106-preview             | &#36;0.01 &#47; 1K tokens | &#36;0.03 &#47; 1K tokens |
| gpt-4-1106-vision-preview      | &#36;0.01 &#47; 1K tokens | &#36;0.03 &#47; 1K tokens |


2️⃣ 使用[回调函数](https://js.langchain.com/docs/modules/callbacks/) `handleLLMEnd`

LangChain 提供了大量方便的回调函数，我们可以利用其提供的内置的 `handleLLMEnd()` 函数来统计，我们可以在创建 `ChatOpenAI` 实例的时候注入回调函数：

```js
const chat = new ChatOpenAI({
  modelName: 'gpt-4',
  openAIApiKey: 'YOUR_KEY',
}, {
  callbacks: [
    {
      handleLLMEnd(llmResult) {
        console.log(JSON.stringify(llmResult, null, 2))
      },
    }
  ]
})
```

> 回调参数 `llmResult` 和 `generate()` 方法返回值是一样的，同样有包含 `tokenUsage`


另外也可以在调用的时候再注入回调函数，可以更精细地统计：
```js
model
  .invoke(
    [
      new SystemMessage('Only return JSON'),
      new HumanMessage('Hi there!')
    ],
    {
      callbacks: [
        {
          handleLLMEnd(llmResult) {
            console.log(JSON.stringify(llmResult, null, 2))
          },
        },
      ],
    }
  )
```