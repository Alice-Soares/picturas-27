"use strict";

// Consumidor específico da UC-VID-006. Ao contrário de read_rabbit_msg(),
// só confirma a mensagem depois de a Promise do handler terminar.
function queueUrl() {
  const { RABBITMQ_HOST, RABBITMQ_PORT, RABBITMQ_USER, RABBITMQ_PASS } = process.env;
  return `amqp://${encodeURIComponent(RABBITMQ_USER || "guest")}:${encodeURIComponent(RABBITMQ_PASS || "guest")}@${RABBITMQ_HOST || "rabbitmq"}:${RABBITMQ_PORT || "5672"}`;
}

function consumeMergeQueue(handleMessage, { amqp, url = queueUrl(), logger = console } = {}) {
  if (typeof handleMessage !== "function") throw new TypeError("handleMessage obrigatório");
  const client = amqp || require("amqplib/callback_api");
  return new Promise((resolve, reject) => {
    client.connect(url, (connectionError, connection) => {
      if (connectionError) return reject(connectionError);
      connection.on("error", (error) => logger.error("video_merge: conexão RabbitMQ:", error));
      connection.createChannel((channelError, channel) => {
        if (channelError) return reject(channelError);
        channel.on("error", (error) => logger.error("video_merge: canal RabbitMQ:", error));
        channel.assertExchange("picturas", "direct", { durable: true }, (exchangeError) => {
          if (exchangeError) return reject(exchangeError);
          channel.assertQueue("video_merge", { durable: true }, (queueError, queue) => {
            if (queueError) return reject(queueError);
            channel.bindQueue(queue.queue, "picturas", "video_merge", {}, (bindError) => {
              if (bindError) return reject(bindError);
              channel.prefetch(1);
              channel.consume(queue.queue, (message) => {
                if (!message) return;
                Promise.resolve().then(() => handleMessage(message)).then(
                  () => channel.ack(message),
                  (error) => {
                    logger.error("video_merge: processamento falhou; mensagem reenfileirada:", error);
                    // Requeue com prefetch 1. Repetidas falhas precisam de política
                    // de retries/dead-letter antes de uso em produção.
                    channel.nack(message, false, true);
                  },
                );
              }, { noAck: false }, (consumeError) => {
                if (consumeError) return reject(consumeError);
                resolve({ connection, channel });
              });
            });
          });
        });
      });
    });
  });
}

module.exports = { consumeMergeQueue, queueUrl };
