"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const ts = require("typescript");
const { QueryClient, QueryObserver } = require("@tanstack/react-query");

function load(relative, mocks) {
  const source = fs.readFileSync(path.join(__dirname, "..", relative), "utf8");
  const { outputText } = ts.transpileModule(source, {
    compilerOptions: { target: ts.ScriptTarget.ES2017, module: ts.ModuleKind.CommonJS, jsx: ts.JsxEmit.ReactJSX },
  });
  const exports = {};
  vm.runInNewContext(outputText, {
    exports,
    require: (name) => mocks[name] ?? (name.startsWith("@/") || name.startsWith("../") ? {} : require(name)),
  });
  return exports;
}

for (const kind of ["Images", "Video"]) {
  for (const shared of [false, true]) {
    test(`${kind}: upload atualiza o projeto visível (${shared ? "partilha" : "proprietário"})`, async () => {
      const uid = "viewer";
      const ownerId = shared ? "owner" : uid;
      const shareId = shared ? "share-link" : undefined;
      const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
      const key = ["project", uid, "project-id", "token", ownerId, shareId];
      let stored = [];
      const observer = new QueryObserver(qc, { queryKey: key, queryFn: async () => ({ media: [...stored], version: stored.length }) });
      const unsubscribe = observer.subscribe(() => {});
      await observer.refetch();
      let mutation;
      const hooks = load("lib/mutations/projects.ts", {
        "@tanstack/react-query": { useQueryClient: () => qc, useMutation: (options) => options },
        "../projects": {
          addProjectImages: async () => { stored.push("image"); return "1"; },
          addProjectVideo: async () => { stored.push("video"); return { newVersionHeader: "1" }; },
        },
      });
      const component = load(`components/project-page/add-${kind === "Images" ? "images" : "video"}-dialog.tsx`, {
        react: { useState: () => [false, () => {}], useRef: () => ({ current: null }) },
        "next/navigation": { useSearchParams: () => new URLSearchParams(shared ? "owner=owner&share=share-link" : "") },
        "@/providers/session-provider": { useSession: () => ({ user: { _id: uid }, token: "token" }) },
        "@/providers/project-provider": { useProjectInfo: () => ({ _id: "project-id", version: 0 }) },
        "@/hooks/use-toast": { useToast: () => ({ toast: () => {} }) },
        "@/lib/mutations/projects": {
          [`useAddProject${kind}`]: (...args) => { mutation = hooks[`useAddProject${kind}`](...args); return {}; },
        },
      });
      try {
        component[`Add${kind}Dialog`]();
        const result = await mutation.mutationFn({ images: [], video: {}, projectVersion: 0 });
        await mutation.onSuccess(result);
        assert.equal(observer.getCurrentResult().data.media.length, 1);
        assert.equal(observer.getCurrentResult().data.version, 1);
      } finally {
        unsubscribe();
        qc.clear();
      }
    });
  }
}

for (const [hook, api] of [
  ["Trim", "getProjectVideoTrim"],
  ["Conversion", "getProjectVideoTrim"],
  ["FrameTool", "getProjectVideoFrameTool"],
  ["FrameExtraction", "getProjectVideoFrameExtraction"],
  ["Merge", "getProjectVideoMerge"],
]) {
  test(`${hook}: conclusão atualiza resultados mesmo sem WebSocket`, async () => {
    const qc = new QueryClient();
    let content = "original";
    let status = "processing";
    const ids = hook === "FrameExtraction" ? ["source", "destination"] : ["source"];
    const observers = ids.map((pid) => new QueryObserver(qc, {
      queryKey: ["project", "viewer", pid, "token", "owner", "share"],
      queryFn: async () => content,
    }));
    const unsubscribes = observers.map((observer) => observer.subscribe(() => {}));
    try {
      await Promise.all(observers.map((observer) => observer.refetch()));
      const hooks = load("lib/mutations/projects.ts", {
        "@tanstack/react-query": { useQueryClient: () => qc, useMutation: (options) => options },
        "../projects": { [api]: async () => ({ status, targetProjectId: ids[1] }) },
      });
      const mutation = hooks[`useGetProjectVideo${hook}`]("viewer", "source", "token", "owner", "share");
      content = "processed";
      await mutation.onSuccess(await mutation.mutationFn("operation"));
      assert.equal(observers[0].getCurrentResult().data, "original");
      status = "completed";
      await mutation.onSuccess(await mutation.mutationFn("operation"));
      for (const observer of observers) assert.equal(observer.getCurrentResult().data, "processed");
    } finally {
      unsubscribes.forEach((unsubscribe) => unsubscribe());
      qc.clear();
    }
  });
}

