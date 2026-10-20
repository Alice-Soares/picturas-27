"use client";

import { useEffect, useState } from "react";
import { LoaderCircle, WandSparkles } from "lucide-react";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Progress } from "@/components/ui/progress";
import { useToast } from "@/hooks/use-toast";
import { ProjectToolResponse, ProjectVideo } from "@/lib/projects";
import { ToolNames } from "@/lib/tool-types";
import { useCancelProjectVideoTrim, useCreateProjectVideoFrameTool, useGetProjectVideoFrameTool } from "@/lib/mutations/projects";

const compatibleVideoTools: ToolNames[] = [
  "border", "brightness", "contrast", "cut", "scale", "saturation",
  "binarization", "rotate", "resize", "watermark",
];

export function VideoFrameToolDialog({
  video, tools, uid, pid, token, projectVersion, ownerId, shareId, canEdit = true,
}: {
  video: ProjectVideo;
  tools: ProjectToolResponse[];
  uid: string;
  pid: string;
  token: string;
  projectVersion: number;
  ownerId?: string;
  shareId?: string;
  canEdit?: boolean;
}) {
  const compatibleTools = tools.filter((tool) => compatibleVideoTools.includes(tool.procedure));
  const [open, setOpen] = useState(false);
  const [procedure, setProcedure] = useState(compatibleTools[0]?.procedure ?? "");
  const [params, setParams] = useState(JSON.stringify(compatibleTools[0]?.params ?? {}, null, 2));
  const [start, setStart] = useState("0");
  const [end, setEnd] = useState(String(Math.max(1, video.duration)));
  const [fps, setFps] = useState(String(video.fps || 25));
  const [operationId, setOperationId] = useState<string | null>(null);
  const create = useCreateProjectVideoFrameTool(uid, pid, token, ownerId, shareId);
  const get = useGetProjectVideoFrameTool(uid, pid, token, ownerId, shareId);
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
    const outputFps = Number(fps);
    let parsedParams: Record<string, unknown>;
    try { parsedParams = JSON.parse(params); } catch (_) {
      toast({ title: "Parâmetros inválidos", description: "Use um objeto JSON válido.", variant: "destructive" });
      return;
    }
    if (!procedure || !Number.isFinite(startSeconds) || !Number.isFinite(endSeconds) ||
      !Number.isFinite(outputFps) || startSeconds < 0 || endSeconds > video.duration ||
      endSeconds <= startSeconds || outputFps <= 0) {
      toast({ title: "Configuração inválida", description: "Confirme o intervalo, a taxa e a ferramenta.", variant: "destructive" });
      return;
    }
    create.mutate({
      videoId: video._id,
      tools: [{ procedure, position: 0, params: parsedParams }],
      startSeconds,
      endSeconds,
      outputFps,
      projectVersion,
    }, { onSuccess: (result) => setOperationId(result.operationId), onError: () => toast({
      title: "Não foi possível iniciar o processamento",
      description: "Verifique a ferramenta, os parâmetros, o acesso e a quota.",
      variant: "destructive",
    }) });
  }

  const active = operation && !["completed", "failed", "cancelled"].includes(operation.status);
  return (
    <Dialog open={open} onOpenChange={(next) => { setOpen(next); if (!next) setOperationId(null); }}>
      <DialogTrigger asChild>
        <Button size="sm" variant="outline" disabled={!canEdit || compatibleTools.length === 0}>
          <WandSparkles className="mr-2 size-4" /> Aplicar ferramenta
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Aplicar ferramenta a {video.name}</DialogTitle>
          <DialogDescription>Processa os fotogramas e cria um novo vídeo.</DialogDescription>
        </DialogHeader>
        {!operationId ? <div className="space-y-3">
          <label className="text-sm">Ferramenta<select className="mt-1 w-full rounded-md border bg-background p-2" value={procedure} onChange={(event) => setProcedure(event.target.value as ToolNames)}>
            {compatibleTools.map((tool) => <option key={`${tool.position}-${tool.procedure}`} value={tool.procedure}>{tool.procedure}</option>)}
          </select></label>
          <label className="text-sm">Parâmetros JSON<textarea className="mt-1 min-h-20 w-full rounded-md border bg-background p-2 font-mono text-xs" value={params} onChange={(event) => setParams(event.target.value)} /></label>
          <div className="grid grid-cols-3 gap-2">
            <label className="text-sm">Início<Input type="number" min={0} value={start} onChange={(event) => setStart(event.target.value)} /></label>
            <label className="text-sm">Fim<Input type="number" max={video.duration} value={end} onChange={(event) => setEnd(event.target.value)} /></label>
            <label className="text-sm">FPS<Input type="number" min={1} value={fps} onChange={(event) => setFps(event.target.value)} /></label>
          </div>
        </div> : <div className="space-y-3">
          <div className="flex justify-between text-sm"><span>Estado: {operation?.status ?? "queued"}</span><span>{operation?.progress ?? 0}%</span></div>
          <Progress value={operation?.progress ?? 0} />
          {operation?.errorCode && <p className="text-sm text-destructive">{operation.errorCode}</p>}
        </div>}
        <DialogFooter>
          {active && <Button variant="outline" onClick={() => operationId && cancel.mutate(operationId)}>Cancelar operação</Button>}
          {!operationId && <Button onClick={submit} disabled={create.isPending || compatibleTools.length === 0}>{create.isPending && <LoaderCircle className="mr-2 size-4 animate-spin" />} Processar vídeo</Button>}
          {operation?.status === "completed" && <Button onClick={() => setOpen(false)}>Concluir</Button>}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
