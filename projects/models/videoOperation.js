const mongoose = require("mongoose");

const videoOperationSchema = new mongoose.Schema(
  {
    type: { type: String, enum: ["trim", "frame_tool"], required: true },
    user_id: { type: mongoose.Schema.Types.ObjectId, required: true },
    project_id: { type: mongoose.Schema.Types.ObjectId, required: true },
    source_video_id: { type: mongoose.Schema.Types.ObjectId, required: true },
    start_seconds: { type: Number, required: true, min: 0 },
    end_seconds: { type: Number, required: true },
    output_fps: { type: Number, default: null, min: 0 },
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
    frame_attempts: { type: Number, default: 0, min: 0 },
    status: {
      type: String,
      enum: ["queued", "processing", "completed", "failed", "cancelled"],
      default: "queued",
      required: true,
    },
    progress: { type: Number, min: 0, max: 100, default: 0 },
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
