require('./main.css');
var Elm = require('./Main.elm');

var babelFishApp = Elm.Main.fullscreen({ currentTime: Date.now() });

babelFishApp.ports.scrollIdIntoView.subscribe(function(domId) {
	 document.getElementById(domId).scrollIntoView();
});
