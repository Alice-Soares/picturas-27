"use client";

import { useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import { ProjectVideo, createProjectVideoAudioPlayback, fetchProjectVideoAudio, getProjectVideoAudio } from "@/lib/projects";

type Props = {
  video: ProjectVideo;
  uid: string;
  pid: string;
  token: string;
  projectVersion: number;
  ownerId?: string;
  shareId?: string;
  audioUrl?: string;
  onAudioReady: (videoId: string, url: string) => void;
};

export function ProjectVideoPlayer({ video, uid, pid, token, projectVersion, ownerId, shareId, audioUrl, onAudioReady }: Props) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const audioRef = useRef<HTMLAudioElement>(null);
  const requestedVideoId = useRef<string | undefined>(undefined);
  const audioCorrectionAt = useRef(0);
  const [preparingAudio, setPreparingAudio] = useState(false);
  const [audioStatus, setAudioStatus] = useState("");

  async function prepareAudio() {
    if (!video.audioCodec || audioUrl || requestedVideoId.current === video._id) return;
    requestedVideoId.current = video._id;
    const params = { uid, pid, token, ownerId, shareId };
    try {
      setPreparingAudio(true);
      setAudioStatus("A preparar a faixa de áudio para reprodução…");
      const accepted = await createProjectVideoAudioPlayback({ ...params, videoId: video._id, projectVersion });
      let operation = await getProjectVideoAudio({ ...params, operationId: accepted.operationId });
      while (!["completed", "failed", "cancelled"].includes(operation.status)) {
        await new Promise((resolve) => window.setTimeout(resolve, 1500));
        operation = await getProjectVideoAudio({ ...params, operationId: accepted.operationId });
      }
      if (operation.status !== "completed") throw new Error(operation.errorCode || "Não foi possível preparar o áudio.");
      const url = await fetchProjectVideoAudio({ ...params, operationId: accepted.operationId });
      if (requestedVideoId.current !== video._id) {
        URL.revokeObjectURL(url);
        return;
      }
      onAudioReady(video._id, url);
      setAudioStatus("");
    } catch (error) {
      if (requestedVideoId.current === video._id) {
        requestedVideoId.current = undefined;
        setAudioStatus((error as Error).message || "Não foi possível preparar o áudio para reprodução.");
      }
    } finally {
      if (requestedVideoId.current === video._id) setPreparingAudio(false);
    }
  }

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
        preload="metadata"
        muted={Boolean(audioUrl)}
        src={video.url}
        onPlay={playAudio}
        onPause={() => audioRef.current?.pause()}
        onSeeking={syncAudio}
        onRateChange={() => { if (audioRef.current && videoRef.current) audioRef.current.playbackRate = videoRef.current.playbackRate; }}
      >
        O browser não suporta reprodução de vídeo.
      </video>
      {video.audioCodec && !audioUrl && (
        <div className="space-y-1">
          <Button type="button" variant="outline" disabled={preparingAudio} onClick={() => void prepareAudio()}>
            {preparingAudio ? "A preparar áudio…" : "Ativar faixa de áudio alternativa"}
          </Button>
          {audioStatus && <p role="status" className="text-sm text-muted-foreground">{audioStatus}</p>}
        </div>
      )}
      {video.audioCodec && audioUrl && (
        <div className="space-y-1">
          <p className="text-sm">Áudio original sincronizado</p>
          <audio
            ref={audioRef}
            className="w-full"
            controls
            preload="auto"
            src={audioUrl}
            onLoadedMetadata={() => {
              syncAudio();
              if (!videoRef.current?.paused) audioRef.current?.play().catch(() => {});
            }}
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
              const now = Date.now();
              if (audio && videoElement && !videoElement.paused &&
                Math.abs(audio.currentTime - videoElement.currentTime) > 0.75 && now - audioCorrectionAt.current > 1000) {
                audioCorrectionAt.current = now;
                audio.currentTime = videoElement.currentTime;
              }
            }}
          />
        </div>
      )}
      {video.audioCodec && audioUrl && audioStatus && <p role="status" className="text-sm text-muted-foreground">{audioStatus}</p>}
    </div>
  );
}
