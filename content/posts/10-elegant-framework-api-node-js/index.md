---
title: "用 Node.js 打造 Elegant API Framework：awilix、zod、zod-openapi 的導入與改變"
date: 2025-03-18T16:06:44+08:00
draft: false
category: ""
tags: ["nodejs", "koa", "zod", "api"]
---

# 用 Node.js 打造 Elegant API Framework：awilix、zod、zod-openapi 的導入與改變

今天我要來聊聊我的專案：[Elegant API Framework for Node.js](https://github.com/and2352000/elegant-api-framework-node-js)。這個 API 框架目標是讓 Node.js API 專案開發變得更優雅，使用 `awilix`、`zod` 和 `zod-openapi` 這三個工具，讓我的專案變得更乾淨、更易於維護。

---

## 專案初衷：優雅與結構並存

我一開始做這個框架的時候，就想要解決 Node.js 開發中常見的痛點：依賴管理亂七八糟、資料驗證麻煩、API 文件難產。我用過 Express、Koa，也看過 NestJS 的做法，NestJS 基本上跟 Spring Boot 很像，NestJS 使用 TypeScript 的裝飾器來定義控制器、服務和其他組件，這與 Spring Boot 使用註解（Annotations）來配置應用程式的方式相似，但我很不喜歡被整個框架綁住，有時候覺得框架的存在限制的程式的擴展性，於是，我決定自己動手，打造一個既有彈性又有結構的框架。

---

## 導入 awilix：依賴注入的救贖

### 為什麼選 awilix？
為了測試容易，我需要能夠輕鬆替換依賴，於是我開始找依賴注入（DI）的解決方案，我以前寫 Node.js 時，依賴管理全靠手動，以下是我之前為了達到 Dependency Injection 的寫法，這個寫法只能達到單例模式。
```javascript
// 手動依賴注入
export class UserService {
  private static instance: UserService;
  private constructor(private readonly db: Database) {}

  public static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService(new Database());
    }
    return UserService.instance;
  }
}

```

NestJS 的 DI 很強，但太重量級；InversifyJS 也不錯，但也要依靠實驗性的功能 `reflect-metadata` 這點我不是很喜歡。最後我發現了 `awilix`，一個輕量又直觀的 DI 容器，完美符合我的需求。

### 怎麼用的？
我用 `awilix` 來管理所有的服務、控制器和儲存庫，把每個模組註冊到一個容器裡，然後在需要的地方自動解析。例如：

```javascript
const { createContainer, asClass, asFunction } = require('awilix');

// 設定容器
const container = createContainer()
  .register({
    userService: asClass(UserService).singleton(),
    userController: asClass(UserController).transient(),
    db: asFunction(() => new Database()),
  });

// 控制器裡直接用
class UserController {
  constructor({ userService }) {
    this.userService = userService;
  }

  async getUser(req, res) {
    const user = await this.userService.findById(req.params.id);
    res.json(user);
  }
}
```

這裡注意你的取名必須要跟你 inject 服務一樣，也就是說同一個 module 可以有多個 inject 實例，你可以用不同的 Pattern 來達到不同的效果，這裡是[官方](https://github.com/jeffijoe/awilix)的原文三種不同的 Lifetime:

- Lifetime.TRANSIENT: This is the default. The registration is resolved every time it is needed. This means if you resolve a class more than once, you will get back a new instance every time.
- Lifetime.SCOPED: The registration is scoped to the container - that means that the resolved value will be reused when resolved from the same scope (or a child scope).
- Lifetime.SINGLETON: The registration is always reused no matter what - that means that the resolved value is cached in the root container.

以上就可以讓你的服務和相依解耦，但他有一個缺點就是注入的時候是沒有型別的所以這邊就沒辦法直接點擊跳轉

## 導入 zod：資料驗證
### 為什麼選 zod？
API 框架少不了資料驗證，主流的驗證套件還有 Joi、Ajv，我選則 zod 單純是因為他跟 TypeScript 的整合的很好，當然他速度快而且輕量，它的語法簡潔，還能直接從 schema 推導出 TypeScript 型別，省下我手動寫介面的時間，這個優勢在於可以上程式碼的一致性很有有效地被維護，也打量減少需要維護的開發文件。

在我的框架裡，zod 負責處理所有的輸入驗證。比如定義一個用戶的 schema：

```javascript
userRouter.get('/', async (ctx) => {
    //NOTE: ！！！這一段 userController 是沒有型別的，相依也是從這裡開始注入
    const user = await container.resolve('userController').getUser(ctx.request.params)
    ctx.body = user;
})
```

```javascript
const { z } = require('zod');
import { routerSchemaCheck } from '../middleware/validator';

export const postUserSchema = {
    // Openapi 需要用到的定義 
    path: '/user',
    method: 'post',
    tags: ['user'],
    // 定義 schema
    body: z.object({
        name: z.string()
    }),
}

userRouter.post('/', routerSchemaCheck(postUserSchema), async (ctx) => {
    const body = ctx.request.body as z.infer<typeof postUserSchema.body>;
    const user = await container.resolve('userService').createUser(body.name)
    ctx.body = user;
})
```
從路由可以看到，我們定義了一個 post 的 user 路由，並且使用 `routerSchemaCheck` 這個 middleware 來檢查輸入的資料是否符合我們定義的 schema，如果符合，就會把資料轉換成我們定義的型別，並且傳遞給 controller 處理，如果資料不符合預期，不但會回傳錯誤還會指出正確的欄位以及可以填入的資料(包括對 enum 的支持)
routerSchemaCheck 的實作如下：
```javascript
export function routerSchemaCheck (schema: SchemaCheck) {
  return async (ctx: Context, next: Next) => {
    try {
      if (schema.body) {
        ctx.request.body = schema.body.parse(ctx.request.body)
      }
      if (schema.query) {
        ctx.query = schema.query.parse(ctx.query)
      }
      if (schema.params) {
        ctx.params = schema.params.parse(ctx.params)
      }
      await next()
    } catch (error) {
      if (error instanceof ZodError) {
        createErrorResponse(ctx, new RouterSchemaCheckErrorResponse('Parameter validation failed'), error)
      } else {
        throw error
      }
    }
  }
}

class RouterSchemaCheckErrorResponse extends ErrorResponse {
  constructor (message: string) {
    super('router-schema/check-error', message, 400)
  }
}
```
Error response 的回應如下：
```json
{
  "code": "router-schema/check-error",
  "message": "Parameter validation failed",
  "data": {
    "issues": [
      {
        "code": "invalid_type",
        "expected": "string",
        "received": "undefined",
        "path": [
          "name"
        ],
        "message": "Required"
      }
    ],
    "name": "ZodError"
  }
}
```
## 改變了什麼？
- 型別安全：從 userSchema.parse() 出來的資料直接有 TypeScript 型別，不用再自己定義 interface，爽度爆表。
- 錯誤處理超直觀：zod 的錯誤訊息清晰到不行，還能自訂，API 的回應品質直接提升。
- 開發效率：以前驗證邏輯散在各處，現在統一用 schema，既乾淨又好維護。
- 心得？zod 不只是驗證工具，它簡直是 TypeScript 生態的秘密武器，讓我的框架在處理輸入資料時又快又穩。

## 導入 zod-openapi：API 文件的自動化
zod 擁有豐富的插件這邊可以看到[zod 的插件](https://www.npmjs.com/package/zod)  
API 文件是一個很麻煩的東西，當團隊一大就會希望有文件來作為溝通的橋樑，手動寫 openapi 文件又累又容易過時。 zod-openapi 是 zod 的擴充，可以把 zod schema 直接轉成 OpenAPI 規格，還能輸出標準的 JSON 文件，那至於要怎麼去選擇UI 就看自己的需求。  

至於怎麼把 openapi 的 document 產出來 幾本上就是寫一個小的插件去掃描所有 router 的 schema 根據上面的定義去產出，細節就不詳述有興趣的可以看

產出來的資料長這樣：
```json
{
  "openapi": "3.1.0",
  "info": {
    "title": "Elegant API Framework",
    "version": "1.0.0"
  },
  "servers": [
    {
      "url": "http://localhost:6969",
      "description": "Local Development"
    }
  ],
  "paths": {
    "/user": {
      "post": {
        "tags": [
          "user"
        ],
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "properties": {
                  "name": {
                    "type": "string"
                  }
                },
                "required": [
                  "name"
                ]
              }
            }
          }
        },
        "responses": {
          "200": {
            "description": "Success"
          }
        }
      },
      "get": {
        "tags": [
          "user"
        ],
        "responses": {
          "200": {
            "description": "Success"
          }
        }
      }
    }
  }
}
```
然後這個 spec 可以直接丟給 Swagger UI 或其他工具，生成漂亮的 API 文件。

## 總結
---
這篇文章中，我們探討了如何建立一個優雅的 Node.js API 框架，主要聚焦在以下幾個關鍵點：

1. **程式碼即文件**：透過 OpenAPI 規範，我們讓 API 的定義和文件成為程式碼的一部分，確保文件永遠與實際實作同步。
2. **開發者體驗優先**：設計框架時以開發者體驗為核心，提供清晰的 API 結構和自動生成的文件，大幅降低學習和使用成本。
3. **自動化與一致性**：透過框架的設計，我們實現了 API 定義、驗證和文件的自動化，同時確保了跨專案的一致性。
4. **減少重複工作**：不再需要手動維護文件或編寫重複的驗證邏輯，讓開發者可以專注於業務邏輯的實現。

這種方法不僅提高了開發效率，也確保了 API 的品質和可維護性，特別適合需要快速迭代和長期維護的專案。






