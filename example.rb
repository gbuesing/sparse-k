#! /usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require_relative './sparse-k'
require_relative './bag'

runs = 10

# Data from Qazvinian and radev 2011 http://www-personal.umich.edu/~vahed/data.html
datafiles = Dir['data/*.txt'] #.sample(5)
docs = []
doc_fileids = []

bag = Bag.new

datafiles.each_with_index do |filename, i|
  puts filename
  File.open(filename).each do |line|
    doc = line.chomp.to_s
    bag << doc
    docs << doc
    doc_fileids << i
  end
end

k = datafiles.length

puts "\nClassifying #{docs.length} docs with #{bag.total_features} total features into #{k} clusters:\n"

# start = Time.now
# kmeans = SparseK.run(k, bag.sparse_hashes, bag.total_features, runs: runs)
# elapsed = Time.now - start

# kmeans.clusters.each_with_index do |cluster, i|
#   puts "\nc#{i} - #{cluster.length} docs\n"
#   cluster.slice(0,20).each do |pointid|
#     puts "#{doc_fileids[pointid]}) #{docs[pointid]}"
#   end
# end

# puts "\nBest of #{runs} runs (total time #{elapsed.round(2)}s):"
# puts "#{k} clusters in #{kmeans.iterations} iterations, #{kmeans.runtime.round(2)}s, SSE #{kmeans.error.round(2)}"


require 'kmeans-clusterer'

start = Time.now
kmeans = KMeansClusterer.run(k, bag.to_a, runs: runs, log: true)
elapsed = Time.now - start

kmeans.clusters.each do |cluster|
  puts "\nc#{cluster.id} - #{cluster.points.length} docs\n"
  cluster.points.sample(10).each do |point|
    puts "#{'%02d' % doc_fileids[point.id]}) #{docs[point.id]}"
  end
end

puts "\nBest of #{runs} runs (total time #{elapsed.round(2)}s):"
puts "#{k} clusters in #{kmeans.iterations} iterations, #{kmeans.runtime.round(2)}s, SSE #{kmeans.error.round(2)}"
