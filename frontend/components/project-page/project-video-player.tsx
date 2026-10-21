"use client";

import { useEffect, useRef, useState } from "react";
import { ProjectVideo, createProjectVideoAudio, fetchProjectVideoAudio, getProjectVideoAudio } from "@/lib/projects";

type Props = {
  video: ProjectVideo;
  uid: string;
  pid: string;
  token: string;
  projectVersion: number;
  audioUrl?: string;
  onAudioReady: (videoId: string, url: string) => void;
};

export function ProjectVideoPlayer({ video, uid, pid, token, projectVersion, audioUrl, onAudioReady }: Props) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const audioRef = useRef<HTMLAudioElement>(null);
  const requestedVideoId = useRef<string | undefined>(undefined);
  const [audioStatus, setAudioStatus] = useState("");

  useEffect(() => {
    if (!video.audioCodec || audioUrl || requestedVideoId.current === video._id) return;
    requestedVideoId.current = video._id;
    let active = true;
    let operationId: string | undefined;
    const params = { uid, pid, token };

    async function prepareAudio() {
      try {
        setAudioStatus("A preparar a faixa de áudio para reprodução…");
        const accepted = await createProjectVideoAudio({ ...params, videoId: video._id, action: "extract", projectVersion });
        operationId = accepted.operationId;
        let operation = await getProjectVideoAudio({ ...params, operationId });
        while (!["completed", "failed", "cancelled"].includes(operation.status)) {
          await new Promise((resolve) => window.setTimeout(resolve, 1500));
          operation = await getProjectVideoAudio({ ...params, operationId });
        }
        if (operation.status !== "completed") throw new Error(operation.errorCode || "Não foi possível preparar o áudio.");
        const url = await fetchProjectVideoAudio({ ...params, operationId });
        if (!active) {
          URL.revokeObjectURL(url);
          return;
        }
        onAudioReady(video._id, url);
        setAudioStatus("");
      } catch (error) {
        if (active) setAudioStatus((error as Error).message || "Não foi possível preparar o áudio para reprodução.");
      }
    }

    void prepareAudio();
    return () => { active = false; };
  }, [audioUrl, onAudioReady, pid, projectVersion, token, uid, video._id, video.audioCodec]);

  function syncAudio() {
    const videoElement = videoRef.current;
    const audioElement = audioRef.current;
    if (!videoElement || !audioElement) return;
    audioElement.currentTime = videoElement.currentTime;
  }

  function playAudio() {
    const audioElement = audioRef.current;
    if (!audioElement || !videoRef.current) return;
    syncAudio();
    audioElement.play().catch(() => setAudioStatus("Carrega em reproduzir no controlo de áudio para ouvir a faixa."));
  }

  return (
    <div className="space-y-2">
      <video
        ref={videoRef}
        className="aspect-video w-full rounded-md bg-black"
        controls
        playsInline
        muted={Boolean(audioUrl)}
        src={video.url}
        onPlay={playAudio}
        onPause={() => audioRef.current?.pause()}
        onSeeking={syncAudio}
        onRateChange={() => { if (audioRef.current && videoRef.current) audioRef.current.playbackRate = videoRef.current.playbackRate; }}
      >
        O browser não suporta reprodução de vídeo.
      </video>
      {video.audioCodec && audioUrl && (
        <div className="space-y-1">
          <p className="text-sm">Áudio original sincronizado</p>
          <audio
            ref={audioRef}
            className="w-full"
            controls
            preload="auto"
            src={audioUrl}
            onLoadedMetadata={syncAudio}
            onPlay={() => {
              const audio = audioRef.current;
              const videoElement = videoRef.current;
              if (audio && videoElement && videoElement.paused) {
                videoElement.currentTime = audio.currentTime;
                videoElement.play().catch(() => {});
              }
            }}
            onPause={() => {
              if (videoRef.current && !videoRef.current.paused) videoRef.current.pause();
            }}
            onSeeking={() => {
              if (audioRef.current && videoRef.current) videoRef.current.currentTime = audioRef.current.currentTime;
            }}
            onTimeUpdate={() => {
              const audio = audioRef.current;
              const videoElement = videoRef.current;
              if (audio && videoElement && !videoElement.paused && Math.abs(audio.currentTime - videoElement.currentTime) > 0.4) {
                videoElement.currentTime = audio.currentTime;
              }
            }}
          />
        </div>
      )}
      {audioStatus && <p role="status" className="text-sm text-muted-foreground">{audioStatus}</p>}
    </div>
  );
}
