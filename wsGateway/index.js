const http = require("http");
const https = require("https");
const socketIo = require('socket.io');
const jwt = require("jsonwebtoken");

const { read_rabbit_msg } = require("./utils/rabbit_mq.js");
const { emitProjectOperation } = require("./utils/project_events");
const httpServer = http.createServer();
httpServer.listen(4000);

const io = socketIo(httpServer, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"],
    },
    // options
});

io.use((socket, next) => {
    const token = socket.handshake.auth?.token;
    if (!token) return next(new Error("Authentication required"));
    jwt.verify(token, process.env.JWT_SECRET_KEY, (error, payload) => {
        if (error || !payload?.id) return next(new Error("Invalid token"));
        socket.data.userId = String(payload.id);
        socket.data.token = token;
        next();
    });
});

function authorizeProjectRoom(socket, project) {
    return new Promise((resolve, reject) => {
        const ownerId = encodeURIComponent(project?.ownerId || "");
        const projectId = encodeURIComponent(project?.projectId || "");
        if (!ownerId || !projectId) return reject(new Error("Invalid project"));
        const share = project.shareId ? `?share=${encodeURIComponent(project.shareId)}` : "";
        const request = https.request({
            hostname: "projects",
            port: 9001,
            path: `/projects/${ownerId}/${projectId}/ws-access${share}`,
            method: "GET",
            rejectUnauthorized: false,
            headers: { Authorization: `Bearer ${socket.data.token}` },
        }, (response) => {
            response.resume();
            if (response.statusCode === 204) resolve();
            else reject(new Error("Project access denied"));
        });
        request.setTimeout(5000, () => request.destroy(new Error("Project authorization timed out")));
        request.on("error", reject);
        request.end();
    });
}

io.on("connection", (socket) => {
    console.log("a user connected");
    socket.join(socket.data.userId);

    socket.on("join-project", async (project) => {
        try {
            await authorizeProjectRoom(socket, project);
            socket.join(`project:${project.projectId}`);
        } catch (error) {
            socket.emit("project-join-error", { projectId: project?.projectId, message: error.message });
        }
    });

    socket.on("leave-project", (project) => {
        const projectId = typeof project === "string" ? project : project?.projectId;
        if (typeof projectId === "string" && projectId.length > 0) socket.leave(`project:${projectId}`);
    });
        
    socket.on("disconnect", () => {
        console.log("A user disconnected");
    });

});

// id do user como room id

function process_msg() {
    read_rabbit_msg('ws_queue', (msg) => {
        const msg_content = JSON.parse(msg.content.toString());
        const msg_id = msg_content.messageId;
        const timestamp = msg_content.timestamp
        const status = msg_content.status;
        const user = msg_content.user;

        console.log('Received msg:', JSON.stringify(msg_content));

        if (/update-client-preview/.test(msg_id)) {
            if (status == "error") {
                const error_code = msg_content.errorCode;
                const error_msg = msg_content.errorMsg;

                io.to(user).emit("preview-error", { error_code, error_msg }); 

                return;
            }

            const img_url = msg_content.img_url;

            io.to(user).emit("preview-ready", img_url);
        }

        else if (/update-client-process/.test(msg_id)) {

            if (status == "error") {
                const error_code = msg_content.errorCode;
                const error_msg = msg_content.errorMsg;

                io.to(user).emit("process-error", { error_code, error_msg }); 

                return;
            }

            io.to(user).emit("process-update", msg_id);
        }

        else if (msg_content.type === "project-op") {
            emitProjectOperation(io, msg_content);
            }

        //  project updated
        else if (/project-updated/.test(msg_id) || msg_content.type === "project-updated") {
            const projectId = msg_content.projectId;
            const version = msg_content.version;

            if (projectId) {
                io.to(`project:${projectId}`).emit("project-updated", { projectId, version });
            }
        }
    })
}

process_msg();
