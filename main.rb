#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'tempfile'

def truthy(val) !(val.nil? || val.empty? || val.to_s.downcase == 'false') end

logfile = Tempfile.new
logfile.write()
logfile.flush

# Export tag
tag = (ENV['INPUT_TAG'] || ENV['GITHUB_REF'] || '').sub(%r{^refs/[^/]+/}, '')
if tag.empty?
  $stderr.puts "Tag is omitted from arguments (missing GITHUB_REF)"
  exit 1
end
puts "::set-output name=tag::#{tag}"

# Find changelog
filenames = (ENV['INPUT_FILENAME'] || '').empty? ?
  %w(changelog.md changelog releases.md releases) : [ENV['INPUT_FILENAME']]

# Extract changelog portion
version = tag.sub(/^v/, '')
re = %r{^\#{1,2}\s+\[?v?#{Regexp.quote version}[^\r\n]*\r?\n(.+?)(^#|\Z)}mi
filename = Dir['*'].find {|f| filenames.include?(f.downcase) }
raise "Cannot find any valid changelog files from #{filenames.inspect}" if filename.nil?
extracted = File.read(filename)[re, 1]
raise "Could not find changelog portion from #{filename} (version: #{version})" if extracted.nil?
extracted.strip!
logfile.write(extracted)
logfile.close

# Run release command
title = (ENV['INPUT_TITLE'] || 'Release $tag').sub('$tag', tag)
puts "Title: #{title}\nContents:\n\n#{extracted}\n"

cmd = ['gh', 'release', 'create', tag, '-F', logfile.path]
cmd << '-d' if truthy(ENV['INPUT_DRAFT'])
cmd << '-p' if truthy(ENV['INPUT_PRERELEASE'])
cmd += ['-t', title.inspect]
puts "Command: #{cmd.join(' ')}"
out = `#{cmd.join(' ')}`.strip
result = $?
puts "::set-output name=release_url::#{out}" if result.to_i == 0
puts out
logfile.unlink
exit result.to_i
