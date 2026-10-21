const amqp = require('amqplib/callback_api');

const rabbit_host = process.env.RABBITMQ_HOST;
const rabbit_port = process.env.RABBITMQ_PORT;
const rabbit_username = process.env.RABBITMQ_USER;
const rabbit_password = process.env.RABBITMQ_PASS;
const exchange = "picturas";

const rabbit_mq_sv = `amqp://${rabbit_username}:${rabbit_password}@${rabbit_host}:${rabbit_port}`;

function send_rabbit_msg(msg, queue) {
    return new Promise((resolve) => {
        let settled = false;
        let connection;
        let channel;

        const finish = (success, error) => {
            if (settled) return;
            settled = true;
            if (error) console.error("RabbitMQ publish failed:", error.message);

            const closeConnection = () => {
                if (!connection) return resolve(success);
                try {
                    connection.close(() => resolve(success));
                } catch (_) {
                    resolve(success);
                }
            };
            if (!channel) return closeConnection();
            try {
                channel.close(closeConnection);
            } catch (_) {
                closeConnection();
            }
        };

        amqp.connect(rabbit_mq_sv, (connectError, connected) => {
            if (connectError) return finish(false, connectError);
            connection = connected;
            connection.on("error", (error) => finish(false, error));
            connection.createConfirmChannel((channelError, createdChannel) => {
                if (channelError) return finish(false, channelError);
                channel = createdChannel;
                channel.on("error", (error) => finish(false, error));
                channel.assertExchange(exchange, "direct", { durable: true }, (exchangeError) => {
                    if (settled) return;
                    if (exchangeError) return finish(false, exchangeError);

                    const publish = () => {
                        if (settled) return;
                        try {
                            channel.publish(exchange, queue, Buffer.from(JSON.stringify(msg)), { persistent: true });
                            channel.waitForConfirms((publishError) => finish(!publishError, publishError));
                        } catch (publishError) {
                            finish(false, publishError);
                        }
                    };

                    if (queue !== "video_audio_queue") return publish();
                    channel.assertQueue(queue, { durable: true }, (queueError) => {
                        if (settled) return;
                        if (queueError) return finish(false, queueError);
                        channel.bindQueue(queue, exchange, queue, {}, (bindError) => {
                            if (bindError) return finish(false, bindError);
                            publish();
                        });
                    });
                });
            });
        });
    });
}

function read_rabbit_msg(queue, callback) {
    amqp.connect(rabbit_mq_sv, (err_sv, connection) => {
        if (err_sv) throw err_sv;

        connection.createChannel((err_conn, channel) => {
            if (err_conn) throw err_conn;

            channel.assertExchange(exchange, 'direct', {
                durable: true
              });

            channel.assertQueue(queue, { durable: true }, (err_queue, q) => {
                if(err_queue) throw err_queue;

                channel.bindQueue(q.queue, exchange, queue, {}, (err_bind) => {
                    if (err_bind) throw err_bind;
                    channel.consume(q.queue, (msg) => {
                        if(msg != null){
                            callback(msg);
                            channel.ack(msg);
                        }
                    }, {
                        noAck: false
                    });
                });
            });
        });
    });
}

module.exports = { send_rabbit_msg, read_rabbit_msg };
