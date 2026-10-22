"use client";

import { useProjectVideoOperation } from "@/lib/queries/projects";
import { getProjectVideoTrim } from "@/lib/projects";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "@/components/ui/dialog";
import { Progress } from "@/components/ui/progress";
import { ProjectVideo } from "@/lib/projects";
import {
  useCancelProjectVideoConversion,
  useCreateProjectVideoConversion,
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
  const get = useProjectVideoOperation(uid, pid, token, operationId, open, getProjectVideoTrim, ownerId, shareId);
  const cancel = useCancelProjectVideoConversion(uid, pid, token, ownerId, shareId);
  const operation = get.data?.id === operationId ? get.data : undefined;
  const limit = options.data?.resolutionLimits;
  const source = options.data?.source;
  const outputSizeEstimate = source?.size && source.width && source.height
    ? Math.round(source.size * (Number(width) * Number(height)) / (source.width * source.height))
    : null;



  function start() {
    create.mutate({
      videoId: video._id, projectVersion, outputContainer: "mp4", outputVideoCodec: "h264",
      outputAudioCodec: audio === "none" ? null : audio, outputWidth: Number(width), outputHeight: Number(height),
    }, { onSuccess: (result) => setOperationId(result.operationId) });
  }

  function show() {
    if (operation && ["completed", "failed", "cancelled"].includes(operation.status)) setOperationId(null);
    setOpen(true);
    options.mutate(video._id);
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <Button size="sm" variant="outline" disabled={!canEdit} onClick={show}>Converter</Button>
      <DialogContent className="max-h-[85dvh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>Converter {video.name}</DialogTitle>
              <DialogDescription>Escolha a resolução do novo vídeo.</DialogDescription>
            </DialogHeader>
            {!operationId ? (
              <>
                <p className="text-sm text-muted-foreground">Origem: {video.container} · {video.videoCodec} · {video.width}×{video.height}</p>
                <p className="text-sm">Saída: MP4 · H.264 · AAC</p>
                <div className="grid grid-cols-2 gap-3">
                  <label className="text-sm">Largura<Input type="number" min={1} max={limit?.width} value={width} onChange={(e) => setWidth(e.target.value)} /></label>
                  <label className="text-sm">Altura<Input type="number" min={1} max={limit?.height} value={height} onChange={(e) => setHeight(e.target.value)} /></label>
                </div>
                <p className="text-xs text-muted-foreground">
                  Limite do perfil: {limit ? `${limit.width}×${limit.height}` : "a carregar"}.
                  {" "}Estimativa: {outputSizeEstimate
                    ? `${(outputSizeEstimate / (1024 * 1024)).toFixed(1)} MB`
                    : "indisponível"}.
                </p>
              </>
            ) : (
              <>
                <p className="text-sm">Estado: {operation?.status ?? (get.isError ? "Erro de ligação" : "A consultar estado…")}</p>
                <Progress value={operation?.progress ?? 0} />
          {get.isError && <div role="alert" className="space-y-2 text-sm text-destructive">
            <p>Não foi possível consultar o estado. A operação pode continuar no servidor.</p>
            <Button variant="outline" onClick={() => void get.refetch()}>Tentar novamente</Button>
          </div>}
                {operation?.errorCode && <p className="text-sm text-destructive">{operation.errorCode}</p>}
              </>
            )}
            <DialogFooter>
              <Button variant="outline" onClick={() => setOpen(false)}>Fechar</Button>
              {operationId && !["completed", "failed", "cancelled"].includes(operation?.status ?? "") &&
                <Button variant="outline" onClick={() => cancel.mutate(operationId)}>Cancelar</Button>}
              {!operationId && <Button onClick={start} disabled={create.isPending || !limit ||
                !Number.isInteger(Number(width)) || !Number.isInteger(Number(height)) ||
                Number(width) <= 0 || Number(height) <= 0 ||
                Number(width) > limit.width || Number(height) > limit.height}>
                Iniciar conversão
              </Button>}
            </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
