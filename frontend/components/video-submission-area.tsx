"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export default function VideoSubmissionArea({
  onSelect,
  disabled,
}: {
  onSelect: (file: File | undefined) => void;
  disabled?: boolean;
}) {
  const [name, setName] = useState("");
  return (
    <div className="space-y-3">
      <Input
        type="file"
        accept="video/mp4,.mp4"
        disabled={disabled}
        onChange={(event) => {
          const file = event.target.files?.[0];
          setName(file?.name ?? "");
          onSelect(file);
        }}
      />
      {name && <p className="text-sm text-muted-foreground">{name}</p>}
      <Button type="button" variant="outline" onClick={() => onSelect(undefined)} disabled={!name || disabled}>
        Limpar seleção
      </Button>
    </div>
  );
}
