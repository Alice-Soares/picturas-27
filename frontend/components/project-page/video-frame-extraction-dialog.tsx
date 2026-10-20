"use client";

import { useEffect, useState } from "react";
import { Images, LoaderCircle } from "lucide-react";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Progress } from "@/components/ui/progress";
import { useToast } from "@/hooks/use-toast";
import { ProjectVideo } from "@/lib/projects";
import { useCancelProjectVideoTrim, useCreateProjectVideoFrameExtraction, useGetProjectVideoFrameExtraction } from "@/lib/mutations/projects";

export function VideoFrameExtractionDialog({
  video, uid, pid, token, projectVersion, ownerId, shareId, canEdit = true,
}: {
  video: ProjectVideo;
  uid: string;
  pid: string;
  token: string;
  projectVersion: number;
  ownerId?: string;
  shareId?: string;
  canEdit?: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [start, setStart] = useState("0");
  const [end, setEnd] = useState(String(Math.max(1, video.duration)));
  const [maxFrames, setMaxFrames] = useState("100");
  const [operationId, setOperationId] = useState<string | null>(null);
  const create = useCreateProjectVideoFrameExtraction(uid, pid, token, ownerId, shareId);
  const get = useGetProjectVideoFrameExtraction(uid, pid, token, ownerId, shareId);
  const cancel = useCancelProjectVideoTrim(uid, pid, token, ownerId, shareId);
  const { toast } = useToast();
  const operation = get.data;
  const refreshOperation = get.mutate;

  useEffect(() => {
    if (!operationId || !open || ["completed", "failed", "cancelled"].includes(operation?.status ?? "")) return;
    const timer = window.setInterval(() => refreshOperation(operationId), 2000);
    refreshOperation(operationId);
    return () => window.clearInterval(timer);
  }, [operationId, open, operation?.status, refreshOperation]);

  function submit() {
    const startSeconds = Number(start);
    const endSeconds = Number(end);
    const requestedFrames = Number(maxFrames);
    if (!Number.isFinite(startSeconds) || !Number.isFinite(endSeconds) || !Number.isInteger(requestedFrames) ||
      startSeconds < 0 || endSeconds > video.duration || endSeconds <= startSeconds || requestedFrames <= 0) {
      toast({ title: "Configuração inválida", description: "Confirme o intervalo e a quantidade de fotogramas.", variant: "destructive" });
      return;
    }
    create.mutate({ videoId: video._id, startSeconds, endSeconds, maxFrames: requestedFrames, projectVersion }, {
      onSuccess: (result) => setOperationId(result.operationId),
      onError: () => toast({ title: "Não foi possível iniciar a extração", description: "Verifique o acesso, os limites e a quota.", variant: "destructive" }),
    });
  }

  const active = operation && !["completed", "failed", "cancelled"].includes(operation.status);
  return (
    <Dialog open={open} onOpenChange={(next) => { setOpen(next); if (!next) setOperationId(null); }}>
      <DialogTrigger asChild>
        <Button size="sm" variant="outline" disabled={!canEdit} title="Extrair fotogramas">
          <Images className="mr-2 size-4" /> Extrair fotogramas
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Extrair fotogramas de {video.name}</DialogTitle>
          <DialogDescription>As imagens serão guardadas no projeto como JPEG.</DialogDescription>
        </DialogHeader>
        {!operationId ? <div className="grid grid-cols-3 gap-2">
          <label className="text-sm">Início<Input type="number" min={0} value={start} onChange={(event) => setStart(event.target.value)} /></label>
          <label className="text-sm">Fim<Input type="number" max={video.duration} value={end} onChange={(event) => setEnd(event.target.value)} /></label>
          <label className="text-sm">Máximo<Input type="number" min={1} value={maxFrames} onChange={(event) => setMaxFrames(event.target.value)} /></label>
        </div> : <div className="space-y-3">
          <div className="flex justify-between text-sm"><span>Estado: {operation?.status ?? "queued"}</span><span>{operation?.extractedFrames ?? 0} / {operation?.estimatedFrames ?? "-"}</span></div>
          <Progress value={operation?.progress ?? 0} />
          {operation?.errorCode && <p className="text-sm text-destructive">{operation.errorCode}</p>}
        </div>}
        <DialogFooter>
          {active && <Button variant="outline" onClick={() => operationId && cancel.mutate(operationId)}>Cancelar operação</Button>}
          {!operationId && <Button onClick={submit} disabled={create.isPending}>{create.isPending && <LoaderCircle className="mr-2 size-4 animate-spin" />} Extrair JPEGs</Button>}
          {operation?.status === "completed" && <Button onClick={() => setOpen(false)}>Concluir</Button>}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}