"use client";

import { useEffect, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { createProjectVideoAudio, getProjectVideoAudio, cancelProjectVideoAudio, downloadProjectVideoAudio, ProjectVideo } from "@/lib/projects";

function audioErrorMessage(error: unknown) {
  const responseError = (error as { response?: { data?: { error?: unknown } } })?.response?.data?.error;
  const code = typeof responseError === "string"
    ? responseError
    : (responseError as { code?: string } | undefined)?.code;
  if (code === "VIDEO_AUDIO_NO_TRACK") return "O vídeo escolhido não contém uma faixa de áudio.";
  if (code === "VIDEO_AUDIO_FORMAT_UNSUPPORTED") return "Formato não suportado. Escolhe MP3, M4A/AAC ou um vídeo válido com áudio.";
  if (code === "VIDEO_AUDIO_QUOTA_EXCEEDED") return "A quota diária de operações avançadas está esgotada. Tenta novamente quando for renovada.";
  return (error as Error)?.message || "Não foi possível processar o áudio.";
}

export function VideoAudioDialog({ video, uid, pid, token, projectVersion, ownerId, shareId, canEdit }: { video: ProjectVideo; uid: string; pid: string; token: string; projectVersion: number; ownerId?: string; shareId?: string; canEdit?: boolean }) {
  const [open, setOpen] = useState(false); const [removeConfirmOpen, setRemoveConfirmOpen] = useState(false); const [file, setFile] = useState<File>();
  const [start, setStart] = useState(""); const [end, setEnd] = useState(""); const [status, setStatus] = useState(""); const [error, setError] = useState("");
  const [activeOperation, setActiveOperation] = useState<string>();
  const [downloadUrl, setDownloadUrl] = useState<string>();
  const qc = useQueryClient();
  useEffect(() => () => { if (downloadUrl) URL.revokeObjectURL(downloadUrl); }, [downloadUrl]);
  async function run(action: "remove" | "replace" | "extract") {
    setError(""); setStatus("A submeter operação…");
    try {
      const accepted = await createProjectVideoAudio({ uid, pid, token, ownerId, shareId, videoId: video._id, action, projectVersion, file, startSeconds: start ? Number(start) : undefined, endSeconds: end ? Number(end) : undefined });
      setActiveOperation(accepted.operationId);
      let result = await getProjectVideoAudio({ uid, pid, token, ownerId, shareId, operationId: accepted.operationId });
      setStatus(`${result.status} · ${result.progress}%`);
      while (!["completed", "failed", "cancelled"].includes(result.status)) {
        await new Promise((resolve) => setTimeout(resolve, 1500));
        result = await getProjectVideoAudio({ uid, pid, token, ownerId, shareId, operationId: accepted.operationId });
        setStatus(`${result.status} · ${result.progress}%`);
      }
      if (result.status === "completed") {
        if (action === "extract") {
          const url = await downloadProjectVideoAudio({ uid, pid, token, ownerId, shareId, operationId: accepted.operationId });
          setDownloadUrl(url);
          setStatus("Áudio extraído e transferência iniciada.");
        } else {
          setStatus("Concluído. O novo vídeo foi adicionado à biblioteca.");
          await qc.invalidateQueries({ queryKey: ["project", uid, pid, token], refetchType: "all" });
        }
      }
      else setError(result.errorCode || "A operação não foi concluída.");
      setActiveOperation(undefined);
    } catch (e) { setActiveOperation(undefined); setError(audioErrorMessage(e)); setStatus(""); }
  }
  return <Dialog open={open} onOpenChange={setOpen}>
    <DialogTrigger asChild><Button variant="outline" disabled={!canEdit}>Gerir áudio</Button></DialogTrigger>
    <DialogContent>
      <DialogHeader><DialogTitle>Gerir áudio</DialogTitle><DialogDescription>O vídeo original permanece inalterado.</DialogDescription></DialogHeader>
      <div className="space-y-3">
        <Button className="w-full" onClick={() => setRemoveConfirmOpen(true)}>Remover áudio</Button>
        <div className="space-y-2 rounded border p-3">
          <Input type="file" accept="video/*,.mp3,.m4a,audio/mpeg,audio/mp4" onChange={(event) => setFile(event.target.files?.[0])} />
          <p className="text-xs text-muted-foreground">Podes escolher MP3, M4A ou um vídeo com áudio. De um vídeo será usada apenas a primeira faixa de áudio.</p>
          <div className="grid grid-cols-2 gap-2"><Input aria-label="Início do áudio (segundos)" placeholder="Início (opcional)" type="number" min="0" value={start} onChange={(e) => setStart(e.target.value)} /><Input aria-label="Fim do áudio (segundos)" placeholder="Fim (opcional)" type="number" min="0" value={end} onChange={(e) => setEnd(e.target.value)} /></div>
          <Button className="w-full" disabled={!file} onClick={() => run("replace")}>Substituir áudio</Button>
        </div>
        <Button className="w-full" variant="secondary" onClick={() => run("extract")}>Extrair faixa de áudio</Button>
        {status && <p role="status" className="text-sm">{status}</p>}{error && <p role="alert" className="text-sm text-destructive">{error}</p>}
        {downloadUrl && <Button variant="outline" onClick={() => { const link = document.createElement("a"); link.href = downloadUrl; link.download = "audio.m4a"; link.click(); }}>Descarregar novamente</Button>}
        {activeOperation && <Button variant="destructive" onClick={async () => {         try { await cancelProjectVideoAudio({ uid, pid, token, ownerId, shareId, operationId: activeOperation }); setStatus("cancelled"); setActiveOperation(undefined); } catch (e) { setError((e as Error).message); } }}>Cancelar operação</Button>}
      </div>
    </DialogContent>
    <Dialog open={removeConfirmOpen} onOpenChange={setRemoveConfirmOpen}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Remover áudio?</DialogTitle>
          <DialogDescription>Será criada uma cópia sem áudio. O vídeo original permanece inalterado.</DialogDescription>
        </DialogHeader>
        <div className="flex justify-end gap-2">
          <Button variant="outline" onClick={() => setRemoveConfirmOpen(false)}>Cancelar</Button>
          <Button onClick={() => { setRemoveConfirmOpen(false); void run("remove"); }}>Confirmar remoção</Button>
        </div>
      </DialogContent>
    </Dialog>
  </Dialog>;
}
