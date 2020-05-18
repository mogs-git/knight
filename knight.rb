require 'matrix'

class Vertex
	attr_accessor :position, :neighbours
	include Comparable
	def initialize (x, y)
		@position = Vector[x, y]
		@neighbours = find_neighbours
	end

	def <=> (another_vertex)
		if self.position == another_vertex.position 
			return 0
		elsif self.position.r > another_vertex.position.r
			return 1
		else 
			return -1
		end
	end

	def move_vectors
		moves = []
		[1,-1].each do |num1| 
			[2,-2].each do |num2|
				moves.push(Vector::elements([num1, num2], copy = true))
				moves.push(Vector::elements([num2, num1], copy = true))
			end
		end

		return moves
	end

	def find_neighbours
		new_positions = []
		self.move_vectors.each {|vector| new_positions.push(vector + self.position)}
		valid_positions = new_positions.keep_if {|position| position[0].between?(0,7) && position[1].between?(0,7)}
		return valid_positions
	end

	def to_s
		self.position
	end

end

def print_array arr 
	s = ""
	arr.each{|el| s += "#{el.to_s}, "}
	return s
end

def print_levels levels
	puts
	levels.each_with_index{|level, i| puts "Level #{i}: #{print_array(level)}"}
	puts
end

def construct_levels (start_pos, finish_pos)
	levels = [[start_pos]]
	until levels.last.include?(finish_pos)
		# Get the neighbour positions for every valid position of the knight
		neighbour_vertices = []
		levels.last.each{|vertex| neighbour_vertices.push(vertex.neighbours)}
		
		# Convert these position vectors to vertices. Keep only if the knight hasn't travelled there before.
		neighbour_vertices = neighbour_vertices.flatten.map{|pos| Vertex.new(pos[0], pos[1])}
		neighbour_vertices = neighbour_vertices.keep_if {|vertex| !levels.flatten.include?(vertex)}

		# Remove any duplicated positions.
		neighbour_vertices = neighbour_vertices.uniq(&:position)

		# The remaining Vertices are all the valid positions the Knight could move to. Add these to the next level.
		levels.push(neighbour_vertices)
	end

	levels.last.keep_if{|vertex| vertex == finish_pos} # The last level should just contain the finish position.
	return levels
end

def prune_levels (levels)
	# From the final level (the finish position), iterate back through each level and 
	# remove vertices that aren't a neighbour position of the calling level. 
	i = levels.length-1
	while i > 0
		parent_level_neighbours = []
		levels[i].each {|vertex| parent_level_neighbours.push(vertex.neighbours)}
		levels[i-1].keep_if {|sub_vertex| parent_level_neighbours.flatten.include?(sub_vertex.position)}
		i -= 1
	end
	return levels
end

def build_paths (levels)
	i = levels.length-1
	paths = [levels.last] 

	# paths begins as a single array of finish_pos, this array is then dequeued, and 
	# paths becomes n_children arrays of [finish_pos, nth_child_pos]
	# children to choose from come from the next level closer to the start_pos, a paths last vertex
	# might have multiple valid children in the next level, in which case all are pushed as separate new paths. 

	while i > 0
		children = levels[i-1]
		current_paths = paths.length
		new_paths = []
		paths.each do |path|
			# each parent is an array or path, which needs to be extended using the children of the last vertex in the path
			parent = path.last 
			valid_children = children.keep_if{|child| parent.neighbours.include?(child.position)}
			valid_children.each {|child| new_paths.push(path + [child])}
		end
		paths = new_paths 
		i -= 1
	end

	return paths
end

def print_paths (paths)
	paths.each do |el| 
		puts
		el.each do |vert| 
			puts vert.position
		end
	end
end

start_pos = Vertex.new(0,0)
finish_pos = Vertex.new(5, 7)

levels = construct_levels(start_pos, finish_pos)
# print_levels(levels)
levels = prune_levels(levels)
# print_levels(levels)
paths = build_paths(levels)
print_paths(paths)