#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

if ARGV.empty?
  $stderr.puts "Tag is omitted from arguments (missing GITHUB_REF)"
  exit 1
end

# Export tag
tag = ARGV[0].sub(%r{^refs/[^/]+/}, '')
puts "::set-output name=tag::#{tag}"

# Create package.json
package = {
  version: tag.sub(/^v/, ''),
  repository: {
    type: 'git',
    url: "git://github.com/#{ENV['GITHUB_REPOSITORY']}"
  }
}
File.open('package.json', 'w') {|f| f.write(JSON.generate(package)) }

# Run release command
cmd = ['npx', 'github-release-from-changelog']
cmd += ['--filename', ENV['FILENAME']] unless (ENV['FILENAME'] || '').empty?
system(cmd.join(' '))
IO.popen('git checkout package.json || rm package.json', err: :out)
