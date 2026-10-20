"use client";

import { Card } from "@/components/ui/card";
import { ProjectVideo } from "@/lib/projects";
import { VideoTrimDialog } from "./video-trim-dialog";
import { VideoFrameToolDialog } from "./video-frame-tool-dialog";
import { VideoFrameExtractionDialog } from "./video-frame-extraction-dialog";
import { ProjectToolResponse } from "@/lib/projects";
import { VideoConversionDialog } from "./video-conversion-dialog";

export function ProjectVideoList({
  videos,
  uid,
  pid,
  token,
  projectVersion,
  ownerId,
  shareId,
  canEdit,
  tools,
}: {
  videos: ProjectVideo[];
  uid: string;
  pid: string;
  token: string;
  projectVersion: number;
  ownerId?: string;
  shareId?: string;
  canEdit?: boolean;
  tools: ProjectToolResponse[];
}) {
  if (!videos.length) return null;
  return (
    <section className="border-b p-4 space-y-3">
      <h2 className="font-semibold">Vídeos do projeto</h2>
      <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
        {videos.map((video) => (
          <Card key={video._id} className="space-y-3 p-3">
            <video
              className="aspect-video w-full rounded-md bg-black object-contain"
              controls
              preload="metadata"
              src={video.url}
              onError={(event) => {
                console.error("Unable to load project video", video._id, event.currentTarget.error);
              }}
            >
              O browser não suporta reprodução de vídeo.
            </video>
            <div className="min-w-0">
              <p className="truncate font-medium">{video.name}</p>
              <p className="text-xs text-muted-foreground">
                {video.duration.toFixed(2)} s · {video.width}×{video.height}
                {video.sourceVideoId ? " · derivado" : ""}
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              <VideoTrimDialog video={video} uid={uid} pid={pid} token={token}
                projectVersion={projectVersion} ownerId={ownerId} shareId={shareId} canEdit={canEdit} />
              <VideoFrameToolDialog video={video} tools={tools} uid={uid} pid={pid} token={token}
                projectVersion={projectVersion} ownerId={ownerId} shareId={shareId} canEdit={canEdit} />
              <VideoFrameExtractionDialog video={video} uid={uid} pid={pid} token={token}
                projectVersion={projectVersion} ownerId={ownerId} shareId={shareId} canEdit={canEdit} />
              <VideoConversionDialog video={video} uid={uid} pid={pid} token={token}
                projectVersion={projectVersion} ownerId={ownerId} shareId={shareId} canEdit={canEdit} />
            </div>
          </Card>
        ))}
      </div>
    </section>
  );
}
