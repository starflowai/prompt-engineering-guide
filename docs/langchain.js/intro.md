---
slug: langchain-js/intro
position: 1
---


# LangChain.js 入门介绍

[LangChain.js](https://js.langchain.com/docs/get_started/introduction) 是一个快速构建 AI 应用的库，它提供了一系列的工具，可以帮助你快速构建一个 AI 应用。

LangChain.js 目前还在快速迭代中，这是由于 AI 技术自身也正在快速迭代中，所以很多功能可能很快就被废弃掉，比如 `generate()` 方法。

使用 LangChain.js 的好处有挺多，比如：

1. 封装了大量的模型，比如 OpenAI、Azure OpenAI、Claude、文心一言等等，填入响应的 API Key 等参数即可调用
2. 提供了大量方便的方法，比如链式调用、对话管理、回钩子等等
3. 和 LangSmith 结合，对 AI 应用可以很好地进行调试开发


## LangChain.js 的基本使用

### 调用模型

LangChain.js 新改版区分了两种调用方式，一种是**LLM**，一种是**ChatModel**，不过这两种调用方式本质都一样，最终都是调用模型，一般我们使用后者。

实例化 `ChatModel` ：

```typescript
import { ChatOpenAI } from "langchain/chat_models/openai";

const chatModel = new ChatOpenAI({
  openAIApiKey: "...",
});
```

这里 openAIApiKey 可以在实例化的时候传入，也可以放置在环境变量 `OPENAI_API_KEY` 中，这样就不用每次都传入了，LangChain 会自动从 `process.env` 读取。如果是 Azure OpenAI，那对应的就是 `AZURE_OPENAI_API_KEY`、`AZURE_OPENAI_API_INSTANCE_NAME`、`AZURE_OPENAI_API_DEPLOYMENT_NAME` 等等。

接着就可以调用模型：

```typescript
import { HumanMessage, SystemMessage } from "langchain/chat_models/messages";

const messages = [
  new SystemMessage("你是一位语言模型专家"),
  new HumanMessage("模型正则化的目的是什么？"),
];
```

这里的 SystemMessage 和 HumanMessage 都是 LangChain.js 提供的消息类，分别表示系统消息和用户消息。用户消息好理解，系统消息的话可以看作是针对 AI 模型的一个高级指令（instruction），比如 `SystemMessage("你是一位语言模型专家")` 就是告诉 AI 模型，你是一位语言模型专家，这样 AI 模型就会以这个身份来回答你的问题，`SystemMessage` 是可选的。

```typescript
await chatModel.invoke(messages);
```

这里的 `invoke()` 方法就是调用模型，它会返回一个 `Promise`，这个 `Promise` 的结果就是 AI 模型的回复，比如：

```typescript
AIMessage { content: 'The purpose of model regularization is to prevent overfitting in machine learning models. Overfitting occurs when a model becomes too complex and starts to fit the noise in the training data, leading to poor generalization on unseen data. Regularization techniques introduce additional constraints or penalties to the model's objective function, discouraging it from becoming overly complex and promoting simpler and more generalizable models. Regularization helps to strike a balance between fitting the training data well and avoiding overfitting, leading to better performance on new, unseen data.' }
```

### 流式传输

流式传输是一个基本功能了，一开始 LangChain 仅支持使用回调函数的方式来实现，比如：

```typescript
const chat = new ChatOpenAI({
  streaming: true,
});

const response = await chat.call([new HumanMessage("讲个笑话")], {
  callbacks: [
    {
      handleLLMNewToken(token: string) {
        console.log({ token });
      },
    },
  ],
});
```

这样每当模型返回的时候，都会触发 `handleLLMNewToken` 回调函数，新版 LangChain.js 更加灵活，使用 `.stream()` 方法可以实现同样的功能：

```typescript
const stream = await chat.stream([new HumanMessage("讲个笑话")]);

for await (const chunk of stream) {
  console.log(chunk);
}
```

这里的 `stream` 是一个 `AsyncIterableIterator`，可以使用 `for await` 来遍历，每当模型返回的时候，就会触发 `for await` 中的代码。

### JSON Mode

JSON Mode 是 OpenAI 新版的能力，它可以让你更好地控制 AI 模型的输出，比如：

```typescript
const jsonModeModel = new ChatOpenAI({
  modelName: "gpt-4-1106-preview",
}).bind({
  response_format: {
    type: "json_object",
  },
});
```
注意，目前仅 `gpt-4-1106-preview` 模型支持 JSON Mode，另外还有一个强制性的要求，就是 `SystemMessage` 必须包含 `JSON` 字眼：

```typescript
const res = await jsonModeModel.invoke([
  ["system", "Only return JSON"],
  ["human", "Hi there!"],
]);
```

后续 GPT 迭代 JSON Mode 应该就会变成通用能力，之语 `SystemMessage` 的规则，不知道后续会不会改变。

### 函数调用

函数调用（Function Calling）是 OpenAI 的一个重点能力，也就是目前 AI 应用和程序的一个重要交互协议。函数调用其实很简单，就是先让 AI 去选择调用哪个函数，然后在程序中调用真正的函数。

最常见的场景就是联网回答，你提供了「联网搜索」的函数，当用户提问「今天的重点新闻是什么」的时候，AI 会先调用「联网搜索」函数，然后根据函数执行得到的信息，最终再回答用户的问题。

OpenAI 使用 JSON Schema 来定义函数调用的协议，比如定义一个提取字段的函数：

```typescript
const extractionFunctionSchema = {
  // 定义函数的名字
  name: "extractor",
  // 定义函数的描述
  description: "Extracts fields from the input.",
  // 定义函数的入参有哪些
  parameters: {
    type: "object",
    properties: {
      tone: {
        type: "string",
        enum: ["positive", "negative"],
        description: "The overall tone of the input",
      },
      word_count: {
        type: "number",
        description: "The number of words in the input",
      },
      chat_response: {
        type: "string",
        description: "A response to the human's input",
      },
    },
    required: ["tone", "word_count", "chat_response"],
  },
};
```

也可以使用 `zod` 这个库，写起来更方便：

```typescript
import { z } from "zod";
import { zodToJsonSchema } from "zod-to-json-schema";

const extractionFunctionSchema = {
  name: "extractor",
  description: "Extracts fields from the input.",
  parameters: zodToJsonSchema(
    z.object({
      tone: z
        .enum(["positive", "negative"])
        .describe("The overall tone of the input"),
      entity: z.string().describe("The entity mentioned in the input"),
      word_count: z.number().describe("The number of words in the input"),
      chat_response: z.string().describe("A response to the human's input"),
      final_punctuation: z
        .optional(z.string())
        .describe("The final punctuation mark in the input, if any."),
    })
  ),
};
```

调用函数：

```typescript
const model = new ChatOpenAI({
  modelName: "gpt-4",
}).bind({
  functions: [extractionFunctionSchema],
  function_call: { name: "extractor" },
});
```

```typescript
const result = await model.invoke([new HumanMessage("What a beautiful day!")]);
```

```typescript
console.log(result);
/*
AIMessage {
  //...
  additional_kwargs: {
    function_call: {
      name: 'extractor',
      arguments: '{\n' +
        '"tone": "positive",\n' +
        '"entity": "day",\n' +
        '"word_count": 4,\n' +
        `"chat_response": "I'm glad you're enjoying the day!",\n` +
        '"final_punctuation": "!"\n' +
        '}'
    }
  }
}
*/
```