const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.append("Provide", new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: ['popper.js', 'default'],  // Not a typo, we're still using popper.js here
    'd3': 'd3'   // had to use 'd3' instead of 'd3/dist/d3.js' that I saw in an example.
}))

//const aliasConfig = {
//    'd3': 'd3/dist/d3.js'
//};

//environment.config.set('resolve.alias', aliasConfig);

module.exports = environment

