"use client";

import { useEffect, useState } from "react";
import { LoaderCircle, Scissors } from "lucide-react";
import {
  Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader,
  DialogTitle, DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Progress } from "@/components/ui/progress";
import { useToast } from "@/hooks/use-toast";
import { ProjectVideo } from "@/lib/projects";
import {
  useCancelProjectVideoTrim,
  useCreateProjectVideoTrim,
  useGetProjectVideoTrim,
} from "@/lib/mutations/projects";

export function VideoTrimDialog({
  video,
  uid,
  pid,
  token,
  projectVersion,
  ownerId,
  shareId,
  canEdit = true,
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
  const [operationId, setOperationId] = useState<string | null>(null);
  const create = useCreateProjectVideoTrim(uid, pid, token, ownerId, shareId);
  const get = useGetProjectVideoTrim(uid, pid, token, ownerId, shareId);
  const cancel = useCancelProjectVideoTrim(uid, pid, token, ownerId, shareId);
  const { toast } = useToast();
  const operation = get.data;

  useEffect(() => {
    if (!operationId || !open || ["completed", "failed", "cancelled"].includes(operation?.status ?? "")) return;
    const timer = window.setInterval(() => get.mutate(operationId), 2000);
    get.mutate(operationId);
    return () => window.clearInterval(timer);
  }, [operationId, open, operation?.status]);

  function submit() {
    const startSeconds = Number(start);
    const endSeconds = Number(end);
    if (!Number.isFinite(startSeconds) || !Number.isFinite(endSeconds) ||
      startSeconds < 0 || endSeconds > video.duration || endSeconds <= startSeconds ||
      endSeconds - startSeconds < 1) {
      toast({ title: "Intervalo inválido", description: "O recorte deve ter pelo menos 1 segundo.", variant: "destructive" });
      return;
    }
    create.mutate({ videoId: video._id, startSeconds, endSeconds, projectVersion }, {
      onSuccess: (result) => setOperationId(result.operationId),
      onError: (error) => toast({
        title: "Não foi possível criar o recorte",
        description: error instanceof Error ? error.message : "Verifique o acesso, intervalo e quota.",
        variant: "destructive",
      }),
    });
  }

  function close(next: boolean) {
    if (!next && create.isPending) return;
    setOpen(next);
    if (!next) setOperationId(null);
  }

  const active = operation && !["completed", "failed", "cancelled"].includes(operation.status);

  return (
    <Dialog open={open} onOpenChange={close}>
      <DialogTrigger asChild>
        <Button size="sm" variant="outline" disabled={!canEdit}>
          <Scissors className="mr-2 size-4" /> Recortar
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Recortar {video.name}</DialogTitle>
          <DialogDescription>Duração original: {video.duration.toFixed(2)} segundos.</DialogDescription>
        </DialogHeader>
        {!operationId ? (
          <div className="grid grid-cols-2 gap-3">
            <label className="text-sm">Início (s)<Input type="number" min={0} max={video.duration} step="0.01" value={start} onChange={(e) => setStart(e.target.value)} /></label>
            <label className="text-sm">Fim (s)<Input type="number" min={0} max={video.duration} step="0.01" value={end} onChange={(e) => setEnd(e.target.value)} /></label>
          </div>
        ) : (
          <div className="space-y-3">
            <div className="flex items-center justify-between text-sm">
              <span>Estado: {operation?.status ?? "queued"}</span>
              <span>{operation?.progress ?? 0}%</span>
            </div>
            <Progress value={operation?.progress ?? 0} />
            {operation?.errorCode && <p className="text-sm text-destructive">{operation.errorCode}</p>}
          </div>
        )}
        <DialogFooter>
          {active && <Button variant="outline" onClick={() => operationId && cancel.mutate(operationId)}>Cancelar operação</Button>}
          {!operationId && <Button onClick={submit} disabled={create.isPending}>
            {create.isPending && <LoaderCircle className="mr-2 size-4 animate-spin" />} Criar recorte
          </Button>}
          {operation?.status === "completed" && <Button onClick={() => setOpen(false)}>Concluir</Button>}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