test("eventos do projeto partilhado e reconexão atualizam a cache do utilizador atual", async () => {
  const qc = new QueryClient();
  const effects = [];
  const listeners = new Map();
  const emitted = [];
  let content = "original";
  const observers = ["project", "projectResults"].map((name) => new QueryObserver(qc, {
    queryKey: [name, "viewer", "pid", "token", "owner", "share"],
    queryFn: async () => content,
  }));
  const unsubscribes = observers.map((observer) => observer.subscribe(() => {}));
  const socket = {
    emit: (...args) => emitted.push(args),
    on: (name, fn) => listeners.set(name, fn),
    off: (name) => listeners.delete(name),
  };
  const provider = load("providers/project-provider.tsx", {
    react: {
      createContext: () => ({ Provider: () => null }),
      useState: (value) => [value, () => {}],
      useRef: (value) => ({ current: value }),
      useEffect: (effect) => effects.push(effect),
    },
    "@tanstack/react-query": { useQueryClient: () => qc },
    "@/providers/session-provider": { useSession: () => ({ user: { _id: "viewer" }, token: "token" }) },
    "@/lib/queries/projects": { useGetSocket: () => ({ data: socket }) },
    "@/lib/mutations/projects": { useSetProjectDirty: () => ({ mutate: () => {} }) },
    "@/hooks/use-toast": { useToast: () => ({ toast: () => {} }) },
  });
  const cleanups = [];
  try {
    await Promise.all(observers.map((observer) => observer.refetch()));
    provider.ProjectProvider({ project: { _id: "pid", user_id: "owner", tools: [], version: 1 },
      currentImage: null, preview: { waiting: "", setWaiting: () => {} }, ownerId: "owner", shareId: "share" });
    effects.forEach((effect) => cleanups.push(effect()));
    await Promise.all(observers.map((observer) => observer.refetch()));
    for (const type of ["frame_tool", "conversion", "RESULTS_READY"]) {
      content = type;
      listeners.get("project-op")({ projectId: "pid", op: { type, status: "completed" } });
      // Wait for the refetch already started by the handler.
      while (qc.isFetching()) await new Promise((resolve) => setTimeout(resolve, 0));
      for (const observer of observers) assert.equal(observer.getCurrentResult().data, type);
    }
    content = "reconnected";
    listeners.get("connect")();
    while (qc.isFetching()) await new Promise((resolve) => setTimeout(resolve, 0));
    for (const observer of observers) assert.equal(observer.getCurrentResult().data, content);
    assert.equal(emitted.filter(([name]) => name === "join-project").length, 2);
  } finally {
    cleanups.forEach((cleanup) => cleanup?.());
    unsubscribes.forEach((unsubscribe) => unsubscribe());
    qc.clear();
  }
});

function elements(node) {
  if (!node || typeof node !== "object") return [];
  if (Array.isArray(node)) return node.flatMap(elements);
  return [node, ...elements(node.props?.children)];
}

test("sliders de vídeo alteram os parâmetros sem exigir JSON", () => {
  const { VideoToolControls } = load("components/project-page/video-tool-controls.tsx", {
    "@/components/ui/slider": { Slider: "slider" },
  });
  for (const [procedure, key, next] of [
    ["brightness", "brightness", 1.5], ["contrast", "contrastFactor", 0.5],
    ["saturation", "saturationFactor", 1.2], ["rotate", "degrees", 90],
    ["binarization", "threshold", 160],
  ]) {
    let changed;
    const tree = VideoToolControls({ procedure, params: { [key]: 1, preserved: 42 }, onChange: (params) => { changed = params; } });
    const nodes = elements(tree);
    assert.equal(nodes.some((node) => node.type === "textarea"), false);
    const slider = nodes.find((node) => node.type === "slider");
    assert.ok(slider.props["aria-label"]);
    slider.props.onValueChange([next]);
    assert.equal(changed[key], next);
    assert.equal(changed.preserved, 42);
  }
});

