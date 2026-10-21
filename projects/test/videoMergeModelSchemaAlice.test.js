"use strict";
// Verificacao estrutural do esquema UC-VID-006 sobre a versao da Alice.
// Nao substitui validacao Mongoose com MongoDB.
const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

function loadFields() {
  const filename = path.resolve(__dirname, "../models/videoOperation.js");
  const source = fs.readFileSync(filename, "utf8");
  let fields;
  function FakeSchema(definition) { fields = definition; }
  FakeSchema.Types = { ObjectId: Symbol("ObjectId") };
  FakeSchema.prototype.index = function () {};
  const module = { exports: {} };
  vm.runInNewContext(source, {
    module, exports: module.exports,
    require(name) {
      if (name !== "mongoose") throw Error(`Import inesperado: ${name}`);
      return { Schema: FakeSchema, model(name, schema) { assert.equal(name, "video_operation"); return { schema }; } };
    },
  }, { filename });
  return fields;
}
const fields = loadFields();
const legacy = ["trim", "frame_tool", "frame_extract", "conversion"];

test("mantem cinco operacoes existentes (incluindo audio) e acrescenta merge", () => {
  assert.deepEqual(Array.from(fields.type.enum), [...legacy, "audio", "merge"]);
});
test("operacoes anteriores mantem os requisitos de origem", () => {
  for (const type of [...legacy, "audio"]) assert.equal(fields.source_video_id.required.call({ type }), true);
  for (const type of legacy) {
    assert.equal(fields.start_seconds.required.call({ type }), true);
    assert.equal(fields.end_seconds.required.call({ type }), true);
  }
});
test("audio continua sem exigir os intervalos legacy", () => {
  for (const key of ["start_seconds", "end_seconds"]) {
    assert.equal(fields[key].required.call({ type: "audio" }), false);
  }
  assert.equal(fields.audio_action.required.call({ type: "audio" }), true);
  assert.equal(fields.audio_action.required.call({ type: "merge" }), false);
});
test("merge nao exige fonte unica nem intervalo legacy", () => {
  for (const key of ["source_video_id", "start_seconds", "end_seconds"]) {
    assert.equal(fields[key].required.call({ type: "merge" }), false);
  }
});
test("duracao total obrigatoria apenas em merge", () => {
  assert.equal(fields.total_duration_seconds.required.call({ type: "merge" }), true);
  for (const type of [...legacy, "audio"]) assert.equal(fields.total_duration_seconds.required.call({ type }), false);
});
test("IDs de merge devem estar entre 2 e 15, sem duplicados", () => {
  const validate = (ids, type = "merge") => fields.source_video_ids.validate.validator.call({ type }, ids);
  assert.equal(validate([]), false);
  assert.equal(validate(["a"]), false);
  assert.equal(validate(["a", "b"]), true);
  assert.equal(validate(["a", "a"]), false);
  assert.equal(validate(Array.from({ length: 15 }, (_, i) => String(i))), true);
  assert.equal(validate(Array.from({ length: 16 }, (_, i) => String(i))), false);
  assert.equal(validate([], "audio"), true);
});
test("campos existentes de audio, video e controlo continuam presentes", () => {
  for (const key of ["audio_action", "replacement_audio_key", "audio_output", "result_audio_id", "frame_results", "tools", "output", "status", "progress", "result_video_id", "quota_reserved", "quota_refunded"]) {
    assert.ok(fields[key], key);
  }
});
