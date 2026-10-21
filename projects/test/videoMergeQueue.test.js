"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const { consumeMergeQueue } = require("../utils/videoMergeQueue");
const { startMergeWorker } = require("../services/videoMergeWorker");

function rabbitMock() {
  const calls = [];
  let deliver;
  const channel = {
    on() {},
    assertExchange(name, type, settings, cb) { calls.push(`exchange:${name}:${type}:${settings.durable}`); cb(null); },
    assertQueue(name, settings, cb) { calls.push(`queue:${name}:${settings.durable}`); cb(null, { queue: name }); },
    bindQueue(queue, exchange, route, opts, cb) { calls.push(`bind:${queue}:${exchange}:${route}`); cb(null); },
    prefetch(n) { calls.push(`prefetch:${n}`); },
    consume(queue, fn, opts, cb) { calls.push(`consume:${queue}:${opts.noAck}`); deliver = fn; cb(null); },
    ack() { calls.push("ack"); },
    nack(message, allUpTo, requeue) { calls.push(`nack:${requeue}`); },
  };
  const connection = { on() {}, createChannel(cb) { cb(null, channel); } };
  const amqp = { connect(_url, cb) { cb(null, connection); } };
  return { amqp, calls, send: (message) => deliver({ content: Buffer.from(JSON.stringify(message)) }) };
}

function nextTick() { return new Promise((resolve) => setImmediate(resolve)); }

test("declara queue durável, exchange e prefetch 1", async () => {
  const mock = rabbitMock();
  await consumeMergeQueue(async () => {}, { amqp: mock.amqp });
  assert.deepEqual(mock.calls.slice(0, 5), [
    "exchange:picturas:direct:true", "queue:video_merge:true",
    "bind:video_merge:picturas:video_merge", "prefetch:1", "consume:video_merge:false",
  ]);
});

test("ACK só acontece depois de terminar o processamento assíncrono", async () => {
  const mock = rabbitMock();
  let release;
  await consumeMergeQueue(() => new Promise((resolve) => { release = resolve; }), { amqp: mock.amqp });
  mock.send({ operationId: "aaaaaaaaaaaaaaaaaaaaaaaa" });
  await nextTick();
  assert.equal(mock.calls.includes("ack"), false);
  release();
  await nextTick();
  assert.equal(mock.calls.filter((item) => item === "ack").length, 1);
});

test("erro do handler resulta em NACK e requeue", async () => {
  const mock = rabbitMock();
  const errors = [];
  await consumeMergeQueue(async () => { throw new Error("falha de infraestrutura"); }, {
    amqp: mock.amqp, logger: { error: (...args) => errors.push(args) },
  });
  mock.send({ operationId: "aaaaaaaaaaaaaaaaaaaaaaaa" });
  await nextTick();
  assert.equal(mock.calls.includes("ack"), false);
  assert.ok(mock.calls.includes("nack:true"));
  assert.equal(errors.length, 1);
});

test("worker espera pelo processamento antes de resolver callback", async () => {
  let queuedHandler;
  let release;
  const result = startMergeWorker({
    claim: async () => ({ _id: "aaaaaaaaaaaaaaaaaaaaaaaa", source_video_ids: ["1", "2"] }),
    status: async () => "processing",
    project: async () => ({ videos: [{ _id: "1", object_key: "a" }, { _id: "2", object_key: "b" }] }),
    pipeline: () => new Promise((resolve) => { release = () => resolve({ savedResult: { videoId: "v" } }); }),
    complete: async () => ({ status: "completed" }),
    publish: async () => {},
  }, { consumer: (handler) => { queuedHandler = handler; return Promise.resolve(); } });
  await result.ready;
  let finished = false;
  const running = queuedHandler({ content: Buffer.from('{"operationId":"aaaaaaaaaaaaaaaaaaaaaaaa"}') })
    .then(() => { finished = true; });
  await nextTick();
  assert.equal(finished, false);
  release();
  await running;
  assert.equal(finished, true);
});

test("mensagem inválida não chama o worker", async () => {
  let handler;
  const worker = startMergeWorker({ claim: async () => { throw new Error("não devia executar"); } }, {
    consumer: (fn) => { handler = fn; return Promise.resolve(); },
  });
  await worker.ready;
  await handler({ content: Buffer.from('{"operationId":"invalid"}') });
  await handler({ content: Buffer.from('not-json') });
});
