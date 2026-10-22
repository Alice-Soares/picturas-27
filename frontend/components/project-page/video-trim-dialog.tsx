"use client";

import { useProjectVideoOperation } from "@/lib/queries/projects";
import { getProjectVideoTrim } from "@/lib/projects";

import { useState } from "react";
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
  const get = useProjectVideoOperation(uid, pid, token, operationId, open, getProjectVideoTrim, ownerId, shareId);
  const cancel = useCancelProjectVideoTrim(uid, pid, token, ownerId, shareId);
  const { toast } = useToast();
  const operation = get.data?.id === operationId ? get.data : undefined;



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
      onError: (error) => {
        const code = (error as { response?: { data?: { error?: string } } })?.response?.data?.error;
        toast({
          title: "Não foi possível criar o recorte",
          description: code === "VIDEO_TRIM_QUOTA_EXCEEDED"
            ? "A quota diária de operações avançadas está esgotada. Tenta novamente quando for renovada."
            : code || (error instanceof Error ? error.message : "Verifique o acesso e o intervalo."),
          variant: "destructive",
        });
      },
    });
  }

  function close(next: boolean) {
    if (!next && create.isPending) return;
    setOpen(next);
    if (!next) setOperationId(null);
  }

  const active = !!operationId && !["completed", "failed", "cancelled"].includes(operation?.status ?? "");

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
              <span>Estado: {operation?.status ?? (get.isError ? "Erro de ligação" : "A consultar estado…")}</span>
              <span>{operation?.progress ?? 0}%</span>
            </div>
            <Progress value={operation?.progress ?? 0} />
          {get.isError && <div role="alert" className="space-y-2 text-sm text-destructive">
            <p>Não foi possível consultar o estado. A operação pode continuar no servidor.</p>
            <Button variant="outline" onClick={() => void get.refetch()}>Tentar novamente</Button>
          </div>}
            {operation?.errorCode && <p className="text-sm text-destructive">{operation.errorCode}</p>}
          </div>
        )}
        <DialogFooter>
          {active && <Button variant="outline" onClick={() => operationId && cancel.mutate(operationId)}>Cancelar operação</Button>}
          {!operationId && <Button onClick={submit} disabled={create.isPending}>
            {create.isPending && <LoaderCircle className="mr-2 size-4 animate-spin" />} Criar recorte
          </Button>}
          {operation?.status === "completed" && <Button onClick={() => { setOpen(false); setOperationId(null); }}>Concluir</Button>}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
