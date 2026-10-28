# bramble-search capacity

- `ranker` fleet: 8 instances. Together they serve about 1,200 requests per second at p50 180 ms.
- Normal peak: about 400 user searches per second. Each search makes one `query-gw` request and one `ranker` request when nothing fails.
- `ranker` scores every request that it accepts. It queues requests that wait for a worker thread. The queue has no limit.
