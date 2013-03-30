/*
 * grunt-init
 * https://gruntjs.com/
 *
 * Copyright (c) 2012 "Cowboy" Ben Alman, contributors
 * Licensed under the MIT license.
 */

'use strict';

// Basic template description.
exports.description = 'Create a Node.js module, including Nodeunit unit tests.';

// Template-specific notes to be displayed before question prompts.
exports.notes = '_Project name_ shouldn\'t contain "node" or "js" and should ' +
  'be a unique ID not already in use at search.npmjs.org.';

// Any existing file or directory matching this wildcard will cause a warning.
exports.warnOn = '*';

// The actual init template.
exports.template = function(grunt, init, done) {

  init.process({type: 'node'}, [
    // Prompt for these values.
    init.prompt('name'),
    init.prompt('description'),
    init.prompt('version'),
    init.prompt('repository'),
    init.prompt('homepage'),
    init.prompt('bugs'),
    init.prompt('licenses'),
    init.prompt('author_name'),
    init.prompt('author_email'),
    init.prompt('author_url'),
    init.prompt('node_version')
  ], function(err, props) {
    props.keywords = [];
    props.main = 'lib/index.js';

    props.dependencies = {
    };

    props.devDependencies = {
      "grunt": '~' + grunt.version,
      "grunt-contrib-watch": "~0.2.0rc7",
      "grunt-contrib-coffee": "~0.4.0rc5",
      "grunt-simple-mocha": "~0.3.2",
      "mocha": "~1.7.3",
      "chai": "~1.4.0"
    };

    props.npm_test = 'grunt test';

    // Files to copy (and process).
    var files = init.filesToCopy(props);
    console.error(files);

    // Add properly-named license files.
    init.addLicenseFiles(files, props.licenses);

    // Actually copy (and process) files.
    init.copyAndProcess(files, props);

    // Generate package.json file.
    init.writePackageJSON('package.json', props);

    // All done!
    done();
  });

};
