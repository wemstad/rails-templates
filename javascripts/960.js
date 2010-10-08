var gOverride = {
  urlBase: 'http://gridder.andreehansson.se/releases/latest/',
  gColor: '#f00',
  gColumns: 16,
  gOpacity: 0.15,
  gWidth: 10,
  pColor: '#C0C0C0',
  pHeight: 15,
  pOffset: 0,
  pOpacity: 0.55,
  center: true,
  gEnabled: true,
  pEnabled: true,
  setupEnabled: true,
  fixFlash: true,
  size: 960
};

Event.observe(window, 'load', function() {
	document.body.appendChild(
	document.createElement('script'))
	.src='http://gridder.andreehansson.se/releases/latest/960.gridder.js';
});
