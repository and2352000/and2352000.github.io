---
title: "Manage Nodejs Heap in Docker"
date: 2024-02-26T15:07:57+08:00
draft: false
category: "NodeJs"
tags: ["code", "nodejs"]
---

## Container 記憶體調整
在 local 調整 container 記憶體如下
```
docker run --memory 1024m --interactive --tty ravali1906/dockermemory bash
```
但是這樣會有一個問題，有由於 container default 有 swap，所以即便用超過也不會Out of memory  

這段程式碼程式碼會 allocate  1024MB
```
const buf = Buffer.alloc(+process.argv[2] * 1024 * 1024)
console.log(Math.round(buf.length / (1024 * 1024)))
console.log(Math.round(process.memoryUsage().rss / (1024 * 1024)))
``` 

執行結果
```
$ node buffer_example 2000
2000
16
```
以上這段程式碼是參考 ref1 其實是有問題的 Buffer.alloc 並不會用使用到 heap  

我有重新實作但是還不完整.....

- memoryUsage 有四個資訊  
  1. heapTotal and heapUsed refer to V8's memory usage.
  2. external refers to the memory usage of C++ objects bound to JavaScript objects managed by V8.
  3. rss, Resident Set Size, is the amount of space occupied in the main memory device (that is a subset of the total allocated memory) for the process, including all C++ and JavaScript objects and code. 
  4. arrayBuffers refers to memory allocated for ArrayBuffers and SharedArrayBuffers, including all Node.js Buffers. This is also included in the external value. When Node.js is used as an embedded library, this value may be 0 because allocations for ArrayBuffers may not be tracked in that case.

如果要檢查 container 的記憶體大小可以看這裡
```
cat /sys/fs/cgroup/memory.max
```


- NodeJs Resident Set 示意圖
![NodeJs Resident Set](images/nodejs_resident_set.png)
如果要把限制或擴增 memory 的總數要透過 V8 參數設定，每一個 Nodejs 的版本對於記憶體的最大值有所不同尤其是 32bit的版本


## 查看 Heap 參數
由於 NodeJs 是由 V8 engine 來管理記憶體，所以如果要調整想關參數要參閱 V8的設定
```
node --v8-options
# 其中 max_old_space_size 可以用來調整 heap 大小
node --v8-options | grep "max_old_space_size"
```

## Debug Tool
Open [chrome://inspect](chrome://inspect)
```
node --inspect index.js
# NOTE: In container
node --inspect-brk=0.0.0.0 --max_old_space_size=2000  index.js 200
```

## Reference
- [IBM Node.js memory management in container environments](https://developer.ibm.com/articles/nodejs-memory-management-in-container-environments/)
-  https://levelup.gitconnected.com/understanding-call-stack-and-heap-memory-in-js-e34bf8d3c3a4
-  [Share Buffer In Nodejs](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer)
-  [NodeJs memoryUsage](https://nodejs.org/api/process.html#processmemoryusage)