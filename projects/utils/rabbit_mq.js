const amqp = require('amqplib/callback_api');

const rabbit_host = process.env.RABBITMQ_HOST;
const rabbit_port = process.env.RABBITMQ_PORT;
const rabbit_username = process.env.RABBITMQ_USER;
const rabbit_password = process.env.RABBITMQ_PASS;
const exchange = "picturas";

const rabbit_mq_sv = `amqp://${rabbit_username}:${rabbit_password}@${rabbit_host}:${rabbit_port}`;

function send_rabbit_msg(msg, queue) {
    return new Promise((resolve) => {
        amqp.connect(rabbit_mq_sv, (connectError, connection) => {
            if (connectError) {
                console.error("RabbitMQ publish connection failed:", connectError.message);
                return resolve(false);
            }
            connection.on("error", (error) => {
                console.error("RabbitMQ publish connection error:", error.message);
                resolve(false);
            });
            connection.createConfirmChannel((channelError, channel) => {
                if (channelError) {
                    console.error("RabbitMQ publish channel failed:", channelError.message);
                    connection.close();
                    return resolve(false);
                }
                channel.on("error", (error) => {
                    console.error("RabbitMQ publish channel error:", error.message);
                    resolve(false);
                });
                channel.assertExchange(exchange, "direct", { durable: true }, (exchangeError) => {
                    if (exchangeError) {
                        console.error("RabbitMQ exchange assertion failed:", exchangeError.message);
                        channel.close();
                        connection.close();
                        return resolve(false);
                    }
                    try {
                        channel.publish(exchange, queue, Buffer.from(JSON.stringify(msg)), { persistent: true });
                        channel.waitForConfirms((publishError) => {
                            if (publishError) console.error("RabbitMQ publish failed:", publishError.message);
                            channel.close();
                            connection.close();
                            resolve(!publishError);
                        });
                    } catch (publishError) {
                        console.error("RabbitMQ publish failed:", publishError.message);
                        channel.close();
                        connection.close();
                        resolve(false);
                    }
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
