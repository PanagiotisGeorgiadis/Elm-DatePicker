const fs                 = require("fs");
const path               = require("path");
const { execSync } = require("child_process");


let inProgress = false;
const elmSourcePath = path.join(__dirname, "src");
const elmTestPath   = path.join(__dirname, "tests");


const printWatchMsg = (eventType, filename) => {
    console.log(`\n\nDetected a ${ eventType } event on ${ filename }. Running Tests...`);
}


/* Watch for Elm Test changes and re-test */
fs.watch(elmTestPath, { recursive : true }, (eventType, filename) => {
    if (!inProgress) {
        inProgress = true;
        printWatchMsg(eventType, filename);
        try {
            console.log(execSync("npm test").toString());
        } catch(error) {
            console.log(error.stdout.toString());
        }
        setTimeout(() => { inProgress = false }, 1000)
    }
});

/* Watch for Elm changes and re-compile & refresh the browser for every client */
fs.watch(elmSourcePath, { recursive : true }, (eventType, filename) => {
    if (!inProgress) {
        inProgress = true;
        printWatchMsg(eventType, filename);
        try {
            console.log(execSync("npm test").toString());
        } catch(error) {
            console.log(error.stdout.toString());
        }
        setTimeout(() => { inProgress = false }, 1000)
    }
});

console.log("Tests Watch initialised and waiting for changes...\n");
