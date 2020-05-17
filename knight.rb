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
				moves.push([num1, num2])
			end
		end
		# puts moves.to_s	
		moves.length.times {|i| moves.push(moves[i].reverse)}
		return moves.map {|move| Vector::elements(move, copy=true)}
	end

	def find_neighbours
		new_positions = []
		self.move_vectors.each {|vector| new_positions.push(vector + self.position)}
		# puts new_positions.to_s
		valid_positions = new_positions.keep_if {|position| position[0].between?(0,7) && position[1].between?(0,7)}
		return valid_positions
	end

	def to_s
		self.position
	end

end

def print_levels levels
	puts
	levels.each_with_index{|level, i| puts "Level #{i}: #{print_array(level)}"}
	puts
end
def print_array arr 
	s = ""
	arr.each{|el| s += "#{el.to_s}, "}
	return s
end

start_pos = Vertex.new(3,3)
finish_pos = Vertex.new(3, 4)

def construct_levels (start_pos, finish_pos)
	levels = [[start_pos]]
	until levels.last.include?(finish_pos)
		neighbour_vertices = []
		levels.last.each{|vertex| neighbour_vertices.push(vertex.neighbours)}
		neighbour_vertices = neighbour_vertices.flatten.map{|pos| Vertex.new(pos[0], pos[1])}
		neighbour_vertices = neighbour_vertices.keep_if {|vertex| !levels.flatten.include?(vertex)}
		neighbour_vertices = neighbour_vertices.uniq(&:position)
		levels.push(neighbour_vertices)
	end
	levels.last.keep_if{|vertex| vertex == finish_pos}
	return levels
end

levels = construct_levels(start_pos, finish_pos)
print_levels(levels)

# puts levels[levels.length-2].keep_if {|vertex| levels.last[0].neighbours.include?(vertex.position)}

# puts levels.last[0].neighbours[0] == Vertex.new(4,6).position

def prune_levels (levels)
	i = levels.length-1
	while i > 0
		parent_level_neighbours = []
		levels[i].each {|vertex| parent_level_neighbours.push(vertex.neighbours)}
		levels[i-1].keep_if {|sub_vertex| parent_level_neighbours.flatten.include?(sub_vertex.position)}
		i -= 1
	end
	return levels
end

print_levels(prune_levels (levels))

master_array = []

i = levels.length-1

def build_paths_print (parents, children)
	paths = []
	parents.each do |parent|
		valid_children = children.keep_if{|child| parent.neighbours.include?(child.position)}
		valid_children.each {|child| paths.push([parent.position, child.position])}
	end
	return paths
end

def build_paths (levels)
	i = levels.length-1
	paths = [levels.last]
	while i > 0
		children = levels[i-1]
		current_paths = paths.length
		new_paths = []
		paths.each do |path|
			# each parent is an array or path, which needs to be extended using the children of the last vertex in the path
			parent = path.last 
			valid_children = children.keep_if{|child| parent.neighbours.include?(child.position)}
			puts "valid children"
			valid_children.each{|child| puts child.position}
			valid_children.each {|child| new_paths.push(path + [child])}
		end
		paths = new_paths 
		i -= 1
	end
	paths.each do |el| 
		puts
		el.each do |vert| 
			puts vert.position
		end
	end
	return paths
end

# puts levels.last.to_s
# build_paths(levels).each {|path| puts path.length} 
build_paths(levels)