test("campos de vídeo mantêm dimensões, margens e cor no contrato existente", () => {
  const { VideoToolControls } = load("components/project-page/video-tool-controls.tsx", {
    "@/components/ui/input": { Input: "input" },
  });
  for (const [procedure, key] of [["resize", "width"], ["cut", "left"], ["border", "borderWidth"]]) {
    let changed;
    const tree = VideoToolControls({ procedure, params: { [key]: 1 }, onChange: (params) => { changed = params; } });
    elements(tree).find((node) => node.props?.type === "number").props.onChange({ target: { valueAsNumber: 12 } });
    assert.equal(changed[key], 12);
  }
  let color;
  const tree = VideoToolControls({ procedure: "border", params: { borderWidth: 4 }, onChange: (params) => { color = params; } });
  elements(tree).find((node) => node.props?.type === "color").props.onChange({ target: { value: "#12abff" } });
  assert.equal(color.r, 18);
  assert.equal(color.g, 171);
  assert.equal(color.b, 255);
  assert.equal(color.borderWidth, 4);
});

test("barra de progresso contém o preenchimento nos limites e expõe o mesmo valor", () => {
  const { Progress } = load("components/ui/progress.tsx", {
    react: { forwardRef: (render) => render },
    "@radix-ui/react-progress": { Root: "progress", Indicator: "indicator" },
    "@/lib/utils": { cn: (...classes) => classes.filter(Boolean).join(" ") },
  });
  for (const [value, expected] of [[0, 0], [45, 45], [100, 100], [-20, 0], [130, 100]]) {
    const tree = Progress({ value }, null);
    assert.equal(tree.props.value, expected);
    assert.equal(tree.props.children.props.style.width, `${expected}%`);
    assert.equal(tree.props.children.props.style.transform, undefined);
    assert.match(tree.props.className, /overflow-hidden/);
  }
});

test("consulta de estado publica a conclusão enquanto a biblioteca ainda está a carregar", async () => {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  let finishLibrary;
  let slowLibrary = false;
  const library = new QueryObserver(qc, {
    queryKey: ["project", "viewer", "pid", "token", "owner"],
    queryFn: () => slowLibrary ? new Promise((resolve) => { finishLibrary = resolve; }) : Promise.resolve("original"),
  });
  const unsubscribeLibrary = library.subscribe(() => {});
  let observer;
  let unsubscribeOperation;
  let queryOptions;
  const effects = [];
  const hooks = load("lib/queries/projects.ts", {
    react: { useEffect: (effect) => effects.push(effect) },
    "@tanstack/react-query": {
      useQueryClient: () => qc,
      useQuery: (options) => {
        queryOptions = options;
        if (!observer) {
          observer = new QueryObserver(qc, options);
          unsubscribeOperation = observer.subscribe(() => {});
        }
        return observer.getCurrentResult();
      },
    },
  });
  try {
    await library.refetch();
    const fetchOperation = async () => ({ id: "op", status: "completed", progress: 100, errorCode: null });
    hooks.useProjectVideoOperation("viewer", "pid", "token", "op", true, fetchOperation, "owner");
    await observer.refetch();
    slowLibrary = true;
    effects.length = 0;
    const result = hooks.useProjectVideoOperation("viewer", "pid", "token", "op", true, fetchOperation, "owner");
    effects.forEach((effect) => effect());
    assert.equal(library.getCurrentResult().isFetching, true);
    assert.equal(result.data.status, "completed");
    assert.equal(result.data.progress, 100);
    assert.equal(queryOptions.refetchInterval({ state: { data: result.data } }), false);
    assert.equal(queryOptions.refetchInterval({ state: { data: { status: "processing" } } }), 2000);
    finishLibrary("processed");
    while (qc.isFetching()) await new Promise((resolve) => setTimeout(resolve, 0));
    assert.equal(library.getCurrentResult().data, "processed");
  } finally {
    finishLibrary?.("processed");
    unsubscribeOperation?.();
    unsubscribeLibrary();
    qc.clear();
  }
});
