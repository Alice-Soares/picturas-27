"use client";

import { Input } from "@/components/ui/input";
import { Slider } from "@/components/ui/slider";
import { ToolNames } from "@/lib/tool-types";

export const videoToolLabels: Partial<Record<ToolNames, string>> = {
  border: "Moldura", brightness: "Brilho", contrast: "Contraste", cut: "Recortar imagem",
  saturation: "Saturação", binarization: "Preto e branco", rotate: "Rodar",
  resize: "Redimensionar", watermark: "Marca de água",
};

export function VideoToolControls({ procedure, params, onChange }: {
  procedure: ToolNames;
  params: Record<string, unknown>;
  onChange: (params: Record<string, unknown>) => void;
}) {
  const set = (key: string, value: number) => onChange({ ...params, [key]: value });
  const numeric = (key: string, label: string, min = 0) => (
    <label className="space-y-1 text-sm" key={key}>
      <span>{label}</span>
      <Input type="number" min={min} step={1} value={Number.isFinite(Number(params[key] ?? min)) ? Number(params[key] ?? min) : ""}
        onChange={(event) => set(key, event.target.valueAsNumber)} />
    </label>
  );
  const sliderKeys: Partial<Record<ToolNames, string>> = {
    brightness: "brightness", contrast: "contrastFactor", saturation: "saturationFactor",
    binarization: "threshold", rotate: "degrees",
  };
  const key = sliderKeys[procedure];
  if (key) {
    const percent = ["brightness", "contrast", "saturation"].includes(procedure);
    const max = percent ? 2 : procedure === "rotate" ? 360 : 255;
    const value = Number(params[key] ?? (percent ? 1 : 0));
    const display = percent ? `${Math.round(value * 100 - 100)}%` : `${value}${procedure === "rotate" ? "°" : ""}`;
    return (
      <div className="space-y-3 px-1 py-2">
        <Slider aria-label={videoToolLabels[procedure]} min={0} max={max} step={percent ? 0.01 : 1}
          value={[value]} onValueChange={([next]) => set(key, next)} />
        <div className="flex justify-between text-xs text-muted-foreground">
          <span>{percent ? "−100%" : "0"}</span><output className="font-semibold text-foreground">{display}</output>
          <span>{percent ? "+100%" : `${max}${procedure === "rotate" ? "°" : ""}`}</span>
        </div>
      </div>
    );
  }
  if (procedure === "border") {
    const color = `#${["r", "g", "b"].map((channel) => Number(params[channel] ?? 0).toString(16).padStart(2, "0")).join("")}`;
    return <div className="grid grid-cols-2 gap-3">
      {numeric("borderWidth", "Espessura (px)", 1)}
      <label className="space-y-1 text-sm"><span>Cor da moldura</span>
        <Input type="color" value={color} onChange={(event) => {
          const hex = event.target.value;
          onChange({ ...params, r: parseInt(hex.slice(1, 3), 16), g: parseInt(hex.slice(3, 5), 16), b: parseInt(hex.slice(5, 7), 16) });
        }} />
      </label>
    </div>;
  }
  if (procedure === "resize") return <div className="grid grid-cols-2 gap-3">
    {numeric("width", "Largura (px)", 1)}{numeric("height", "Altura (px)", 1)}
  </div>;
  if (procedure === "cut") return <div className="space-y-2">
    <p className="text-xs text-muted-foreground">Pixels a remover de cada margem.</p>
    <div className="grid grid-cols-2 gap-3">
      {numeric("left", "Esquerda (px)")}{numeric("top", "Topo (px)")}
      {numeric("right", "Direita (px)")}{numeric("bottom", "Fundo (px)")}
    </div>
  </div>;
  return <p className="text-sm text-muted-foreground">Aplica a marca de água padrão, sem ajustes adicionais.</p>;
}
