module.exports = {
    outputDir: "static/app",
    filenameHashing: false,
    chainWebpack: config => {
        config.plugins.delete('html')
        config.plugins.delete('preload')
        config.plugins.delete('prefetch')
    }
}