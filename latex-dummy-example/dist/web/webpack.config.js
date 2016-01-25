module.exports = {
    entry: './src/js/app.js',
    output: {
        path: './assets/js/',
        filename: 'bundle.js',
    },
    resolve: {
        modulesDirectories: ['node_modules', 'bower_components'],
        extensions: ['', '.webpack.js', '.web.js', '.js']
    },
    module: {
        loaders: [
        ]
    }
};