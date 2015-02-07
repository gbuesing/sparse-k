class SparseK
  def self.run k, points, total_features, opts = {}
    runscount = opts[:runs] || 10
    runs = runscount.times.map do |i|
      km = new(k, points, total_features).run
      puts "[#{i + 1}] #{km.iterations} iter\t#{km.runtime.round(2)}s\t#{km.error.round(2)} err"
      km
    end
    runs.sort_by {|run| run.error }.first
  end

  attr_reader :k, :points, :total_features, :centroids, :clusters, :points_clusters, :error, :iterations, :runtime

  def initialize k, points, total_features
    @k = k
    @points = points
    @total_features = total_features
    @centroids = @points.sample k
    @clusters = Array.new(k) { [] }
    @points_clusters = Array.new(points.length)
  end

  def run
    start_time = Time.now
    @iterations = 0

    cluster_points = Array.new(@k) { [] }

    loop do
      @iterations +=1

      @points.each_with_index do |point, pi|
        mindist = Float::INFINITY
        minclust = nil

        @centroids.each_with_index do |centroid, ci|
          dist = distance(centroid, point)
          if dist < mindist
            mindist = dist
            minclust = ci
          end
        end

        @clusters[minclust] << pi
        @points_clusters[pi] = minclust
        cluster_points[minclust] << point
      end

      updated_centroids = @centroids.map.with_index do |centroid, ci|
        mean cluster_points[ci], @total_features
      end

      moves = @centroids.map.with_index do |centroid, ci|
        distance centroid, updated_centroids[ci]
      end

      @centroids = updated_centroids

      break if moves.max < 0.001
      break if @iterations > 300

      @clusters.each &:clear
      cluster_points.each &:clear
    end

    @error = calculate_error

    @runtime = Time.now - start_time
    self
  end

  private
    def distance h1, h2
      # diffs will be squared, so sign is irrelevant
      diffs = h1.merge(h2) {|k, v1, v2| (v1 || 0) - (v2 || 0) }
      sum_of_squares = diffs.inject(0) {|sum, (k, v)| sum + v**2 }
      Math.sqrt sum_of_squares
    end

    def mean hashes, size
      sums = {}
      hashes.each do |hsh| 
        sums.merge!(hsh) {|k, v1, v2| (v1 || 0) + (v2 || 0) }
      end
      sums.each {|k, v| sums[k] = v / size.to_f }
      sums
    end

    def calculate_error
      errors = @clusters.map.with_index do |point_indexes, ci|
        if point_indexes.empty?
          0
        else
          centroid = @centroids[ci]

          d2 = point_indexes.map do |pi|
            point = @points[pi]
            distance(centroid, point)**2
          end

          d2.reduce(:+)
        end
      end

      errors.reduce(:+)
    end
end
