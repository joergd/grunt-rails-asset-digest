grunt  = require("grunt")
spawn  = require("child_process").spawn
read   = grunt.file.read
write  = grunt.file.write
mkdir  = grunt.file.mkdir
clear  = grunt.file.delete
expand = grunt.file.expand

runGruntTask = (task, config, done) ->
  spawn("grunt",
    [
      task,
      "--config", JSON.stringify(config),
      "--tasks", "../tasks"
      "--gruntfile", "spec/Gruntfile.coffee"
    ],
    {stdio: 'inherit'}
  ).on("exit", -> done())

beforeEach -> mkdir @workspacePath = "spec/tmp/public/assets"
# afterEach  -> clear "spec/tmp/"

describe "rails_asset_digest", ->

  Given ->
    @railsManifestEntries =
      """
      some/assetpipeline/generated-tree.js: some/assetpipeline/generated-tree-536a9e5ddkfjc9v9e9r939494949491.js
      another/tree-we-didnt-touch.js: another/entry-we-didnt-touch-536a9e5d711e0593e43360ad330ccc31.js
      """
    @taskManifestEntries =
      """
      rootfile.js: rootfile-54267464ea71790d3ec68e243f64b98e.js
      rootfile.js.map: rootfile-742adbb9b78615a3c204b83965bb62f7.js.map
      othersubdirectory/generated-tree.js: othersubdirectory/generated-tree-e4ce151e4824a9cbadf1096551b070d8.js
      subdirectory/with/alibrary.js: subdirectory/with/alibrary-313b3b4b01cec6e4e82bdeeb258503c5.js
      style.css: style-7527fba956549aa7f85756bdce7183cf.css
      """
    @staleManifestEntries =
      """
      rootfile.js: rootfile-OLDSHA.js
      rootfile.js.map: rootfile-OLDSHA.js.map
      othersubdirectory/generated-tree.js: othersubdirectory/generated-tree-OLDSHA.js
      subdirectory/with/alibrary.js: subdirectory/with/alibrary-OLDSHA.js
      style.css: style-OLDSHA.css
      """
    @railsJsonManifestEntries =
      {
        "assets": {
          "some/assetpipeline/generated-tree.js": "some/assetpipeline/generated-tree-536a9e5ddkfjc9v9e9r939494949491.js",
          "another/tree-we-didnt-touch.js": "another/entry-we-didnt-touch-536a9e5d711e0593e43360ad330ccc31.js"
        },
        "files": {
          "some/assetpipeline/generated-tree-536a9e5ddkfjc9v9e9r939494949491.js": {
            "digest": "536a9e5ddkfjc9v9e9r939494949491",
            "logical_path": "some/assetpipeline/generated-tree.js",
            "mtime": "2013-07-26T16:52:58+02:00",
            "size": 6801
          },
          "another/entry-we-didnt-touch-536a9e5d711e0593e43360ad330ccc31.js": {
            "digest": "536a9e5d711e0593e43360ad330ccc31",
            "logical_path": "another/entry-we-didnt-touch.js",
            "mtime": "2013-08-14T11:45:17+02:00",
            "size": 35102
          }
        }
      }
    @taskJsonManifestEntries =
      {
        "assets": {
          "rootfile.js": "rootfile-54267464ea71790d3ec68e243f64b98e.js",
          "rootfile.js.map": "rootfile-742adbb9b78615a3c204b83965bb62f7.js.map",
          "othersubdirectory/generated-tree.js": "othersubdirectory/generated-tree-e4ce151e4824a9cbadf1096551b070d8.js",
          "subdirectory/with/alibrary.js": "subdirectory/with/alibrary-313b3b4b01cec6e4e82bdeeb258503c5.js",
          "style.css": "style-7527fba956549aa7f85756bdce7183cf.css"
        },
        "files": {
          "rootfile-54267464ea71790d3ec68e243f64b98e.js": {
            "digest": "54267464ea71790d3ec68e243f64b98e",
            "logical_path": "rootfile.js",
            "mtime": "2011-10-17T20:40:27+02:00",
            "size": 426
          },
          "rootfile-742adbb9b78615a3c204b83965bb62f7.js.map": {
            "digest": "742adbb9b78615a3c204b83965bb62f7",
            "logical_path": "rootfile.js.map",
            "mtime": "2011-10-17T22:40:27+02:00",
            "size": 1321
          },
          "othersubdirectory/generated-tree-e4ce151e4824a9cbadf1096551b070d8.js": {
            "digest": "e4ce151e4824a9cbadf1096551b070d8",
            "logical_path": "othersubdirectory/generated-tree.js",
            "mtime": "2012-10-17T22:40:27+02:00",
            "size": 506
          },
          "subdirectory/with/alibrary-313b3b4b01cec6e4e82bdeeb258503c5.js": {
            "digest": "313b3b4b01cec6e4e82bdeeb258503c5",
            "logical_path": "subdirectory/with/alibrary.js",
            "mtime": "2012-11-10T07:12:27+02:00",
            "size": 2506
          },
          "style-7527fba956549aa7f85756bdce7183cf.css": {
            "digest": "7527fba956549aa7f85756bdce7183cf",
            "logical_path": "style.css",
            "mtime": "2012-12-10T07:12:14+02:00",
            "size": 1001
          }
        }
      }
    @staleJsonManifestEntries =
      {
        "assets": {
          "rootfile.js": "rootfile-OLDSHA.js",
          "rootfile.js.map": "rootfile-OLDSHA.js.map",
          "othersubdirectory/generated-tree.js": "othersubdirectory/generated-tree-OLDSHA.js",
          "subdirectory/with/alibrary.js": "subdirectory/with/alibrary-OLDSHA.js",
          "style.css": "style-OLDSHA.css"
        },
        "files": {
          "rootfile-OLDSHA.js": {
            "digest": "OLDSHA",
            "logical_path": "rootfile.js",
            "mtime": "2011-10-17T20:40:27+02:00",
            "size": 426
          },
          "rootfile-OLDSHA.js.map": {
            "digest": "OLDSHA",
            "logical_path": "rootfile.js.map",
            "mtime": "2011-10-17T22:40:27+02:00",
            "size": 1321
          },
          "othersubdirectory/generated-tree-OLDSHA.js": {
            "digest": "OLDSHA",
            "logical_path": "othersubdirectory/generated-tree.js",
            "mtime": "2012-10-17T22:40:27+02:00",
            "size": 506
          },
          "subdirectory/with/alibrary-OLDSHA.js": {
            "digest": "OLDSHA",
            "logical_path": "subdirectory/with/alibrary.js",
            "mtime": "2012-11-10T07:12:27+02:00",
            "size": 2506
          },
          "style-OLDSHA.css": {
            "digest": "OLDSHA",
            "logical_path": "style.css",
            "mtime": "2012-12-10T07:12:14+02:00",
            "size": 1001
          }
        }
      }
    @config =
      rails_asset_digest:
        sut:
          options:
            assetPath: "tmp/public/assets/"
          files:
            "tmp/public/assets/rootfile.js"                         : "common_rails_project/public/assets/javascripts/rootfile.js"
            "tmp/public/assets/rootfile.js.map"                : "common_rails_project/public/assets/javascripts/rootfile.js.map"
            "tmp/public/assets/othersubdirectory/generated-tree.js" : "common_rails_project/public/assets/javascripts/othersubdirectory/generated-tree.js"
            "tmp/public/assets/subdirectory/with/alibrary.js"       : "common_rails_project/public/assets/javascripts/subdirectory/with/alibrary.js"
            "tmp/public/assets/style.css"                           : "common_rails_project/public/assets/stylesheets/style.css"

    @extend = (object, properties) ->
      for key, val of properties
        object[key] = val
      object

    @merge = (options, overrides) ->
      @extend (@extend {}, options), overrides

  context "with a manifest.yml file", ->
    context "a manifest with rails asset pipeline generated entries", ->
      Given ->
        @existingManifest =
          """
          ---
          #{@railsManifestEntries}
          """

        @expectedManifest =
          """
          ---
          #{@railsManifestEntries}
          #{@taskManifestEntries}
          """

      describe "appends new manifest entries, does not touch existing rails entries", ->
        Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
        Given (done) -> runGruntTask("rails_asset_digest", @config, done)
        When  -> @writtenManifest = read("#{@workspacePath}/manifest.yml")
        Then  -> @writtenManifest == @expectedManifest

    context "a manifest with stale entries from a previous task", ->
      Given ->
        @existingManifest =
          """
          ---
          #{@railsManifestEntries}
          #{@staleManifestEntries}
          """

        @expectedManifest =
          """
          ---
          #{@railsManifestEntries}
          #{@taskManifestEntries}
          """

      describe "replaces stale entries", ->
        Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
        Given (done) -> runGruntTask("rails_asset_digest", @config, done)
        When  -> @writtenManifest = read("#{@workspacePath}/manifest.yml")
        Then  -> @writtenManifest == @expectedManifest

    context "an empty manifest", ->
      Given ->
        @existingManifest =
          """
          ---
          """

        @expectedManifest =
          """
          ---
          #{@taskManifestEntries}
          """

      describe "appends new entries", ->
        Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
        Given (done) -> runGruntTask("rails_asset_digest", @config, done)
        When  -> @writtenManifest = read("#{@workspacePath}/manifest.yml")
        Then  -> @writtenManifest == @expectedManifest

      describe "normalizes the asset path by adding a trailing slash", ->
        Given -> @config.rails_asset_digest.sut.options.assetPath = "tmp/public/assets"
        Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
        Given (done) -> runGruntTask("rails_asset_digest", @config, done)
        When  -> @writtenManifest = read("#{@workspacePath}/manifest.yml")
        Then  -> @writtenManifest == @expectedManifest

    describe "writes contents of fingerprinted files properly", ->
      Given -> @existingManifest = "---"
      Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
      Given (done) -> runGruntTask("rails_asset_digest", @config, done)
      Then  -> read("#{expand('spec/tmp/public/assets/rootfile-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/rootfile.js")
      And   -> read("#{expand('spec/tmp/public/assets/rootfile-*.js.map')[0]}") == read("spec/common_rails_project/public/assets/javascripts/rootfile.js.map")
      And   -> read("#{expand('spec/tmp/public/assets/style-*.css')[0]}") == read("spec/common_rails_project/public/assets/stylesheets/style.css")
      And   -> read("#{expand('spec/tmp/public/assets/othersubdirectory/generated-tree-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/othersubdirectory/generated-tree.js")
      And   -> read("#{expand('spec/tmp/public/assets/subdirectory/with/alibrary-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/subdirectory/with/alibrary.js")

  context "with a manifest.json file", ->
    context "a manifest with rails asset pipeline generated entries", ->
      Given ->
        @existingManifest = @railsJsonManifestEntries

      describe "appends new manifest entries, does not touch existing rails entries", ->
        Given -> write("#{@workspacePath}/manifest-408ec17ba911cc99d2e36ceb4d0f0528.json", JSON.stringify(@existingManifest))
        Given (done) -> runGruntTask("rails_asset_digest", @config, done)
        When  -> @writtenManifest = JSON.parse(read("#{@workspacePath}/manifest-408ec17ba911cc99d2e36ceb4d0f0528.json"))
        Then  -> @writtenManifest["assets"]["rootfile.js"] is @taskJsonManifestEntries["assets"]["rootfile.js"]
        And   -> @writtenManifest["assets"]["rootfile.js.map"] is @taskJsonManifestEntries["assets"]["rootfile.js.map"]
        And   -> @writtenManifest["assets"]["othersubdirectory/generated-tree.js"] is @taskJsonManifestEntries["assets"]["othersubdirectory/generated-tree.js"]
        And   -> @writtenManifest["assets"]["style.css"] is @taskJsonManifestEntries["assets"]["style.css"]
        And   -> @writtenManifest["files"][@taskJsonManifestEntries["assets"]["rootfile.js"]]["logical_path"] is "rootfile.js"

    context "a manifest with stale entries from a previous task", ->
      Given ->
        @existingManifest = @staleJsonManifestEntries

      describe "replaces stale entries", ->
        Given -> write("#{@workspacePath}/manifest-408ec17ba911cc99d2e36ceb4d0f0528.json", JSON.stringify(@existingManifest))
        Given (done) -> runGruntTask("rails_asset_digest", @config, done)
        When  -> @writtenManifest = JSON.parse(read("#{@workspacePath}/manifest-408ec17ba911cc99d2e36ceb4d0f0528.json"))
        Then  -> @writtenManifest["assets"]["rootfile.js"] is @taskJsonManifestEntries["assets"]["rootfile.js"]
        And   -> @writtenManifest["assets"]["rootfile.js.map"] is @taskJsonManifestEntries["assets"]["rootfile.js.map"]
        And   -> @writtenManifest["assets"]["othersubdirectory/generated-tree.js"] is @taskJsonManifestEntries["assets"]["othersubdirectory/generated-tree.js"]
        And   -> @writtenManifest["assets"]["style.css"] is @taskJsonManifestEntries["assets"]["style.css"]
        And   -> @writtenManifest["files"][@taskJsonManifestEntries["assets"]["rootfile.js"]]["logical_path"] is "rootfile.js"

    context "an empty manifest", ->
      Given ->
        @existingManifest = {}

      describe "appends new entries", ->
        Given -> write("#{@workspacePath}/manifest-408ec17ba911cc99d2e36ceb4d0f0528.json", JSON.stringify(@existingManifest))
        Given (done) -> runGruntTask("rails_asset_digest", @config, done)
        When  -> @writtenManifest = JSON.parse(read("#{@workspacePath}/manifest-408ec17ba911cc99d2e36ceb4d0f0528.json"))
        Then  -> @writtenManifest["assets"]["rootfile.js"] is @taskJsonManifestEntries["assets"]["rootfile.js"]

    describe "writes contents of fingerprinted files properly", ->
      Given -> @existingManifest = "---"
      Given -> write("#{@workspacePath}/manifest.yml", @existingManifest)
      Given (done) -> runGruntTask("rails_asset_digest", @config, done)
      Then  -> read("#{expand('spec/tmp/public/assets/rootfile-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/rootfile.js")
      And   -> read("#{expand('spec/tmp/public/assets/rootfile-*.js.map')[0]}") == read("spec/common_rails_project/public/assets/javascripts/rootfile.js.map")
      And   -> read("#{expand('spec/tmp/public/assets/style-*.css')[0]}") == read("spec/common_rails_project/public/assets/stylesheets/style.css")
      And   -> read("#{expand('spec/tmp/public/assets/othersubdirectory/generated-tree-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/othersubdirectory/generated-tree.js")
      And   -> read("#{expand('spec/tmp/public/assets/subdirectory/with/alibrary-*.js')[0]}") == read("spec/common_rails_project/public/assets/javascripts/subdirectory/with/alibrary.js")
