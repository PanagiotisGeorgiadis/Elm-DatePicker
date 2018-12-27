const sass = require("node-sass");
const path = require("path");
const fs   = require("fs");

const sourceDir = path.join(__dirname, "public", "scss");
const destDir   = path.join(__dirname, "public", "styles");

const scss_entrypoint = path.join(sourceDir, "main.scss");
const scss_dest       = path.join(destDir, "styles.css");

sass.render(
  { file: scss_entrypoint
  , outFile: scss_dest
  }, (error, result) => {
      if (error) {
          console.log("Node sass error\n", error);
          return;
      }

      const compilationResultHandler = (err) => {
          if (err) {
              console.log("FileSystem error\n", err);
          } else {
              console.log("SCSS compilation was successful");
          }
      }

      fs.writeFile(scss_dest, result.css, compilationResultHandler);
  }
);
