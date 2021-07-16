// We import the CSS which is extracted to its own file by esbuild.
import "../css/app.css"

// Bring phoenix_html to deal with method=PUT/DELETE in forms and buttons
import "phoenix_html"

// Uncomment below to bring Phoenix' client side socket
// import socket from "./socket"

// You can bring dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.min.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
