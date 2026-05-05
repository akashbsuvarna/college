import mongoose from "mongoose";

const notificationSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  message: {
    type: String,
    required: true,
  },
  target: {
    type: String,
    enum: ["all", "students", "teachers"],
    default: "all",
  },
  sentBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Admin",
  }
}, { timestamps: true });

const Notification = mongoose.models.Notification || mongoose.model("Notification", notificationSchema);
export default Notification;
