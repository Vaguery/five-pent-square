require 'set'

space = Set.new([0,1,2,3,4].product([0,1,2,3,4]))

names = [:A,:B,:C,:D,:E]

class Omino
  attr_accessor :label,:cells

  def initialize(label,cells)
    @label = label
    @cells = Set.new(cells)
  end

  def neighbors_of_cell(cell,possible_set)
    i,j = [cell[0],cell[1]]
    orthogonal_neighbors = Set[ [i-1,j],[i+1,j],[i,j-1],[i,j+1] ]
    return possible_set & orthogonal_neighbors
  end

  def feasible_neighbors(possible_set)
    @cells.inject(Set.new()) {|s,c| s | neighbors_of_cell(c,possible_set)}
  end

  def sorted_cells(cells)
    cells.to_a.sort
  end

  def self.omino_labeling_hash(ominos)
    labeling = {}
    ominos.each do |o|
      o.cells.each {|c| labeling[c] = o.label.to_s}
    end
    return labeling
  end

  def self.draw_cells(ominos,embedding_space)
    i_lo,i_hi = embedding_space.collect {|c| c[0]}.minmax
    j_lo,j_hi = embedding_space.collect {|c| c[1]}.minmax

    labels = self.omino_labeling_hash(ominos)

    pic = ""
    (j_lo..j_hi).each do |j|
      (i_lo..i_hi).each do |i|
        pic += labels[[i,j]] || "."
      end
      pic += "\n"
    end
    return pic
  end
end

s = Omino.new(:A,[[4,4],[4,3],[4,2]])
t = Omino.new(:B,[[1,1],[1,2],[0,0],[1,0]])
puts t.neighbors_of_cell([0,0],space).inspect
tn = t.feasible_neighbors(space)
puts tn.to_a.sort.inspect
puts Omino.draw_cells([t,s],space)
