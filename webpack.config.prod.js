const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const path = require( 'path' );

const paths = {
  entry: path.resolve('./src/index'),
  dist: path.resolve('./dist'),
  template: path.resolve('./src/index_prod.html'),
  favicon: path.resolve('./src/favicon.ico'),
  elmMake: path.resolve(__dirname, './node_modules/.bin/elm-make')
}

module.exports = {

  devtool: 'eval',

   entry: [
    paths.entry
  ],
  output: {

    pathinfo: true,

    path: paths.dist,

    filename: 'app-[hash]',

    publicPath: './'
  },
  resolve: {
    extensions: ['', '.js', '.elm']
  },
  module: {
    noParse: /\.elm$/,
    loaders: [
        {
        test: /\.elm$/,
        exclude: [ /elm-stuff/, /node_modules/ ],

        // Use the local installation of elm-make
        loader: 'elm-webpack',
        query: {
          pathToMake: paths.elmMake
        }
      },
      {
        test: /\.css$/,
        exclude: [ /elm-stuff/, /node_modules/ ],
        loader: "style-loader!css-loader"
      }
    ]
  },
  plugins: [
    new webpack.DefinePlugin({
      API_URL: JSON.stringify('available-languages.json')
    }),
    new HtmlWebpackPlugin({
      inject: true,
      title: "Functional programming Babelfish",
      template: paths.template,
      favicon: paths.favicon,
      minify: {
        removeComments: true,
        collapseWhitespace: true,
        removeRedundantAttributes: true,
        useShortDoctype: true,
        removeEmptyAttributes: true,
        removeStyleLinkTypeAttributes: true,
        keepClosingSlash: true,
        minifyJS: true,
        minifyCSS: true,
        minifyURLs: true
      }
    }),
    new CleanWebpackPlugin(['dist'], {
      verbose: true
    }),
     // Minify the compiled JavaScript.
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false
      },
      output: {
        comments: false
      }
    }),
  ]
};