# Medley

Welcome to a simple combo handler written with 
[Sinatra](http://github.com/sinatra/sinatra/) for use with 
[Rack](https://github.com/rack/rack). 
It works just the combo service from Yahoo, and is based on the 
[Node.js version by rgrove](http://github.com/rgrove/combohandler). 

## Installation
Clone it where you want it! Then, install any files you'd like combined under
`public`, like [YUI 3](https://github.com/yui/yui3) and 
[2in3](https://github.com/yui/2in3), or whatever you want!

## Usage
`cd path/to/where/you/cloned` and then `bundle install` and then 
`ruby medley.rb` and then you are up and running. 

Medley uses [Rack::Cache](http://rtomayko.github.com/rack-cache/), with fairly 
aggressive settings so things go pretty fast (hopefully you are into that kind
of thing). Check them out in `config.ru`.

### Using as a YUI 3 source
Assuming you installed YUI 3.3.0 and YUI 2in3 version 2.8.1 in `public/yui`...

`YUI(
      comboBase: 'http://my-medley.address/combo?',
      root     : 'yui/3.3.0/build/',
      combine: true,
      groups: {
        yui2: {
          combine: true,
          base: 'http://my-medley.address/yui/2in3/2.8.1',
          comboBase: 'http://my-medley.address/combo?',
          root: 'yui/2in3/2.8.1/build/',
          patterns:{
            'yui2-': {
              configFn: function(me) {
                if(/-skin|reset|fonts|grids|base/.test(me.name)) {
                    me.type = 'css';
                    me.path = me.path.replace(/\.js/, '.css');
                    me.path = me.path.replace(/\/yui2-skin/, '/assets/skins/sam/yui2-skin');
                }
              }
            }
          }
        }
      }
    ).use('node', 'yui2-calendar', function(Y){
      Y.log('_WHY?');
})`

