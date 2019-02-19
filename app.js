const fs                 = require("fs");
const path               = require("path");
const express            = require("express");
const app                = express();
const http               = require("http").Server(app);
const io                 = require("socket.io")(http);
const { execSync }       = require("child_process");
const { printMsg
      , printWarningMsg
      , printSuccessMsg
      }                  = require("./private/console-helpers.js");

let elmCompilationInProgress  = false;
let scssCompilationInProgress = false;

const elmSourcePath     = path.join(__dirname, "src");
const publicFolderPath  = path.join(__dirname, "public");
const indexFilePath     = path.join(__dirname, "index.html");
const scssFolderPath    = path.join(publicFolderPath, "scss");
const stylesFolderPath  = path.join(publicFolderPath, "styles");
const scriptsFolderPath = path.join(publicFolderPath, "scripts");


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



/* Watch for Elm changes and re-compile & refresh the browser for every client */
fs.watch(elmSourcePath, { recursive : true }, (eventType, filename) => {
    if (!elmCompilationInProgress) {
        elmCompilationInProgress = true;
        printMsg(`\nDetected a ${ eventType } event on ${ filename }. Compiling...`);
        try {
            execSync("npm run elm-make");
            printSuccessMsg("\nElm compilation was complete. Reloading clients...");
            for(var i = 0; i < browserClients.length; i++) {
                browserClients[i].emit("reload-browser");
            }
        } catch(error) {
            printWarningMsg(`\n${ error }`);
        }
        setTimeout(() => { elmCompilationInProgress = false }, 1000)
    }
});


/* Watch for SCSS compile on change and re-compile & refresh styles on every client */
fs.watch(scssFolderPath, { recursive : true }, (eventType, filename) => {
    if (!scssCompilationInProgress) {
        scssCompilationInProgress = true;
        printMsg(`\nDetected a ${ eventType } event on ${ filename }. Compiling...`);
        try {
            printMsg(
                execSync("npm run compile-sass").toString()
            );
        } catch(error) {
            // Ignoring the error for now ?
        }
        printMsg("Reloading styles...");
        for(var i = 0; i < browserClients.length; i++) {
            browserClients[i].emit("reload-css");
        }
        setTimeout(() => { scssCompilationInProgress = false }, 1000)
    }
});


let port = 3765;
http.listen(port, () => {
    console.log("Listening on " + port);
});
