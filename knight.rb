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

start_pos = Vertex.new(0,0)
finish_pos = Vertex.new(4, 2)

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
	return levels
end

levels = construct_levels(start_pos, finish_pos)
print_levels(levels)
