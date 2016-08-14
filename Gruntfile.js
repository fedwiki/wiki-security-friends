module.exports = function (grunt) {
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-git-authors');

  grunt.initConfig({


    authors: {
      prior: [
        "Austin King <shout@ozten.com>",
        "Ward Cunningham <ward@c2.com>",
        "Nick Niemeir <nick.niemeir@gmail.com>",
        "Paul Rodwell <paul.rodwell@btinternet.com>"
      ]
    },

    browserify: {
      plugin: {
        src: ['client/security.coffee'],
        dest: 'client/security.js',
        options: {
          transform: ['coffeeify'],
          browserifyOptions: {
            extentions: ".coffee"
          }
        }
      }
    },

    watch: {
      all: {
        files: ['client/*.coffee'],
        tasks: ['build']
      }
    }
  });

  grunt.registerTask('build', ['browserify']);
  grunt.registerTask('default', ['build']);

};