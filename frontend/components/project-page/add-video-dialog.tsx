"use client";

import { useRef, useState } from "react";
import { LoaderCircle, Plus } from "lucide-react";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import VideoSubmissionArea from "../video-submission-area";
import { useProjectInfo } from "@/providers/project-provider";
import { useSearchParams } from "next/navigation";
import { useSession } from "@/providers/session-provider";
import { useAddProjectVideo } from "@/lib/mutations/projects";
import { useToast } from "@/hooks/use-toast";

export function AddVideoDialog() {
  const [open, setOpen] = useState(false);
  const [video, setVideo] = useState<File>();
  const [duplicateRetry, setDuplicateRetry] = useState(false);
  const abortRef = useRef<AbortController | null>(null);
  const { _id: pid, version } = useProjectInfo();
  const session = useSession();
  const searchParams = useSearchParams();
  const ownerId = searchParams.get("owner") ?? session.user._id;
  const shareId = searchParams.get("share") ?? undefined;
  const { toast } = useToast();
  const upload = useAddProjectVideo(session.user._id, pid as string, session.token, ownerId, shareId);

  function submit() {
    if (!video) return;
    abortRef.current = new AbortController();
    upload.mutate({ video, projectVersion: version, signal: abortRef.current.signal, duplicateAction: duplicateRetry ? "keep" : "cancel" }, {
      onSuccess: (result) => {
        const metadata = result.data?.metadata;
        toast({
          title: "Vídeo adicionado com sucesso.",
          description: metadata
            ? `${metadata.width}×${metadata.height}, ${metadata.duration.toFixed(1)} s, ${metadata.videoCodec}`
            : undefined,
        });
        setVideo(undefined);
        setOpen(false);
      },
      onError: async (error) => {
        const response = (error as {
          response?: { status?: number; data?: { error?: string | { code?: string } } };
        })?.response;
        const responseError = response?.data?.error;
        const responseCode = typeof responseError === "string"
          ? responseError
          : responseError?.code;
        if ((responseCode === "VIDEO_DUPLICATE" || response?.status === 409) && !duplicateRetry) {
          setDuplicateRetry(window.confirm("Já existe um vídeo com este nome. Pretende manter ambos?"));
          return;
        }
        toast({
          title: "Não foi possível adicionar o vídeo.",
          description: error instanceof Error ? error.message : "Verifique o formato e os limites do vídeo.",
          variant: "destructive",
        });
      },
    });
  }

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild><Button variant="outline"><Plus /> Adicionar vídeo</Button></DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Adicionar vídeo</DialogTitle>
          <DialogDescription>Selecione um MP4 com vídeo H.264.</DialogDescription>
        </DialogHeader>
        <VideoSubmissionArea onSelect={setVideo} disabled={upload.isPending} />
        <DialogFooter>
          <Button onClick={() => abortRef.current?.abort()} variant="outline" disabled={!upload.isPending}>
            Cancelar
          </Button>
          <Button onClick={submit} disabled={!video || upload.isPending}>
            Enviar {upload.isPending && <LoaderCircle className="ml-2 size-4 animate-spin" />}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
