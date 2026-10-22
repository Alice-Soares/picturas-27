"use client";

import { useProjectVideoOperation } from "@/lib/queries/projects";
import { getProjectVideoFrameTool } from "@/lib/projects";

import { useState } from "react";
import { LoaderCircle, WandSparkles } from "lucide-react";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Progress } from "@/components/ui/progress";
import { useToast } from "@/hooks/use-toast";
import { ProjectToolResponse, ProjectVideo } from "@/lib/projects";
import { VideoToolControls, videoToolLabels } from "./video-tool-controls";
import { ToolNames } from "@/lib/tool-types";
import { useCancelProjectVideoTrim, useCreateProjectVideoFrameTool } from "@/lib/mutations/projects";

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
    if (procedure === "cut") return { left: 0, top: 0, right: 0, bottom: 0 };
    if (procedure === "resize") return { width: Math.max(1, video.width), height: Math.max(1, video.height) };
    return availableVideoTools.find((tool) => tool.procedure === procedure)?.params ?? {};
  }
  const [open, setOpen] = useState(false);
  const [chain, setChain] = useState<Array<{ procedure: ToolNames; params: Record<string, unknown> }>>(
    compatibleProjectTools.length
      ? [...compatibleProjectTools]
        .sort((left, right) => left.position - right.position)
        .map((tool) => ({ procedure: tool.procedure, params: { ...defaultParams(tool.procedure), ...tool.params } }))
      : [{ procedure: "brightness", params: defaultParams("brightness") }],
  );
  const [start, setStart] = useState("0");
  const [end, setEnd] = useState(String(Math.max(1, video.duration)));
  const [fps, setFps] = useState(String(video.fps || 25));
  const [operationId, setOperationId] = useState<string | null>(null);
  const create = useCreateProjectVideoFrameTool(uid, pid, token, ownerId, shareId);
  const get = useProjectVideoOperation(uid, pid, token, operationId, open, getProjectVideoFrameTool, ownerId, shareId);
  const cancel = useCancelProjectVideoTrim(uid, pid, token, ownerId, shareId);
  const { toast } = useToast();
  const operation = get.data?.id === operationId ? get.data : undefined;



  function submit() {
    const startSeconds = Number(start);
    const endSeconds = Number(end);
    const outputFps = Number(fps);
    const parsedTools = chain.map((item, position) => ({ ...item, position }));
    if (parsedTools.some((item) => Object.values(item.params).some(
      (value) => typeof value === "number" && !Number.isFinite(value),
    ))) {
      toast({ title: "Parâmetros inválidos", description: "Preencha os valores de cada ferramenta.", variant: "destructive" });
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

  const active = !!operationId && !["completed", "failed", "cancelled"].includes(operation?.status ?? "");
  return (
    <Dialog open={open} onOpenChange={(next) => { setOpen(next); if (!next) setOperationId(null); }}>
      <DialogTrigger asChild>
        <Button size="sm" variant="outline" disabled={!canEdit}>
          <WandSparkles className="mr-2 size-4" /> Aplicar ferramenta
        </Button>
      </DialogTrigger>
      <DialogContent className="max-h-[85dvh] overflow-y-auto sm:max-w-xl">
        <DialogHeader>
          <DialogTitle>Aplicar ferramenta a {video.name}</DialogTitle>
          <DialogDescription>Processa os fotogramas e cria um novo vídeo.</DialogDescription>
        </DialogHeader>
        {!operationId ? <div className="space-y-3">
          <div className="space-y-2">
            <p className="text-sm">Cadeia de ferramentas</p>
            {chain.map((item, index) => <div className="space-y-1 rounded-md border p-2" key={`${index}-${item.procedure}`}>
              <div className="flex gap-2">
                <select aria-label={`Ferramenta ${index + 1}`} className="w-full rounded-md border bg-background p-2" value={item.procedure}
                  onChange={(event) => setChain((current) => current.map((entry, entryIndex) => {
                    if (entryIndex !== index) return entry;
                    const procedure = event.target.value as ToolNames;
                    const configured = compatibleProjectTools.find((tool) => tool.procedure === procedure);
                    return { procedure, params: { ...defaultParams(procedure), ...configured?.params } };
                  }))}>
                  {availableVideoTools.map((tool) => <option key={tool.procedure} value={tool.procedure}>{videoToolLabels[tool.procedure]}</option>)}
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
              <VideoToolControls procedure={item.procedure} params={item.params}
                onChange={(params) => setChain((current) => current.map((entry, entryIndex) =>
                  entryIndex === index ? { ...entry, params } : entry))} />
            </div>)}
            <Button type="button" variant="outline" onClick={() => {
              const first = availableVideoTools[0];
              if (first) setChain((current) => [...current, {
                procedure: first.procedure,
                params: defaultParams(first.procedure),
              }]);
            }}>Adicionar ferramenta</Button>
          </div>
          <div className="grid grid-cols-3 gap-2">
            <label className="text-sm">Início<Input type="number" min={0} value={start} onChange={(event) => setStart(event.target.value)} /></label>
            <label className="text-sm">Fim<Input type="number" max={video.duration} value={end} onChange={(event) => setEnd(event.target.value)} /></label>
            <label className="text-sm">FPS<Input type="number" min={1} value={fps} onChange={(event) => setFps(event.target.value)} /></label>
          </div>
        </div> : <div className="space-y-3">
          <div className="flex justify-between text-sm"><span>Estado: {operation?.status ?? (get.isError ? "Erro de ligação" : "A consultar estado…")}</span><span>{operation?.progress ?? 0}%</span></div>
          <Progress value={operation?.progress ?? 0} />
          {get.isError && <div role="alert" className="space-y-2 text-sm text-destructive">
            <p>Não foi possível consultar o estado. A operação pode continuar no servidor.</p>
            <Button variant="outline" onClick={() => void get.refetch()}>Tentar novamente</Button>
          </div>}
          {operation?.errorCode && <p className="text-sm text-destructive">{operation.errorCode}</p>}
        </div>}
        <DialogFooter>
          {active && <Button variant="outline" onClick={() => operationId && cancel.mutate(operationId)}>Cancelar operação</Button>}
          {!operationId && <Button onClick={submit} disabled={create.isPending || chain.length === 0}>{create.isPending && <LoaderCircle className="mr-2 size-4 animate-spin" />} Processar vídeo</Button>}
          {operation?.status === "completed" && <Button onClick={() => { setOpen(false); setOperationId(null); }}>Concluir</Button>}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
