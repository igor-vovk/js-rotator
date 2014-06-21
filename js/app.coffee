requirejs.config
  shim:
    underscore:
      exports: "_"
    rotator:
      deps: ["jquery", "underscore"]
  baseUrl: "js/lib"
  paths:
    app: "../app"
    jquery: "//ajax.googleapis.com/ajax/libs/jquery/2.0.0/jquery.min"
    underscore: "//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.6.0/underscore.js"
    raphael: "//cdnjs.cloudflare.com/ajax/libs/raphael/2.1.2/raphael-min.js"

requirejs ["app/main"]