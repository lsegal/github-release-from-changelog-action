#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

# Export tag
tag = ARGV[0].sub(%r{^refs/[^/]+/}, '')
puts "::set-output name=tag::#{tag}"

# Create package.json
package = {
  version: tag.sub(/^v/, ''),
  repository: {
    type: 'git'
    url: "git://github.com/#{ENV['GITHUB_REPOSITORY']}"
  }
}
File.open('package.json', 'w') {|f| f.write(JSON.generate(package)) }

# Run release command
cmd = ['npx', 'github-release-from-changelog']
cmd += ['--filename', ENV['FILENAME']] unless (ENV['FILENAME'] || '').empty?
exec(cmd.join(' '))
