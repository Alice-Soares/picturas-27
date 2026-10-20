import datetime
import json
import os
import subprocess
import uuid

import pika
import pytz


QUEUE = "video_conversion_queue"
RESPONSE_QUEUE = "project_queue"
ROOT = os.path.realpath("/app/images")
EXCHANGE = "picturas"
RABBIT_HOST = os.getenv("RABBITMQ_HOST", "rabbitmq")
RABBIT_PORT = int(os.getenv("RABBITMQ_PORT", "5672"))
RABBIT_USER = os.getenv("RABBITMQ_USERNAME", os.getenv("RABBITMQ_USER", "user"))
RABBIT_PASSWORD = os.getenv("RABBITMQ_PASSWORD", os.getenv("RABBITMQ_PASS", "password"))


def utc_now():
    return datetime.datetime.now(pytz.utc).isoformat()


def probe(path):
    result = subprocess.run(
        ["ffprobe", "-v", "error", "-show_streams", "-show_format", "-of", "json", path],
        check=True, capture_output=True, text=True,
    )
    document = json.loads(result.stdout)
    video = next((s for s in document.get("streams", []) if s.get("codec_type") == "video"), None)
    audio = next((s for s in document.get("streams", []) if s.get("codec_type") == "audio"), None)
    if not video:
        raise ValueError("VIDEO_STREAM_REQUIRED")

    rate = video.get("r_frame_rate", "0/1")
    numerator, denominator = (rate.split("/", 1) + ["1"])[:2] if "/" in rate else (rate, "1")
    return {
        "container": str(document.get("format", {}).get("format_name", "")).split(",")[0],
        "videoCodec": video.get("codec_name"),
        "audioCodec": audio.get("codec_name") if audio else None,
        "duration": float(document.get("format", {}).get("duration", 0)),
        "width": int(video.get("width", 0)),
        "height": int(video.get("height", 0)),
        "fps": float(numerator) / float(denominator),
        "size": os.path.getsize(path),
    }


def publish(channel, message):
    channel.basic_publish(exchange=EXCHANGE, routing_key=RESPONSE_QUEUE,
                          body=json.dumps(message).encode())


def convert(channel, payload):
    parameters = payload["parameters"]
    input_path = parameters["inputVideoURI"]
    output_path = parameters["outputVideoURI"]
    options = parameters.get("options", parameters)
    input_path = os.path.realpath(input_path)
    output_path = os.path.realpath(output_path)
    if not input_path.startswith(ROOT + os.sep) or not output_path.startswith(ROOT + os.sep):
        raise ValueError("VIDEO_PATH_OUTSIDE_SHARED_VOLUME")
    if options.get("outputContainer") != "mp4" or options.get("outputVideoCodec") != "h264":
        raise ValueError("VIDEO_CONVERSION_INVALID_OPTIONS")
    if options.get("outputAudioCodec") not in ("aac", None):
        raise ValueError("VIDEO_CONVERSION_INVALID_OPTIONS")
    if (not isinstance(options.get("outputWidth"), int) or
            not isinstance(options.get("outputHeight"), int) or
            options["outputWidth"] <= 0 or options["outputHeight"] <= 0):
        raise ValueError("VIDEO_CONVERSION_INVALID_OPTIONS")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    output_container = options["outputContainer"].lower()
    output_codec = options["outputVideoCodec"].lower()
    output_audio = options.get("outputAudioCodec")
    extension = "mp4" if output_container == "mp4" else output_container
    if not output_path.endswith(f".{extension}"):
        raise ValueError("VIDEO_OUTPUT_EXTENSION_INVALID")

    command = [
        "ffmpeg", "-y", "-i", input_path,
        "-c:v", output_codec, "-vf",
        f"scale={options['outputWidth']}:{options['outputHeight']}",
    ]
    if output_audio:
        command.extend(["-c:a", output_audio])
    else:
        command.append("-an")
    command.extend(["-movflags", "+faststart", output_path])

    process = subprocess.Popen(command, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)
    stderr = []
    last_progress = 0
    while True:
        line = process.stderr.readline()
        if not line:
            break
        stderr.append(line)
        now = datetime.datetime.now().timestamp()
        if now - last_progress >= 5:
            last_progress = now
            publish(channel, {
                "messageId": f"video-conversion-progress-{uuid.uuid4()}",
                "correlationId": payload["correlationId"],
                "timestamp": utc_now(),
                "procedure": "video_conversion",
                "status": "processing",
                "progress": 50,
                "metadata": {"microservice": "picturas-video-conversion-tool"},
            })
    code = process.wait()
    if code != 0:
        raise RuntimeError(f"VIDEO_FFMPEG_FAILED:{''.join(stderr)[-500:]}")

    metadata = probe(output_path)
    publish(channel, {
        "messageId": f"video-conversion-response-{uuid.uuid4()}",
        "correlationId": payload["correlationId"],
        "timestamp": utc_now(),
        "procedure": "video_conversion",
        "status": "completed",
        "output": {"type": "video", "videoURI": output_path, "metadata": metadata},
        "metadata": {"microservice": "picturas-video-conversion-tool"},
    })


def callback(channel, method, properties, body):
    output_path = None
    completed = False
    try:
        payload = json.loads(body.decode())
        output_path = payload.get("parameters", {}).get("outputVideoURI")
        if payload.get("procedure") != "video_conversion":
            raise ValueError("VIDEO_CONVERSION_INVALID_PROCEDURE")
        convert(channel, payload)
        completed = True
    except Exception as error:
        try:
            correlation_id = payload.get("correlationId")
        except UnboundLocalError:
            correlation_id = None
        publish(channel, {
            "messageId": f"video-conversion-error-{uuid.uuid4()}",
            "correlationId": correlation_id,
            "timestamp": utc_now(),
            "procedure": "video_conversion",
            "status": "error",
            "error": {"code": str(error).split(":", 1)[0], "message": "Video conversion failed"},
            "metadata": {"microservice": "picturas-video-conversion-tool"},
        })
    finally:
        try:
            if not completed and output_path and os.path.exists(output_path):
                os.remove(output_path)
        except OSError:
            pass


def main():
    credentials = pika.PlainCredentials(RABBIT_USER, RABBIT_PASSWORD)
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(RABBIT_HOST, RABBIT_PORT, "/", credentials)
    )
    channel = connection.channel()
    channel.exchange_declare(exchange=EXCHANGE, exchange_type="direct", durable=True)
    channel.queue_declare(queue=QUEUE, durable=True)
    channel.queue_declare(queue=RESPONSE_QUEUE, durable=True)
    channel.queue_bind(queue=QUEUE, exchange=EXCHANGE, routing_key=QUEUE)
    channel.basic_consume(queue=QUEUE, on_message_callback=callback, auto_ack=True)
    channel.start_consuming()


if __name__ == "__main__":
    main()
