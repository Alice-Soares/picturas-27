"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.join(__dirname, "..");
const read = (relative) => fs.readFileSync(path.join(root, relative), "utf8");
const api = read("lib/projects.ts");
const mutations = read("lib/mutations/projects.ts");
const dialog = read("components/project-page/video-merge-dialog.tsx");
const list = read("components/project-page/project-video-list.tsx");
const page = read("app/dashboard/[pid]/page.tsx");

test("POST concatenação envia IDs ordenados, sem inventar opções de saída", () => {
  assert.match(api, /`\/projects\/\$\{params\.uid\}\/\$\{params\.pid\}\/video-merge`/);
  assert.match(api, /\{ videoIds: params\.videoIds \}/);
  assert.match(api, /Authorization: `Bearer \$\{params\.token\}`/);
});

test("estado e cancelamento reutilizam endpoints de operações de vídeo", () => {
  assert.match(api, /\/video-operations\/\$\{params\.operationId\}/);
  assert.match(api, /\/video-operations\/\$\{params\.operationId\}\/cancel/);
  assert.match(mutations, /useGetProjectVideoMerge/);
  assert.match(mutations, /useCancelProjectVideoMerge/);
});

test("interface só permite proprietário autenticado e não partilhas", () => {
  assert.match(dialog, /!shareId && \(!ownerId \|\| ownerId === uid\) && profile !== "anonymous"/);
  assert.match(page, /profile=\{session\.user\.type\}/);
});

test("validação respeita limites de vídeos e duração", () => {
  assert.match(dialog, /free: \{ count: 5, duration: 300 \}/);
  assert.match(dialog, /premium: \{ count: 15, duration: 1800 \}/);
  assert.match(dialog, /duration <= limits\.duration/);
  assert.match(dialog, /selected\.length >= 2/);
});

test("utilizador pode selecionar, ordenar e remover vídeos", () => {
  assert.match(dialog, /DndContext/);
  assert.match(dialog, /SortableContext/);
  assert.match(dialog, /arrayMove\(prev, from, to\)/);
  assert.match(dialog, /onRemove=\{toggleVideo\}/);
  assert.match(list, /<VideoMergeDialog/);
});

test("consulta periodicamente o estado e atualiza o projeto na conclusão", () => {
  assert.match(dialog, /window\.setInterval\(refresh, 2000\)/);
  assert.match(dialog, /next\.status === "completed"/);
  assert.match(dialog, /qc\.invalidateQueries/);
});
