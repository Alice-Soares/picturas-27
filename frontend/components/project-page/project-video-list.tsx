"use client";

import { useState } from "react";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Trash } from "lucide-react";
import { useToast } from "@/hooks/use-toast";
import { ProjectVideo, ProjectAudio, ProjectToolResponse } from "@/lib/projects";
import { useDeleteProjectVideo } from "@/lib/mutations/projects";
import { VideoTrimDialog } from "./video-trim-dialog";
import { VideoFrameToolDialog } from "./video-frame-tool-dialog";
import { VideoFrameExtractionDialog } from "./video-frame-extraction-dialog";
import { VideoConversionDialog } from "./video-conversion-dialog";
import { VideoAudioDialog } from "./video-audio-dialog";

export function ProjectVideoList({
  videos, audios = [], uid, pid, token, projectVersion, ownerId, shareId, canEdit, tools,
}: {
  videos: ProjectVideo[];
  audios?: ProjectAudio[];
  uid: string;
  pid: string;
  token: string;
  projectVersion: number;
  ownerId?: string;
  shareId?: string;
  canEdit?: boolean;
  tools: ProjectToolResponse[];
}) {
  const [selectedVideo, setSelectedVideo] = useState<ProjectVideo | null>(null);
  const [deleteOpen, setDeleteOpen] = useState(false);
  const deleteVideo = useDeleteProjectVideo(uid, pid, token, ownerId, shareId);
  const { toast } = useToast();

  if (!videos.length && !audios.length) return null;
  return (
    <section className="space-y-4 border-b p-4">
      <div>
        <h2 className="font-semibold">Vídeos do projeto</h2>
        <p className="text-sm text-muted-foreground">Seleciona um vídeo para o reproduzir ou editar.</p>
      </div>
      {!!audios.length && <div className="space-y-2"><h3 className="font-medium">Áudios extraídos</h3>{audios.map((audio) => <Card key={audio._id} className="flex items-center justify-between gap-4 p-3"><div><p className="font-medium">{audio.name}</p><p className="text-xs text-muted-foreground">M4A · AAC · {audio.duration.toFixed(2)} s</p></div><audio controls src={audio.url} className="max-w-full" /></Card>)}</div>}
      <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
        {videos.map((video) => (
          <Card key={video._id} className="overflow-hidden p-0">
            <button type="button" className="block w-full text-left" onClick={() => setSelectedVideo(video)}>
              <video className="aspect-video w-full bg-black object-contain" preload="metadata" src={video.url} />
            </button>
            <div className="space-y-2 p-3">
              <p className="truncate font-medium">{video.name}</p>
              <p className="text-xs text-muted-foreground">
                {video.duration.toFixed(2)} s · {video.width}×{video.height}
                {video.sourceVideoId ? " · derivado" : ""}
              </p>
              <Button className="w-full" variant="outline" onClick={() => setSelectedVideo(video)}>
                Abrir vídeo e editar
              </Button>
            </div>
          </Card>
        ))}
      </div>
      <Dialog open={selectedVideo !== null} onOpenChange={(open) => !open && setSelectedVideo(null)}>
        <DialogContent className="max-w-3xl">
          {selectedVideo && (
            <>
              <DialogHeader>
                <DialogTitle>{selectedVideo.name}</DialogTitle>
                <DialogDescription>
                  {selectedVideo.duration.toFixed(2)} s · {selectedVideo.width}×{selectedVideo.height}
                  {selectedVideo.audioCodec ? ` · Áudio original: ${selectedVideo.audioCodec}` : " · Sem faixa de áudio detetada"}
                </DialogDescription>
              </DialogHeader>
              <video className="aspect-video w-full rounded-md bg-black" controls playsInline muted={false} src={selectedVideo.url}>
                O browser não suporta reprodução de vídeo.
              </video>
              <div className="grid grid-cols-2 gap-2">
                <VideoTrimDialog video={selectedVideo} uid={uid} pid={pid} token={token} projectVersion={projectVersion} ownerId={ownerId} shareId={shareId} canEdit={canEdit} />
                <VideoFrameToolDialog video={selectedVideo} tools={tools} uid={uid} pid={pid} token={token} projectVersion={projectVersion} ownerId={ownerId} shareId={shareId} canEdit={canEdit} />
                <VideoFrameExtractionDialog video={selectedVideo} uid={uid} pid={pid} token={token} projectVersion={projectVersion} ownerId={ownerId} shareId={shareId} canEdit={canEdit} />
                <VideoConversionDialog video={selectedVideo} uid={uid} pid={pid} token={token} projectVersion={projectVersion} ownerId={ownerId} shareId={shareId} canEdit={canEdit} />
                <VideoAudioDialog video={selectedVideo} uid={uid} pid={pid} token={token} projectVersion={projectVersion} canEdit={canEdit} />
              </div>
              {canEdit && (
                <Dialog open={deleteOpen} onOpenChange={setDeleteOpen}>
                  <Button variant="destructive" onClick={() => setDeleteOpen(true)}>
                    <Trash className="mr-2 size-4" /> Apagar vídeo
                  </Button>
                  <DialogContent>
                    <DialogHeader>
                      <DialogTitle>Apagar vídeo?</DialogTitle>
                      <DialogDescription>Esta ação não pode ser desfeita.</DialogDescription>
                    </DialogHeader>
                    <DialogFooter>
                      <Button variant="outline" onClick={() => setDeleteOpen(false)}>Cancelar</Button>
                      <Button
                        variant="destructive"
                        disabled={deleteVideo.isPending}
                        onClick={() => deleteVideo.mutate(
                          { videoId: selectedVideo._id, projectVersion },
                          {
                            onSuccess: () => {
                              setDeleteOpen(false);
                              setSelectedVideo(null);
                              toast({ title: "Vídeo apagado com sucesso." });
                            },
                            onError: (error) => toast({
                              title: "Não foi possível apagar o vídeo.",
                              description: error.message,
                              variant: "destructive",
                            }),
                          },
                        )}
                      >
                        Apagar
                      </Button>
                    </DialogFooter>
                  </DialogContent>
                </Dialog>
              )}
            </>
          )}
        </DialogContent>
      </Dialog>
    </section>
  );
}
