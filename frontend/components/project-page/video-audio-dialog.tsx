"use client";

import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { createProjectVideoAudio, getProjectVideoAudio, cancelProjectVideoAudio, ProjectVideo } from "@/lib/projects";

export function VideoAudioDialog({ video, uid, pid, token, projectVersion, canEdit }: { video: ProjectVideo; uid: string; pid: string; token: string; projectVersion: number; canEdit?: boolean }) {
  const [open, setOpen] = useState(false); const [file, setFile] = useState<File>();
  const [start, setStart] = useState(""); const [end, setEnd] = useState(""); const [status, setStatus] = useState(""); const [error, setError] = useState("");
  const [activeOperation, setActiveOperation] = useState<string>();
  const qc = useQueryClient();
  async function run(action: "remove" | "replace" | "extract") {
    setError(""); setStatus("A submeter operação…");
    try {
      const accepted = await createProjectVideoAudio({ uid, pid, token, videoId: video._id, action, projectVersion, file, startSeconds: start ? Number(start) : undefined, endSeconds: end ? Number(end) : undefined });
      setActiveOperation(accepted.operationId);
      let result = await getProjectVideoAudio({ uid, pid, token, operationId: accepted.operationId });
      setStatus(`${result.status} · ${result.progress}%`);
      while (!["completed", "failed", "cancelled"].includes(result.status)) {
        await new Promise((resolve) => setTimeout(resolve, 1500));
        result = await getProjectVideoAudio({ uid, pid, token, operationId: accepted.operationId });
        setStatus(`${result.status} · ${result.progress}%`);
      }
      if (result.status === "completed") { setStatus("Concluído. O resultado foi adicionado à biblioteca."); await qc.invalidateQueries({ queryKey: ["project", uid, pid, token], refetchType: "all" }); }
      else setError(result.errorCode || "A operação não foi concluída.");
      setActiveOperation(undefined);
    } catch (e) { setActiveOperation(undefined); setError((e as Error).message || "Não foi possível processar o áudio."); setStatus(""); }
  }
  return <Dialog open={open} onOpenChange={setOpen}>
    <DialogTrigger asChild><Button variant="outline" disabled={!canEdit}>Gerir áudio</Button></DialogTrigger>
    <DialogContent>
      <DialogHeader><DialogTitle>Gerir áudio</DialogTitle><DialogDescription>O vídeo original permanece inalterado.</DialogDescription></DialogHeader>
      <div className="space-y-3">
        <Button className="w-full" onClick={() => run("remove")}>Remover áudio</Button>
        <div className="space-y-2 rounded border p-3">
          <Input type="file" accept=".mp3,.m4a,audio/mpeg,audio/mp4" onChange={(event) => setFile(event.target.files?.[0])} />
          <div className="grid grid-cols-2 gap-2"><Input aria-label="Início do áudio (segundos)" placeholder="Início (opcional)" type="number" min="0" value={start} onChange={(e) => setStart(e.target.value)} /><Input aria-label="Fim do áudio (segundos)" placeholder="Fim (opcional)" type="number" min="0" value={end} onChange={(e) => setEnd(e.target.value)} /></div>
          <Button className="w-full" disabled={!file} onClick={() => run("replace")}>Substituir áudio</Button>
        </div>
        <Button className="w-full" variant="secondary" onClick={() => run("extract")}>Extrair faixa de áudio</Button>
        {status && <p role="status" className="text-sm">{status}</p>}{error && <p role="alert" className="text-sm text-destructive">{error}</p>}
        {activeOperation && <Button variant="destructive" onClick={async () => { try { await cancelProjectVideoAudio({ uid, pid, token, operationId: activeOperation }); setStatus("cancelled"); setActiveOperation(undefined); } catch (e) { setError((e as Error).message); } }}>Cancelar operação</Button>}
      </div>
    </DialogContent>
  </Dialog>;
}
