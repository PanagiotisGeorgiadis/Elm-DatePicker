const fs                 = require("fs");
const path               = require("path");
const express            = require("express");
const app                = express();
const http               = require("http").Server(app);
const io                 = require("socket.io")(http);
const { exec, execSync } = require("child_process");


let inProgress = false;
const elmSourcePath     = path.join(__dirname, "src");
const publicFolderPath  = path.join(__dirname, "public");
const indexFilePath     = path.join(__dirname, "index.html");
const scssFolderPath    = path.join(publicFolderPath, "scss");
const stylesFolderPath  = path.join(publicFolderPath, "styles");
const scriptsFolderPath = path.join(publicFolderPath, "scripts");


// Reset = "\x1b[0m"
// Bright = "\x1b[1m"
// Dim = "\x1b[2m"
// Underscore = "\x1b[4m"
const Blink = "\x1b[5m"
// Reverse = "\x1b[7m"
// Hidden = "\x1b[8m"

// const FgBlack = "\x1b[30m"
const FgRed = "\x1b[31m"
const FgGreen = "\x1b[32m"
const FgYellow = "\x1b[33m"
// FgBlue = "\x1b[34m"
// FgMagenta = "\x1b[35m"
// FgCyan = "\x1b[36m"
FgWhite = "\x1b[37m"

// BgBlack = "\x1b[40m"
// BgRed = "\x1b[41m"
// BgGreen = "\x1b[42m"
// BgYellow = "\x1b[43m"
// BgBlue = "\x1b[44m"
// BgMagenta = "\x1b[45m"
// BgCyan = "\x1b[46m"
BgWhite = "\x1b[47m"


app.use("/styles", express.static(stylesFolderPath));
app.use("/scripts", express.static(scriptsFolderPath));


app.get("/", ( request, response ) => {
    response.sendFile(indexFilePath);
});


let browserClients = [];
io.on("connection", (socket) => {
    browserClients.push(socket);
    socket.on("disconnect", () => {
        let socketIndex = browserClients.indexOf(socket);
        browserClients.splice(socketIndex, 1);
    });
});


const printWatchMsg = (eventType, filename) => {
    console.log(FgWhite);
    console.log(`Detected a ${ eventType } event on ${ filename }. Compiling...`);
}

/* Watch for Elm changes and re-compile & refresh the browser for every client */
fs.watch(elmSourcePath, { recursive : true }, (eventType, filename) => {
    if (!inProgress) {
        inProgress = true;
        console.log("\n");
        printWatchMsg(eventType, filename);
        try {
            console.log(FgYellow);
            execSync("npm run elm-make");
            console.log(FgGreen);
            console.log("Elm compilation was complete. Reloading clients...");
            for(var i = 0; i < browserClients.length; i++) {
                browserClients[i].emit("reload-browser");
            }
        } catch(error) {
            // Ignoring the error because its a duplicate
            // with the error thrown from execSync.
        }
        setTimeout(() => { inProgress = false }, 1000)
    }
});


/* Watch for SCSS compile on change and re-compile & refresh styles on every client */
fs.watch(scssFolderPath, { recursive : true }, (eventType, filename) => {
    // if (!inProgress) {
        console.log("\n");
        printWatchMsg(eventType, filename);
        try {
            // execSync("npm run compile-sass");
            console.log(execSync("npm run compile-sass").toString());
        } catch(error) {
            // Ignoring the error for now ?
        }
        console.log("Reloading styles...");
        for(var i = 0; i < browserClients.length; i++) {
            browserClients[i].emit("reload-css");
        }
    // }
});


let port = 3765;
http.listen(port, () => {
    console.log("Listening on " + port);
});
