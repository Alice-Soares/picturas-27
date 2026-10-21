import datetime
import json
import hashlib
import os
import subprocess
import uuid

import pika
import pytz

QUEUE, RESPONSE_QUEUE, EXCHANGE = "video_audio_queue", "project_queue", "picturas"
ROOT = os.path.realpath("/app/images")
HOST = os.getenv("RABBITMQ_HOST", "rabbitmq")
PORT = int(os.getenv("RABBITMQ_PORT", "5672"))
USER = os.getenv("RABBITMQ_USERNAME", os.getenv("RABBITMQ_USER", "user"))
PASSWORD = os.getenv("RABBITMQ_PASSWORD", os.getenv("RABBITMQ_PASS", "password"))

def utc_now(): return datetime.datetime.now(pytz.utc).isoformat()

def safe_path(value):
    path = os.path.realpath(value or "")
    if not path.startswith(ROOT + os.sep): raise ValueError("VIDEO_AUDIO_INVALID")
    return path

def probe(path):
    result = subprocess.run(["ffprobe", "-v", "error", "-show_streams", "-show_format", "-of", "json", path], check=True, capture_output=True, text=True)
    doc = json.loads(result.stdout)
    audio = next((s for s in doc.get("streams", []) if s.get("codec_type") == "audio"), None)
    video = next((s for s in doc.get("streams", []) if s.get("codec_type") == "video"), None)
    return doc, audio, video

def publish(ch, payload, status, output=None, error=None, progress=None):
    body = {"messageId": f"video-audio-{uuid.uuid4()}", "correlationId": payload.get("correlationId"), "timestamp": utc_now(), "procedure": "video_audio", "status": status}
    if output: body["output"] = output
    if error: body["error"] = {"code": error, "message": "Audio processing failed"}
    if progress is not None: body["progress"] = progress
    ch.basic_publish(exchange=EXCHANGE, routing_key=RESPONSE_QUEUE, body=json.dumps(body).encode())

def process(ch, payload):
    p = payload["parameters"]
    action = p.get("action")
    if action not in ("remove", "replace", "extract"): raise ValueError("VIDEO_AUDIO_INVALID")
    source, output = safe_path(p.get("inputVideoURI")), safe_path(p.get("outputURI"))
    replacement = safe_path(p["replacementAudioURI"]) if p.get("replacementAudioURI") else None
    _, source_audio, source_video = probe(source)
    if not source_video: raise ValueError("VIDEO_AUDIO_INVALID")
    if action in ("remove", "extract") and not source_audio: raise ValueError("VIDEO_AUDIO_NO_TRACK")
    os.makedirs(os.path.dirname(output), exist_ok=True)
    start, end = p.get("audioStartSeconds"), p.get("audioEndSeconds")
    if action == "remove":
        cmd = ["ffmpeg", "-y", "-i", source, "-map", "0:v:0", "-c", "copy", "-an", "-movflags", "+faststart", output]
    elif action == "extract":
        # Submitted videos use AAC audio; remux it into M4A instead of
        # re-encoding the whole track. This keeps playback preparation light.
        cmd = ["ffmpeg", "-y", "-i", source, "-map", "0:a:0", "-vn", "-c:a", "copy", "-f", "ipod", output]
    else:
        if not replacement: raise ValueError("VIDEO_AUDIO_INVALID")
        trim = f"atrim=start={float(start or 0)}"
        if end is not None: trim += f":end={float(end)}"
        cmd = ["ffmpeg", "-y", "-i", source, "-i", replacement, "-filter_complex", f"[1:a:0]{trim},asetpts=PTS-STARTPTS,apad[aout]", "-map", "0:v:0", "-map", "[aout]", "-c:v", "copy", "-c:a", "aac"]
        cmd += ["-t", str(float(source_video.get("duration") or 0)), "-movflags", "+faststart", output]
    publish(ch, payload, "processing", progress=10)
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode: raise ValueError("VIDEO_AUDIO_FAILED")
    doc, out_audio, out_video = probe(output)
    if action == "remove" and out_audio: raise ValueError("VIDEO_AUDIO_FAILED")
    if action in ("replace", "extract") and (not out_audio or out_audio.get("codec_name") != "aac"): raise ValueError("VIDEO_AUDIO_FAILED")
    metadata = {"size": os.path.getsize(output), "duration": float(doc.get("format", {}).get("duration", 0)), "container": "m4a" if action == "extract" else "mp4", "audioCodec": out_audio.get("codec_name") if out_audio else None, "sampleRate": int(out_audio.get("sample_rate", 0)) if out_audio else None, "channels": int(out_audio.get("channels", 0)) if out_audio else None}
    digest = hashlib.sha256()
    with open(output, "rb") as result_file:
        for block in iter(lambda: result_file.read(1024 * 1024), b""): digest.update(block)
    metadata["sha256"] = digest.hexdigest()
    if out_video:
        rate = out_video.get("r_frame_rate", "0/1")
        numerator, denominator = rate.split("/", 1) if "/" in rate else (rate, "1")
        metadata.update({"videoCodec": out_video.get("codec_name"), "width": int(out_video.get("width", 0)), "height": int(out_video.get("height", 0)), "fps": float(numerator) / float(denominator)})
    publish(ch, payload, "completed", {"type": "audio" if action == "extract" else "video", "uri": output, "metadata": metadata})

def callback(ch, method, properties, body):
    payload = {}
    output = None
    try:
        payload = json.loads(body.decode())
        if payload.get("procedure") != "video_audio": raise ValueError("VIDEO_AUDIO_INVALID")
        output = safe_path(payload.get("parameters", {}).get("outputURI"))
        process(ch, payload)
    except Exception as exc:
        code = str(exc).split(":", 1)[0]
        publish(ch, payload, "error", error=code if code.startswith("VIDEO_AUDIO_") else "VIDEO_AUDIO_FAILED")
        if output and os.path.exists(output): os.remove(output)

def main():
    credentials = pika.PlainCredentials(USER, PASSWORD)
    connection = pika.BlockingConnection(pika.ConnectionParameters(HOST, PORT, "/", credentials))
    channel = connection.channel()
    channel.exchange_declare(exchange=EXCHANGE, exchange_type="direct", durable=True)
    channel.queue_declare(queue=QUEUE, durable=True)
    channel.queue_declare(queue=RESPONSE_QUEUE, durable=True)
    channel.queue_bind(queue=QUEUE, exchange=EXCHANGE, routing_key=QUEUE)
    channel.basic_consume(queue=QUEUE, on_message_callback=callback, auto_ack=True)
    channel.start_consuming()

if __name__ == "__main__": main()
