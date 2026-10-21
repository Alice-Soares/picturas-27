"use client";

import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Progress } from "@/components/ui/progress";
import { ProjectVideo } from "@/lib/projects";
import {
  useCancelProjectVideoConversion,
  useCreateProjectVideoConversion,
  useGetProjectVideoConversion,
  useGetProjectVideoConversionOptions,
} from "@/lib/mutations/projects";

export function VideoConversionDialog(props: {
  video: ProjectVideo; uid: string; pid: string; token: string; projectVersion: number;
  ownerId?: string; shareId?: string; canEdit?: boolean;
}) {
  const { video, uid, pid, token, projectVersion, ownerId, shareId, canEdit = true } = props;
  const [open, setOpen] = useState(false);
  const [operationId, setOperationId] = useState<string | null>(null);
  const [width, setWidth] = useState(String(video.width));
  const [height, setHeight] = useState(String(video.height));
  const [audio, setAudio] = useState("aac");
  const options = useGetProjectVideoConversionOptions(uid, pid, token, ownerId, shareId);
  const create = useCreateProjectVideoConversion(uid, pid, token, ownerId, shareId);
  const get = useGetProjectVideoConversion(uid, pid, token, ownerId, shareId);
  const cancel = useCancelProjectVideoConversion(uid, pid, token, ownerId, shareId);
  const operation = get.data;
  const limit = options.data?.resolutionLimits;

  useEffect(() => {
    if (!open || operation?.status === "completed" || operation?.status === "failed" || operation?.status === "cancelled") return;
    if (!operationId) return;
    const timer = window.setInterval(() => get.mutate(operationId), 2000);
    get.mutate(operationId);
    return () => window.clearInterval(timer);
  }, [open, operationId, operation?.status]);

  function start() {
    create.mutate({
      videoId: video._id, projectVersion, outputContainer: "mp4", outputVideoCodec: "h264",
      outputAudioCodec: audio === "none" ? null : audio, outputWidth: Number(width), outputHeight: Number(height),
    }, { onSuccess: (result) => setOperationId(result.operationId) });
  }

  function show() {
    setOpen(true);
    options.mutate(video._id);
  }

  return (
    <>
      <Button size="sm" variant="outline" disabled={!canEdit} onClick={show}>Converter</Button>
      {open && (
        <div role="dialog" className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div className="w-full max-w-md space-y-4 rounded-lg bg-background p-6 shadow-lg">
            <h2 className="font-semibold">Converter {video.name}</h2>
            {!operationId ? (
              <>
                <p className="text-sm text-muted-foreground">Origem: {video.container} · {video.videoCodec} · {video.width}×{video.height}</p>
                <p className="text-sm">Saída: MP4 · H.264 · AAC</p>
                <div className="grid grid-cols-2 gap-3">
                  <label className="text-sm">Largura<Input type="number" min={1} max={limit?.width} value={width} onChange={(e) => setWidth(e.target.value)} /></label>
                  <label className="text-sm">Altura<Input type="number" min={1} max={limit?.height} value={height} onChange={(e) => setHeight(e.target.value)} /></label>
                </div>
                <p className="text-xs text-muted-foreground">Limite do perfil: {limit ? `${limit.width}×${limit.height}` : "a carregar"}. Estimativa: indisponível.</p>
              </>
            ) : (
              <>
                <p className="text-sm">Estado: {operation?.status ?? "queued"}</p>
                <Progress value={operation?.progress ?? 0} />
                {operation?.errorCode && <p className="text-sm text-destructive">{operation.errorCode}</p>}
              </>
            )}
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={() => setOpen(false)}>Fechar</Button>
              {operationId && !["completed", "failed", "cancelled"].includes(operation?.status ?? "") &&
                <Button variant="outline" onClick={() => cancel.mutate(operationId)}>Cancelar</Button>}
              {!operationId && <Button onClick={start} disabled={create.isPending || !limit || Number(width) > limit.width || Number(height) > limit.height}>Iniciar conversão</Button>}
            </div>
          </div>
        </div>
      )}
    </>
  );
}
