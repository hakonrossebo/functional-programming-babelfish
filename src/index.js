require('./main.css');
var Elm = require('./Main.elm');

var myJSTestApp = Elm.Main.embed(document.getElementById('root'), {
	currentTime: Date.now()
});
