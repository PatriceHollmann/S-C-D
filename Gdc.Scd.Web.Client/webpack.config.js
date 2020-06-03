/// <binding />
const webpack = require('webpack');
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const OpenBrowserPlugin = require('open-browser-webpack-plugin');
const ExtReactWebpackPlugin = require('@extjs/reactor-webpack-plugin');
const portfinder = require('portfinder');
const WriteFilePlugin = require('write-file-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

const sourcePath = path.resolve(__dirname, 'src');

console.log("SOURCE PATH: " + sourcePath);

module.exports = function (env) {
    portfinder.basePort = (env && env.port) || 8080; // the default port to use

    return portfinder.getPortPromise().then(port => {
        const nodeEnv = env && env.prod ? 'production' : 'development';
        //const isProd = nodeEnv === 'production';
        const isProd = false;
        //console.log("[IS PRODUCTION]: " + isProd);

        const plugins = [
            new ExtReactWebpackPlugin({
                theme: 'custom-ext-react-theme',
                overrides: ['ext-react/overrides'],
                production: isProd
            }),
            new webpack.EnvironmentPlugin({
                NODE_ENV: nodeEnv
            }),
            new webpack.NamedModulesPlugin(),
            new CopyWebpackPlugin([
                { from: 'Images', to: 'images' }
            ]),
            new CopyWebpackPlugin([
                { from: 'app.css' }
            ])
        ];


        if (isProd) {
            plugins.push(
                new webpack.LoaderOptionsPlugin({
                    minimize: true,
                    debug: false
                }),
                new webpack.optimize.UglifyJsPlugin({
                    compress: {
                        warnings: false,
                        screw_ie8: true
                    }
                })
            );
        } else {
            plugins.push(new WriteFilePlugin({ test: /^(?!.+(?:hot-update.(js|json))).+$/ }));

            plugins.push(
                new webpack.HotModuleReplacementPlugin()
            );
        }

        plugins.push(new HtmlWebpackPlugin({
            template: 'index.html',
            hash: true
        }));

        return {
            devtool: isProd ? 'source-map' : 'cheap-module-source-map',
            context: sourcePath,

            entry: [
                './index.tsx'
            ],

            output: {
                path: path.join(__dirname, '../Gdc.Scd.Web.Server/Content'),
                publicPath: '/scd/Content',
                filename: 'bundle.js?v=' + new Date().getTime()
            },

            module: {
                rules: [
                    {
                        test: /\.(ts|tsx)$/,
                        exclude: /node_modules/,
                        use: [
                            {
                                loader: 'babel-loader',
                                options: {
                                    "plugins": [
                                        "@extjs/reactor-babel-plugin"
                                    ]
                                }
                            },
                            {
                                loader: 'awesome-typescript-loader'
                            }
                        ]
                    }
                ]
            },

            resolve: {
                extensions: ['.ts', '.tsx', '.js'],

                // The following is only needed when running this boilerplate within the extjs-reactor repo.  You can remove this from your own projects.
                alias: {
                    "react-dom": path.resolve('./node_modules/react-dom'),
                    "react": path.resolve('./node_modules/react')
                }
            },

            plugins,

            stats: {
                colors: {
                    green: '\u001b[32m'
                }
            }

        };
    });
};