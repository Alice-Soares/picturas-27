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

const availableVideoTools: Array<{ procedure: ToolNames; params: Record<string, number> }> = [
  { procedure: "border", params: { borderWidth: 1, r: 0, g: 0, b: 0 } },
  { procedure: "brightness", params: { brightness: 1.1 } },
  { procedure: "contrast", params: { contrastFactor: 1.1 } },
  { procedure: "cut", params: {} },
  { procedure: "saturation", params: { saturationFactor: 1.1 } },
  { procedure: "binarization", params: { threshold: 127 } },
  { procedure: "rotate", params: { degrees: 90 } },
  { procedure: "resize", params: {} },
  { procedure: "watermark", params: {} },
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
  const compatibleProjectTools = tools.filter((tool) => availableVideoTools.some(({ procedure }) => procedure === tool.procedure));
  function defaultParams(procedure: ToolNames): Record<string, number> {
    if (procedure === "cut") return { left: 0, top: 0, right: Math.max(1, video.width), bottom: Math.max(1, video.height) };
    if (procedure === "resize") return { width: Math.max(1, video.width), height: Math.max(1, video.height) };
    return availableVideoTools.find((tool) => tool.procedure === procedure)?.params ?? {};
  }
  const [open, setOpen] = useState(false);
  const [chain, setChain] = useState<Array<{ procedure: ToolNames; params: string }>>(
    compatibleProjectTools.length
      ? [...compatibleProjectTools]
        .sort((left, right) => left.position - right.position)
        .map((tool) => ({ procedure: tool.procedure, params: JSON.stringify(tool.params ?? defaultParams(tool.procedure), null, 2) }))
      : [{ procedure: "brightness", params: JSON.stringify(defaultParams("brightness"), null, 2) }],
  );
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
    let parsedTools: Array<{ procedure: ToolNames; position: number; params: Record<string, unknown> }>;
    try {
      parsedTools = chain.map((item, position) => ({
        procedure: item.procedure,
        position,
        params: JSON.parse(item.params),
      }));
      if (parsedTools.some((item) => !item.params || Array.isArray(item.params) || typeof item.params !== "object")) {
        throw new Error("invalid params");
      }
    } catch (_) {
      toast({ title: "Parâmetros inválidos", description: "Use um objeto JSON válido em cada ferramenta.", variant: "destructive" });
      return;
    }
    if (chain.length === 0 || !Number.isFinite(startSeconds) || !Number.isFinite(endSeconds) ||
      !Number.isFinite(outputFps) || startSeconds < 0 || endSeconds > video.duration ||
      endSeconds <= startSeconds || outputFps <= 0) {
      toast({ title: "Configuração inválida", description: "Confirme o intervalo, a taxa e a ferramenta.", variant: "destructive" });
      return;
    }
    create.mutate({
      videoId: video._id,
      tools: parsedTools,
      startSeconds,
      endSeconds,
      outputFps,
      projectVersion,
    }, { onSuccess: (result) => setOperationId(result.operationId), onError: (error) => {
      const code = (error as { response?: { data?: { error?: string } } })?.response?.data?.error;
      toast({
        title: "Não foi possível iniciar o processamento",
        description: code || (error instanceof Error ? error.message : "Verifique a ferramenta, os parâmetros e o acesso."),
        variant: "destructive",
      });
    } });
  }

  const active = operation && !["completed", "failed", "cancelled"].includes(operation.status);
  return (
    <Dialog open={open} onOpenChange={(next) => { setOpen(next); if (!next) setOperationId(null); }}>
      <DialogTrigger asChild>
        <Button size="sm" variant="outline" disabled={!canEdit}>
          <WandSparkles className="mr-2 size-4" /> Aplicar ferramenta
        </Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Aplicar ferramenta a {video.name}</DialogTitle>
          <DialogDescription>Processa os fotogramas e cria um novo vídeo.</DialogDescription>
        </DialogHeader>
        {!operationId ? <div className="space-y-3">
          <div className="space-y-2">
            <p className="text-sm">Cadeia de ferramentas</p>
            {chain.map((item, index) => <div className="space-y-1 rounded-md border p-2" key={`${index}-${item.procedure}`}>
              <div className="flex gap-2">
                <select className="w-full rounded-md border bg-background p-2" value={item.procedure}
                  onChange={(event) => setChain((current) => current.map((entry, entryIndex) => {
                    if (entryIndex !== index) return entry;
                    const procedure = event.target.value as ToolNames;
                    const configured = compatibleProjectTools.find((tool) => tool.procedure === procedure);
                    return { procedure, params: JSON.stringify(configured?.params ?? defaultParams(procedure), null, 2) };
                  }))}>
                  {availableVideoTools.map((tool) => <option key={tool.procedure} value={tool.procedure}>{tool.procedure}</option>)}
                </select>
                <Button type="button" variant="outline" disabled={index === 0}
                  onClick={() => setChain((current) => current.map((entry, entryIndex) =>
                    entryIndex === index - 1 ? current[index] : entryIndex === index ? current[index - 1] : entry))}>↑</Button>
                <Button type="button" variant="outline" disabled={index === chain.length - 1}
                  onClick={() => setChain((current) => current.map((entry, entryIndex) =>
                    entryIndex === index ? current[index + 1] : entryIndex === index + 1 ? current[index] : entry))}>↓</Button>
                <Button type="button" variant="outline" disabled={chain.length === 1}
                  onClick={() => setChain((current) => current.filter((_, entryIndex) => entryIndex !== index))}>Remover</Button>
              </div>
              <textarea className="min-h-16 w-full rounded-md border bg-background p-2 font-mono text-xs"
                value={item.params}
                onChange={(event) => setChain((current) => current.map((entry, entryIndex) =>
                  entryIndex === index ? { ...entry, params: event.target.value } : entry))} />
            </div>)}
            <Button type="button" variant="outline" onClick={() => {
              const first = availableVideoTools[0];
              if (first) setChain((current) => [...current, {
                procedure: first.procedure,
                params: JSON.stringify(defaultParams(first.procedure), null, 2),
              }]);
            }}>Adicionar ferramenta</Button>
          </div>
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
          {!operationId && <Button onClick={submit} disabled={create.isPending || chain.length === 0}>{create.isPending && <LoaderCircle className="mr-2 size-4 animate-spin" />} Processar vídeo</Button>}
          {operation?.status === "completed" && <Button onClick={() => setOpen(false)}>Concluir</Button>}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
