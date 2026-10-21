import json
import os
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import video_audio


class Channel:
    def __init__(self):
        self.messages = []

    def basic_publish(self, **kwargs):
        self.messages.append(json.loads(kwargs["body"].decode()))


class VideoAudioWorkerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.root = tempfile.mkdtemp(prefix="video-audio-tests-")
        video_audio.ROOT = os.path.realpath(cls.root)
        cls.source = os.path.join(cls.root, "source.mp4")
        cls.replacement = os.path.join(cls.root, "replacement.mp3")
        cls.replacement_video = os.path.join(cls.root, "replacement-video.mp4")
        cls.replacement_video_input = os.path.join(cls.root, "replacement.input")
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "lavfi", "-i", "color=c=black:s=160x120:r=10:d=2", "-f", "lavfi", "-i", "sine=frequency=440:duration=2", "-c:v", "mpeg4", "-c:a", "aac", "-shortest", cls.source], check=True)
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "lavfi", "-i", "sine=frequency=880:duration=1", "-c:a", "libmp3lame", cls.replacement], check=True)
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "lavfi", "-i", "color=c=red:s=80x60:r=10:d=1", "-f", "lavfi", "-i", "sine=frequency=880:duration=1", "-c:v", "mpeg4", "-c:a", "aac", "-shortest", cls.replacement_video], check=True)
        shutil.copyfile(cls.replacement_video, cls.replacement_video_input)

    @classmethod
    def tearDownClass(cls):
        import shutil
        shutil.rmtree(cls.root, ignore_errors=True)

    def request(self, action, name, replacement=None):
        return {"correlationId": name, "procedure": "video_audio", "parameters": {"action": action, "inputVideoURI": self.source, "replacementAudioURI": (replacement or self.replacement) if action == "replace" else None, "outputURI": os.path.join(self.root, name + (".m4a" if action == "extract" else ".mp4"))}}

    def test_remove_produces_silent_video(self):
        channel = Channel(); request = self.request("remove", "removed")
        video_audio.process(channel, request)
        _, audio, _ = video_audio.probe(request["parameters"]["outputURI"])
        self.assertIsNone(audio)
        self.assertEqual(channel.messages[-1]["status"], "completed")

    def test_replace_pads_short_audio_and_keeps_video_duration(self):
        request = self.request("replace", "replaced")
        video_audio.process(Channel(), request)
        document, audio, _ = video_audio.probe(request["parameters"]["outputURI"])
        self.assertEqual(audio["codec_name"], "aac")
        self.assertAlmostEqual(float(document["format"]["duration"]), 2, delta=0.25)

    def test_replace_uses_audio_only_from_a_video_file(self):
        request = self.request("replace", "replaced-from-video", self.replacement_video_input)
        channel = Channel()
        video_audio.process(channel, request)
        _, audio, video = video_audio.probe(request["parameters"]["outputURI"])
        self.assertEqual(audio["codec_name"], "aac")
        self.assertEqual((video["width"], video["height"]), (160, 120))
        self.assertEqual(channel.messages[-1]["status"], "completed")

    def test_extract_produces_m4a_aac(self):
        request = self.request("extract", "extracted")
        video_audio.process(Channel(), request)
        _, audio, video = video_audio.probe(request["parameters"]["outputURI"])
        self.assertEqual(audio["codec_name"], "aac")
        self.assertIsNone(video)

    def test_incomplete_worker_response_deletes_partial_output(self):
        output = os.path.join(self.root, "partial.mp4")
        with open(output, "wb") as partial:
            partial.write(b"partial")
        request = self.request("invalid", "partial")
        request["parameters"]["outputURI"] = output
        video_audio.callback(Channel(), None, None, json.dumps(request).encode())
        self.assertFalse(os.path.exists(output))


if __name__ == "__main__":
    unittest.main()
