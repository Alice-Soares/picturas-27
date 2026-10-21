const amqp = require('amqplib/callback_api');

const rabbit_host = process.env.RABBITMQ_HOST;
const rabbit_port = process.env.RABBITMQ_PORT;
const rabbit_username = process.env.RABBITMQ_USER;
const rabbit_password = process.env.RABBITMQ_PASS;
const exchange = "picturas";

const rabbit_mq_sv = `amqp://${rabbit_username}:${rabbit_password}@${rabbit_host}:${rabbit_port}`;

function send_rabbit_msg(msg, queue) {
    amqp.connect(rabbit_mq_sv, (err_sv, connection) => {
        if (err_sv) throw err_sv;

        const close = () => connection.close();
        connection.createConfirmChannel((err_conn, channel) => {
            if (err_conn) throw err_conn;

            channel.assertExchange(exchange, 'direct', {
                durable: true
            });

            const body = Buffer.from(JSON.stringify(msg));
            if (queue === "video_audio_queue") {
                channel.assertQueue(queue, { durable: true }, (err_queue) => {
                    if (err_queue) { close(); throw err_queue; }
                    channel.bindQueue(queue, exchange, queue, {}, (err_bind) => {
                        if (err_bind) { close(); throw err_bind; }
                        channel.publish(exchange, queue, body, { persistent: true }, (err_publish) => {
                            close();
                            if (err_publish) throw err_publish;
                        });
                    });
                });
            } else {
                channel.publish(exchange, queue, body, {}, (err_publish) => {
                    close();
                    if (err_publish) throw err_publish;
                });
            }
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
