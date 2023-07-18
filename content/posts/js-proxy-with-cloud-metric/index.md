---
title: "Monitor Third Party Source Through JS proxy and Google Cloud Metric "
date: 2023-07-18T14:01:30+08:00
draft: false
category: "Infrastructure"
tags: [ "cloud", "javascript", "sre" ]
---

## Problem Face
There's too many function or class will build and each client (class of third party library). We need a general solution to help us to monitor different source from multiple vendor also each function of class.
- What we want to know?
The following data Request Count, Response Count, Response Error Count can be aggregated according to the number of days or counted independently according to different types of functions, blockchains and suppliers, while maintaining flexibility
##  Javascript proxy
The Proxy object enables you to create a proxy for another object, which can intercept and redefine fundamental operations for that object. [MDN JS Proxy](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy)
```javascript
class Client {
  getDataA(): string { return 'This is A' }
  getDataB() { throw new Error('Something wrong with B') }
}

const client = new Client();
const clientProxy = new Proxy(client, {
  get: (target, prop) => {
    console.log('Function ', prop)
    return () => { return 'hello' }
  }
});

console.log(clientProxy.getDataA())
console.log(clientProxy.getDataB())
```
[example](https://www.typescriptlang.org/play?ssl=15&ssc=36&pln=1&pc=1#code/MYGwhgzhAEDCIEsCmA7ALtA3gKGtA5kmgCJhpgCCAFAJQBc0EaATgivltM0QK7MrQA5ABUAFghgToFQdAC+uAkVLkAQrU5pRzAPYB3aCiQGAos13MqggMo6AtkXHtoe3c70It0VYJrzsCtjAOihM0KDI6NAAvIbGcIioaLQA3EEhYRFJAAq6AB4AnjFxBrk6hVRZ6AA0WIqEaAxU5MwNtQAOuu1+0QB8dXh4waE6IEgAdCA6+FYAYjwowGgIIUIdXTSKeNxofAIafZw7e0KiSCBTsgp4CnI0aekjY5PTlYnoZYXjDSqUtJvDCCjCZTGZVNCfArfZRkMDqGg0IA)
## Metric

What are metrics?
In layperson terms, metrics are numeric measurements. Time series means that changes are recorded over time. What users want to measure differs from application to application. For a web server it might be request times, for a database it might be number of active connections or number of active queries etc.[Ref](https://prometheus.io/docs/introduction/overview/)
- Logbase Metric
Logs are emitted from almost every program and write every detail down. We can analytic data later. [Google LogBase Metric](https://cloud.google.com/logging/docs/logs-based-metrics)
- Promethus metric
Prometheus scrapes metrics from instrumented jobs, either directly or via an intermediary push gateway for short-lived jobs. [Prometheus Metric](https://prometheus.io/docs/introduction/overview/)
![Metric Architecture](images/metric_architecture.png)

### Metric Client Tool
- [prom-client](https://www.npmjs.com/package/prom-client)
-  [OpenTracing(CNCF項目)](https://opentracing.io/)
-  [OpenCensus(Google開源項目)](https://opencensus.io/)
- [Opentelemetry](https://opentelemetry.io/)  OpenTracing and OpenCensus are merged
```javascript
import otel from '@opentelemetry/api';
import { MeterProvider, PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';
import * as GoogleMonitoring from '@google-cloud/opentelemetry-cloud-monitoring-exporter';

const resource = Resource.default().merge(
  new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'cp-node-graphql-endpoint',
    [SemanticResourceAttributes.SERVICE_VERSION]: '0.1.0',
  }),
);

const metricReader = new PeriodicExportingMetricReader({
  exporter: new GoogleMonitoring.MetricExporter(),

  // Default is 60000ms (60 seconds). Set to 3 seconds for demonstrative purposes only.
  exportIntervalMillis: 30000,
});

const myServiceMeterProvider = new MeterProvider({
  resource: resource,
});

myServiceMeterProvider.addMetricReader(metricReader);

// Set this MeterProvider to be global to the app being instrumented.
otel.metrics.setGlobalMeterProvider(myServiceMeterProvider);

```
## Choosing logs or metrics?

## Client moinitor
```javascript
enum Action {
  Request = 'Request',
  Response = 'Response',
  Error = 'Error',
}

const meterProvider = otel.metrics.getMeterProvider();
const meter = meterProvider.getMeter('client-monitor-metric');

const reqCounter = meter.createCounter('Node.client.request.counter', {
  description: 'Client request counter',
});

const resCounter = meter.createCounter('Node.client.response.counter', {
  description: 'Client response counter',
});

const errorCounter = meter.createCounter('Node.client.error.counter', {
  description: 'Client response counter',
});

export function clientMonitor<
  // eslint-disable-next-line @typescript-eslint/ban-types
  T extends object & { vendor: string; blockchain: string; [K: string]: any }
>(client: T): T {
  return new Proxy(client, {
    get: (obj, prop) => {
      const startTime = Date.now();
      const clientName = obj.constructor.name;
      const { vendor, blockchain } = client;
      const funcName = prop.toString();
      const identifier = 'CLIENT_MONITOR';

      const logAndCount = (action: Action, error?: any) => {
        const commonLogData = {
          identifier,
          action,
          funcName,
          client: clientName,
          vendor,
          blockchain,
          ...(action !== Action.Request ? { latency: (Date.now() - startTime) / 1000 } : {}),
        };

        const traceLogger = logger.child({
          namespace: 'client',
          'logging.googleapis.com/trace': uuidv4(),
        });

        const counterData = {
          clientName,
          funcName,
          vendor,
          blockchain,
          instanceId: INSTANCE_CUSTOM_ID,
        };

        if (error) {
          traceLogger.info({ ...commonLogData, error });
          errorCounter.add(1, counterData);
        } else {
          traceLogger.info({ ...commonLogData });
          if (action === Action.Response) {
            resCounter.add(1, counterData);
          }
          if (action === Action.Request) {
            reqCounter.add(1, counterData);
          }
        }
      };

      const run = async (...args: any[]) => {
        try {
          logAndCount(Action.Request);
          const result = await obj[prop as string](...args);
          logAndCount(Action.Response);
          return result;
        } catch (err) {
          logAndCount(Action.Error, err);
          throw err;
        }
      };

      return typeof obj[prop as string] !== 'function' ? obj[prop as string] : run;
    },
  });
}
```


