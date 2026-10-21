"use client";

import { useEffect, useMemo, useState } from "react";
import {
  DndContext, KeyboardSensor, PointerSensor, closestCenter, useSensor, useSensors,
  type DragEndEvent,
} from "@dnd-kit/core";
import {
  SortableContext, arrayMove, sortableKeyboardCoordinates, useSortable,
  verticalListSortingStrategy,
} from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";
import { ArrowDown, ArrowUp, GripVertical, LoaderCircle, Merge, X } from "lucide-react";
import { useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import {
  Dialog, DialogContent, DialogDescription, DialogFooter,
  DialogHeader, DialogTitle, DialogTrigger,
} from "@/components/ui/dialog";
import { Progress } from "@/components/ui/progress";
import { useToast } from "@/hooks/use-toast";
import type { ProjectVideo, VideoMergeOperation } from "@/lib/projects";
import {
  useCancelProjectVideoMerge, useCreateProjectVideoMerge, useGetProjectVideoMerge,
} from "@/lib/mutations/projects";

const LIMITS = {
  free: { count: 5, duration: 300 },
  premium: { count: 15, duration: 1800 },
} as const;
const FINAL_STATES = new Set(["completed", "failed", "cancelled"]);

function getMergeError(error: unknown) {
  const raw = error as { response?: { data?: { error?: string } } } | undefined;
  const code = raw?.response?.data?.error;
  const messages: Record<string, string> = {
    VIDEO_MERGE_TOO_FEW_VIDEOS: "Seleciona pelo menos dois vídeos.",
    VIDEO_MERGE_TOO_MANY_VIDEOS: "A seleção excede o limite do teu perfil.",
    VIDEO_MERGE_DURATION_EXCEEDED: "A duração ultrapassa o limite do teu perfil.",
    VIDEO_MERGE_QUOTA_EXCEEDED: "Esgotaste a quota diária de operações avançadas.",
    VIDEO_MERGE_UNAUTHORIZED: "Não tens permissão para concatenar vídeos neste projeto.",
    VIDEO_MERGE_NOT_FOUND: "Um dos vídeos já não existe no projeto.",
    VIDEO_MERGE_QUEUE_UNAVAILABLE: "O serviço de processamento não está disponível.",
    VIDEO_MERGE_INVALID_VIDEO: "Existe um vídeo com metadados inválidos.",
  };
  return code && messages[code] ? messages[code] : "Não foi possível concluir o pedido. Tenta novamente.";
}

function formatSeconds(value: number) {
  if (!Number.isFinite(value)) return "—";
  const minutes = Math.floor(value / 60);
  const seconds = value - minutes * 60;
  return `${minutes} min ${seconds.toFixed(1)} s`;
}

function SortableVideo({
  video, position, total, onMove, onRemove,
}: {
  video: ProjectVideo;
  position: number;
  total: number;
  onMove: (from: number, to: number) => void;
  onRemove: (id: string) => void;
}) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id: video._id });
  return (
    <div
      ref={setNodeRef}
      style={{ transform: CSS.Transform.toString(transform), transition }}
      className={`flex items-center gap-2 rounded-md border bg-background p-2 ${isDragging ? "z-10 opacity-70" : ""}`}
    >
      <button type="button" {...attributes} {...listeners} aria-label={`Reordenar ${video.name}`}
        className="rounded p-1 hover:bg-muted touch-none" title="Arrastar para reordenar">
        <GripVertical className="size-4" />
      </button>
      <span className="w-6 shrink-0 text-center text-xs text-muted-foreground">{position + 1}</span>
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-medium">{video.name}</p>
        <p className="text-xs text-muted-foreground">{formatSeconds(video.duration)}</p>
      </div>
      <Button size="icon" variant="ghost" type="button" aria-label={`Subir ${video.name}`}
        disabled={position === 0} onClick={() => onMove(position, position - 1)}>
        <ArrowUp className="size-4" />
      </Button>
      <Button size="icon" variant="ghost" type="button" aria-label={`Descer ${video.name}`}
        disabled={position === total - 1} onClick={() => onMove(position, position + 1)}>
        <ArrowDown className="size-4" />
      </Button>
      <Button size="icon" variant="ghost" type="button" aria-label={`Remover ${video.name}`}
        onClick={() => onRemove(video._id)}>
        <X className="size-4" />
      </Button>
    </div>
  );
}

