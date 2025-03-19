---
title: "Micro Service - Saga"
date: 2024-08-07T16:06:44+08:00
draft: true
category: ""
tags: ["microservice"]
---
Solution 1: Two Phase Commit

Saga Pattern

ACID transactions
- Atomicity is a set of operations that must occur together or none at all.
- Consistency means that the transaction takes data from one valid state to another.
- Isolation guarantees that concurrent transactions would produce the same data state that transactions executed sequentially would have produced.
- Durability ensures that transactions that are committed remain that way when our systems fails.

Approach 1: Choreography  
Approach 2: Orchestration  

https://www.youtube.com/watch?v=xDuwrtwYHu8

