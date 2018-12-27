/* FileSystem watch specific code. */
var socket = io();

socket.on("reload-browser", () => {
    window.location.reload();
});

socket.on("reload-css", () => {
    let linkElements = document.getElementsByTagName("link");
    for(var i = 0; i < linkElements.length; i++) {
        var href = linkElements[i].getAttribute("href");
        if (href.startsWith("/")) {
            linkElements[i].setAttribute("href", href);
        }
    }
});