export function VideoMergeDialog({
  videos, uid, pid, token, profile, ownerId, shareId, canEdit = true,
}: {
  videos: ProjectVideo[];
  uid: string;
  pid: string;
  token: string;
  profile: "anonymous" | "free" | "premium";
  ownerId?: string;
  shareId?: string;
  canEdit?: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [operationId, setOperationId] = useState<string | null>(null);
  const [operation, setOperation] = useState<VideoMergeOperation | null>(null);
  const [pollError, setPollError] = useState(false);
  const { toast } = useToast();
  const qc = useQueryClient();
  const create = useCreateProjectVideoMerge(uid, pid, token);
  const get = useGetProjectVideoMerge(uid, pid, token);
  const cancel = useCancelProjectVideoMerge(uid, pid, token);
  const sensors = useSensors(
    useSensor(PointerSensor, { activationConstraint: { distance: 5 } }),
    useSensor(KeyboardSensor, { coordinateGetter: sortableKeyboardCoordinates }),
  );
  const limits = profile === "premium" ? LIMITS.premium : LIMITS.free;
  // A rota de criação exige o proprietário, mesmo que a partilha permita edição.
  const permitted = canEdit && !shareId && (!ownerId || ownerId === uid) && profile !== "anonymous";
  const videosById = useMemo(() => new Map(videos.map((video) => [video._id, video])), [videos]);
  const selected = selectedIds.map((id) => videosById.get(id)).filter((v): v is ProjectVideo => !!v);
  const duration = selected.reduce((sum, video) => sum + video.duration, 0);
  const valid = selected.length >= 2 && selected.length <= limits.count &&
    selected.length === selectedIds.length && selected.every((video) => Number.isFinite(video.duration) && video.duration > 0) &&
    duration <= limits.duration;
  const finished = operation !== null && FINAL_STATES.has(operation.status);

  // Consultas periódicas até a operação terminar. Os detalhes mantêm-se mesmo se fechar o diálogo.
  useEffect(() => {
    if (!open || !operationId || (operation && FINAL_STATES.has(operation.status))) return;
    let stopped = false;
    const refresh = () => get.mutate(operationId, {
      onSuccess: (next) => {
        if (stopped) return;
        setPollError(false);
        setOperation(next);
        if (next.status === "completed") {
          qc.invalidateQueries({ queryKey: ["project", uid, pid, token, ownerId, shareId], refetchType: "all" });
          toast({ title: "Vídeos concatenados", description: "O resultado foi adicionado ao projeto." });
        }
      },
      onError: () => { if (!stopped) setPollError(true); },
    });
    refresh();
    const interval = window.setInterval(refresh, 2000);
    return () => { stopped = true; window.clearInterval(interval); };
    // get.mutate é estável; não reiniciar a cada atualização de mutation state.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, operationId, operation?.status, uid, pid, token, ownerId, shareId, qc]);

  function toggleVideo(id: string) {
    setSelectedIds((prev) => prev.includes(id) ? prev.filter((value) => value !== id) : [...prev, id]);
  }

  function move(from: number, to: number) {
    setSelectedIds((prev) => arrayMove(prev, from, to));
  }

  function dragEnd(event: DragEndEvent) {
    if (!event.over || event.active.id === event.over.id) return;
    setSelectedIds((prev) => {
      const from = prev.indexOf(String(event.active.id));
      const to = prev.indexOf(String(event.over?.id));
      return from < 0 || to < 0 ? prev : arrayMove(prev, from, to);
    });
  }

  function submit() {
    if (!permitted || !valid || operationId) return;
    create.mutate([...selectedIds], {
      onSuccess: (result) => {
        setOperationId(result.operationId);
        setOperation(null);
        setPollError(false);
        toast({ title: "Concatenação iniciada", description: "A operação foi colocada em fila." });
      },
      onError: (error) => toast({ title: "Não foi possível iniciar a concatenação", description: getMergeError(error), variant: "destructive" }),
    });
  }

  function requestCancel() {
    if (!operationId || finished || cancel.isPending) return;
    cancel.mutate(operationId, {
      onSuccess: () => get.mutate(operationId, { onSuccess: setOperation }),
      onError: (error) => toast({ title: "Falha ao cancelar", description: getMergeError(error), variant: "destructive" }),
    });
  }

  function reset() {
    setOperationId(null);
    setOperation(null);
    setSelectedIds([]);
    setPollError(false);
    get.reset();
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button type="button" size="sm" variant="outline" disabled={!permitted || videos.length < 2}>
          <Merge className="mr-2 size-4" /> Concatenar vídeos
        </Button>
      </DialogTrigger>
      <DialogContent className="max-h-[90vh] max-w-2xl overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Concatenar vídeos</DialogTitle>
          <DialogDescription>
            Seleciona pelo menos dois vídeos, define a ordem e inicia o processamento.
            Os originais permanecem no projeto.
          </DialogDescription>
        </DialogHeader>
        {!operationId ? (
          <div className="space-y-4">
            <div className="space-y-1">
              <p className="text-sm font-medium">Vídeos disponíveis</p>
              <div className="max-h-40 space-y-1 overflow-y-auto rounded border p-2">
                {videos.map((video) => (
                  <label key={video._id} className="flex cursor-pointer items-center gap-2 rounded p-1 hover:bg-muted">
                    <input type="checkbox" className="size-4" checked={selectedIds.includes(video._id)}
                      onChange={() => toggleVideo(video._id)} />
                    <span className="min-w-0 flex-1 truncate text-sm">{video.name}</span>
                    <span className="text-xs text-muted-foreground">{formatSeconds(video.duration)}</span>
                  </label>
                ))}
              </div>
            </div>
            {selected.length > 0 && (
              <div className="space-y-2">
                <p className="text-sm font-medium">Ordem de reprodução (arrasta ou usa as setas)</p>
                <DndContext sensors={sensors} collisionDetection={closestCenter} onDragEnd={dragEnd}>
                  <SortableContext items={selectedIds} strategy={verticalListSortingStrategy}>
                    <div className="max-h-60 space-y-2 overflow-y-auto">
                      {selected.map((video, index) => (
                        <SortableVideo key={video._id} video={video} position={index} total={selected.length}
                          onMove={move} onRemove={toggleVideo} />
                      ))}
                    </div>
                  </SortableContext>
                </DndContext>
              </div>
            )}
            <div className="space-y-1 rounded-md bg-muted p-3 text-sm">
              <p>{selectedIds.length} de {limits.count} vídeos · {formatSeconds(duration)} de {formatSeconds(limits.duration)}</p>
              <p className="text-xs text-muted-foreground">Saída: MP4 (H.264/AAC), com resolução e codecs normalizados automaticamente.</p>
              {!valid && selectedIds.length > 0 && (
                <p className="text-sm text-destructive">Seleciona entre 2 e {limits.count} vídeos, com duração total até {formatSeconds(limits.duration)}.</p>
              )}
            </div>
          </div>
        ) : (
          <div className="space-y-3">
            <p className="text-sm">Operação: <span className="font-mono text-xs">{operationId}</span></p>
            <div className="flex justify-between text-sm">
              <span>Estado: {operation?.status ?? "queued"}</span>
              <span>{operation?.progress ?? 0}%</span>
            </div>
            <Progress value={operation?.progress ?? 0} />
            {operation?.errorCode && <p className="text-sm text-destructive">{operation.errorCode}</p>}
            {pollError && <p className="text-sm text-destructive">Falha a consultar o estado. Nova tentativa automática.</p>}
            {operation?.status === "completed" && <p className="text-sm">Vídeo final disponível na lista do projeto.</p>}
            {operation?.status === "failed" && <p className="text-sm">A operação falhou. Podes criar uma nova tentativa.</p>}
            {operation?.status === "cancelled" && <p className="text-sm">A operação foi cancelada.</p>}
          </div>
        )}
        <DialogFooter className="gap-2">
          <Button type="button" variant="outline" onClick={() => setOpen(false)}>Fechar</Button>
          {!operationId && (
            <Button type="button" disabled={!permitted || !valid || create.isPending} onClick={submit}>
              {create.isPending && <LoaderCircle className="mr-2 size-4 animate-spin" />}
              Iniciar concatenação
            </Button>
          )}
          {operationId && !finished && (
            <Button type="button" variant="destructive" disabled={cancel.isPending} onClick={requestCancel}>Cancelar operação</Button>
          )}
          {operationId && finished && <Button type="button" onClick={reset}>Nova concatenação</Button>}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
