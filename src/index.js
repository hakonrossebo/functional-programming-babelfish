require('./main.css');
var Elm = require('./Main.elm');

var babelFishApp = Elm.Main.embed(document.getElementById('root'), {
	currentTime: Date.now()
});

babelFishApp.ports.scrollIdIntoView.subscribe(function(domId) {
	 document.getElementById(domId).scrollIntoView();
});
