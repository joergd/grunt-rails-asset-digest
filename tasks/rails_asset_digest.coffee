#
# * grunt-rails-asset-digest
# * https://github.com/davemo/grunt-rails-asset-digest
# *
# * Copyright (c) 2013 David Mosher
# * Licensed under the MIT license.
#

fs     = require "fs"
path   = require "path"
crypto = require "crypto"

"use strict"

module.exports = (grunt) ->

  _ = grunt.util._

  normalizeAssetPath = (path) ->
    unless _.str.endsWith(path, "/")
      path += "/"
    path

  grunt.registerMultiTask "rails_asset_digest", "Generates asset fingerprints and appends to a rails manifest", ->

    assetPath      = @options(assetPath: "public/assets/").assetPath
    algorithm      = @options(algorithm: "md5").algorithm

    assetPathRegex = ///^#{normalizeAssetPath(assetPath)}///

    filesToHashed = {}

    stripAssetPath = (path) ->
      path.replace assetPathRegex, ''

    stripPath = (path) ->
      path.split("/").reverse()[0]

    extend = (object, properties) ->
      for key, val of properties
        object[key] = val
      object

    merge = (options, overrides) ->
      extend (extend {}, options), overrides

    writeFingerprintedFiles = (files) ->
      _(files).each (f) ->

        src = f.src[0]
        dest = f.dest

        unless grunt.file.exists(src)
          grunt.log.warn "Source file \"" + src + "\" not found."
          return false


        extension     = path.extname dest

        if extension is ".map"
          extension = "#{path.extname(path.basename(dest, extension))}#{extension}"

        algorithmHash = crypto.createHash(algorithm)
        content  = grunt.file.read(src)
        digest = algorithmHash.update(content).digest("hex")

        filename = "#{path.dirname(dest)}/#{path.basename(dest, extension)}-#{digest}#{extension}"

        grunt.file.write filename, content
        grunt.log.writeln "File #{filename} created."

        filesToHashed[stripAssetPath dest] = {
          "logical_path": stripAssetPath(dest),
          "fingerprintedFilename": stripAssetPath(filename),
          "digest": digest,
          "mtime": fs.statSync(filename).mtime,
          'size': fs.statSync(filename).size,
          'extension': extension
        }


    digestSourceMaps = ->
      for __, file of filesToHashed
        if file["extension"] is ".js.map"
          sourcemapFilename = file["logical_path"]
          sourcemapFingerprintedFilename = file["fingerprintedFilename"]
          grunt.log.writeln "Found a sourcemap file: #{sourcemapFilename}"
          if sourceFile = filesToHashed[sourcemapFilename.replace(".js.map", ".js")]
            fingerPrintedSourceFilePath = normalizeAssetPath(assetPath) + sourceFile["fingerprintedFilename"]
            if grunt.file.exists(fingerPrintedSourceFilePath)
              content  = grunt.file.read(fingerPrintedSourceFilePath)
              # could be either specified as just a filename or a filename with a path
              if content.indexOf "//# sourceMappingURL=#{sourcemapFilename}"
                found = "//# sourceMappingURL=#{sourcemapFilename}"
                replaced = "//# sourceMappingURL=#{sourcemapFingerprintedFilename}"
                content = content.replace(found, replaced)
              if content.indexOf "//# sourceMappingURL=#{stripPath(sourcemapFilename)}"
                found = "//# sourceMappingURL=#{stripPath(sourcemapFilename)}"
                replaced = "//# sourceMappingURL=#{stripPath(sourcemapFingerprintedFilename)}"
                content = content.replace(found, replaced)

              grunt.log.writeln "Reference #{found} replaced with #{replaced} for file with sourcemaps: #{fingerPrintedSourceFilePath}"
              grunt.file.write fingerPrintedSourceFilePath, content

            else
              grunt.log.writeln "Corresponding source does not exist: #{fingerPrintedSourceFilePath}"
          else
            grunt.log.writeln "Corresponding source file not found: #{sourcemapFilename.replace('.js.map', '.js')}"

    changeManifestYml = ->
      manifestName   = "manifest.yml"
      manifestPath   = "#{normalizeAssetPath(assetPath)}#{manifestName}"

      if !grunt.file.exists manifestPath
        grunt.log.warn "#{manifestPath} did not exist"
        return false

      manifestDataLines = grunt.file.read(manifestPath).split "\n"
      replaceCount      = 0
      appendCount       = 0
      filesMatched      = {} # to prevent duplicate files

      manifestDataLines = _(manifestDataLines).map (line) ->
        match = line.match /^(\S+?):/
        file  = match?[1]
        if match and filesToHashed[file]
          if filesMatched[file]
            # Already seen this file in the manifest
            return null
          else
            line = "#{file}: #{filesToHashed[file]['fingerprintedFilename']}"
            filesMatched[file] = true
            replaceCount++
        return line

      _(_.reject(filesToHashed, (hashed, file) -> filesMatched[file]?)).each (hashed, file) ->
        manifestDataLines.push "#{hashed['logical_path']}: #{hashed['fingerprintedFilename']}"

      manifestData = _(manifestDataLines).compact().join("\n")

      fs.writeFileSync manifestPath, manifestData
      grunt.log.writeln "Replaced #{replaceCount} lines and appended #{_(filesToHashed).size()} lines to #{manifestPath}"


    changeManifestJson = ->
      manifestGlob   = "manifest-*.json"

      manifestPaths = grunt.file.expand("#{normalizeAssetPath(assetPath)}#{manifestGlob}")

      if manifestPaths.length is 0
        grunt.log.warn "#{normalizeAssetPath(assetPath)}#{manifestGlob} did not exist"
        return false

      manifestPath = manifestPaths[0]

      manifestData = grunt.file.readJSON(manifestPath)
      replaceCount      = 0
      appendCount       = 0
      filesMatched      = {} # to prevent duplicate files

      unless manifestData["assets"]?
        manifestData["assets"] = {}
      unless manifestData["files"]?
        manifestData["files"] = {}

      for src, dest of filesToHashed
        if manifestData["assets"][src] is null
          appendCount += 1
        else
          replaceCount += 1

        manifestData["assets"][src] = dest['fingerprintedFilename']
        manifestData["files"][dest['fingerprintedFilename']] = {
          "digest": dest['digest'],
          "logical_path": dest['logical_path'],
          "mtime": dest['mtime'],
          "size": dest['size']
        }

      fs.writeFileSync manifestPath, JSON.stringify(manifestData)

      grunt.log.writeln "Replaced #{replaceCount} lines and appended #{appendCount} lines to #{manifestPath}"

    writeFingerprintedFiles @files
    digestSourceMaps()
    changeManifestYml()
    changeManifestJson()

