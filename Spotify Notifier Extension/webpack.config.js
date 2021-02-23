module.exports = {
  entry: {
    script: './script.js'
  },
  output: {
    filename: '[name].js'
  },
  resolve: {
    fallback: {
      "fs": false
    }
  },
  mode: 'production'
};
