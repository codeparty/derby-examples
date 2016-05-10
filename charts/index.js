var app = module.exports = require('derby').createApp('charts', __filename);
app.use(require('derby-debug'));
app.serverUse(module, 'derby-stylus');
app.use(require('d-bootstrap'));
app.loadViews(__dirname);
app.loadStyles(__dirname);
app.component(require('d-connection-alert'));
app.component(require('d-barchart'));
app.component(require('d-barchart-vanilla'));
app.component(require('d-d3-barchart'));

app.get('/', function(page, model, params, next) {
  var id = model.id();
  var $widget = model.at('widgets.' + id);
  $widget.subscribe(function(err) {
    if (err) return next(err);
    var widget = $widget.get();
    if (!widget) model.add('widgets', {id: id, data: []});
    $widget.setNull('data', [{value: 1}, {value: 10}, {value: 20 }]);
    $widget.ref('_page.widget');
    page.render();
  });
});

// adding a prototype method to page of app
app.proto.remove = function(d,i,el) {
  this.model.remove("_page.widget.data", i, 1);
}
app.proto.add = function() {
  this.model.push("_page.widget.data", {value: Math.random() * 100 });
}
