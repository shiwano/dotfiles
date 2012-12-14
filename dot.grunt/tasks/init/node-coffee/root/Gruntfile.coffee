module.exports = (grunt) ->
  grunt.initConfig
    pkg: '<json:package.json>'

    coffee:
      lib:
        files:
          'lib/*.js': 'src/**/*.coffee'

    simplemocha:
      lib:
        src: 'test/**/*_test.coffee'
        options:
          globals: ['expect']
          timeout: 3000
          ui: 'bdd'
          reporter: 'nyan'

    watch:
      files: [
        'Gruntfile.coffee'
        'src/**/*.coffee'
        'test/**/*.coffee'
      ]
      tasks: 'default'

  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'test', 'simplemocha'
  grunt.registerTask 'default', ['coffee', 'simplemocha']
