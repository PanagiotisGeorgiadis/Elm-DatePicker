const sass = require("node-sass");
const path = require("path");
const fs   = require("fs");
const { printSuccessMsg, printErrorMsg, printWarningMsg } = require("./console-helpers.js");

const sourceDir = path.join(process.cwd(), "public", "scss");
const destDir   = path.join(process.cwd(), "public", "styles");

const scss_entrypoint = path.join(sourceDir, "main.scss");
const scss_dest       = path.join(destDir, "styles.css");

sass.render(
  { file: scss_entrypoint
  , outFile: scss_dest
  }, (error, result) => {
      if (error) {
          printErrorMsg(`Node SASS error:\n${ error }`);
          return;
      }

      const compilationResultHandler = (err) => {
          if (err) {
              printErrorMsg(`FileSystem error:\n${ err }`);
          } else {
              printSuccessMsg("SCSS compilation was successful");
          }
      }

      fs.writeFile(scss_dest, result.css, compilationResultHandler);
  }
);
