require('file?name=/assets/highlight/highlight.pack.js!../assets/highlight/highlight.pack.js');
require('./main.css');
require('file?name=available-languages.json!../available-languages.json');
require('file?name=concepts.json!../concepts.json');
require('file?name=/images/elm.png!../images/elm.png');
require('file?name=/assets/highlight/solarized-dark.css!../assets/highlight/solarized-dark.css');
require('file?name=/assets/analytics.js!../assets/analytics.js');

var Elm = require('./Main.elm');

var babelFishApp = Elm.Main.embed(document.getElementById('root'), {
	currentTime: Date.now()
});
// var babelFishApp = Elm.Main.fullscreen({ currentTime: Date.now() });

babelFishApp.ports.scrollIdIntoView.subscribe(function(domId) {
	 document.getElementById(domId).scrollIntoView();
});
