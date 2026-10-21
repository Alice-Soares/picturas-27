const mongoose = require("mongoose");

const videoOperationSchema = new mongoose.Schema(
  {
    type: { type: String, enum: ["trim", "frame_tool", "frame_extract", "conversion", "audio", "merge"], required: true },
    audio_action: { type: String, enum: ["remove", "replace", "extract"], required: function requiredForAudio() { return this.type === "audio"; }, default: null },
    replacement_audio_key: { type: String, default: null },
    replacement_audio_name: { type: String, default: null },
    audio_start_seconds: { type: Number, default: null, min: 0 },
    audio_end_seconds: { type: Number, default: null, min: 0 },
    result_audio_id: { type: mongoose.Schema.Types.ObjectId, default: null },
    result_audio_path: { type: String, default: null, select: false },
    audio_output: { container: { type: String, default: null }, audioCodec: { type: String, default: null }, sampleRate: { type: Number, default: null }, channels: { type: Number, default: null }, duration: { type: Number, default: null } },
    user_id: { type: mongoose.Schema.Types.ObjectId, required: true },
    project_id: { type: mongoose.Schema.Types.ObjectId, required: true },
    source_video_id: { type: mongoose.Schema.Types.ObjectId, required: function requiredForSingleVideo() { return this.type !== "merge"; } },
    start_seconds: { type: Number, required: function requiredForLegacy() { return this.type !== "audio" && this.type !== "merge"; }, min: 0, default: 0 },
    end_seconds: { type: Number, required: function requiredForLegacy() { return this.type !== "audio" && this.type !== "merge"; }, default: null },
    // UC-VID-006: manter a ordem solicitada e preservar os videos originais.
    source_video_ids: {
      type: [{ type: mongoose.Schema.Types.ObjectId }],
      default: [],
      validate: {
        validator: function validateMergeSourceIds(ids) {
          if (this.type !== "merge") return true;
          return Array.isArray(ids) && ids.length >= 2 && ids.length <= 15 &&
            new Set(ids.map(String)).size === ids.length;
        },
        message: "VIDEO_MERGE_INVALID_SOURCE_IDS",
      },
    },
    total_duration_seconds: {
      type: Number,
      min: 0,
      required: function requiredForMerge() { return this.type === "merge"; },
    },
    output_fps: { type: Number, default: null, min: 0 },
    target_project_id: { type: mongoose.Schema.Types.ObjectId, default: null },
    max_frames: { type: Number, default: null, min: 1 },
    estimated_frames: { type: Number, default: null, min: 0 },
    extracted_frames: { type: Number, default: 0, min: 0 },
    output_format: { type: String, default: null },
    frame_results: {
      type: [
        {
          object_key: { type: String, required: true },
          sha256: { type: String, required: true },
          frame_index: { type: Number, required: true, min: 0 },
          timestamp_seconds: { type: Number, required: true, min: 0 },
        },
      ],
      default: [],
    },
    tools: {
      type: [
        {
          position: { type: Number, required: true },
          procedure: { type: String, required: true },
          params: { type: mongoose.Schema.Types.Mixed, required: true },
        },
      ],
      default: [],
    },
    output: {
      outputContainer: { type: String, default: null },
      outputVideoCodec: { type: String, default: null },
      outputAudioCodec: { type: String, default: null },
      outputWidth: { type: Number, default: null, min: 1 },
      outputHeight: { type: Number, default: null, min: 1 },
      estimatedSize: { type: Number, default: null, min: 0 },
    },
    frame_attempts: { type: Number, default: 0, min: 0 },
    status: {
      type: String,
      enum: ["queued", "processing", "completed", "failed", "cancelled"],
      default: "queued",
      required: true,
    },
    progress: { type: Number, min: 0, max: 100, default: 0 },
    commit_locked: { type: Boolean, default: false },
    result_video_id: { type: mongoose.Schema.Types.ObjectId, default: null },
    error_code: { type: String, default: null },
    error_message: { type: String, default: null },
    quota_reserved: { type: Boolean, default: false },
    quota_refunded: { type: Boolean, default: false },
    started_at: { type: Date, default: null },
    finished_at: { type: Date, default: null },
    cancelled_at: { type: Date, default: null },
  },
  { timestamps: true },
);

videoOperationSchema.index({ project_id: 1, _id: 1 });

module.exports = mongoose.model("video_operation", videoOperationSchema);
