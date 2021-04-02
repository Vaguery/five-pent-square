require 'set'

space = Set.new([0,1,2,3,4].product([0,1,2,3,4]))

names = [:A,:B,:C,:D,:E]

class Omino
  attr_accessor :label,:cells

  def initialize(label,cells)
    @label = label
    @cells = Set.new(cells)
  end

  def self.neighbors_of_cell(cell,possible_set)
    i,j = [cell[0],cell[1]]
    orthogonal_neighbors = Set[ [i-1,j],[i+1,j],[i,j-1],[i,j+1] ]
    return possible_set & orthogonal_neighbors
  end

  def feasible_neighbors(possible_set)
    @cells.inject(Set.new()) {|s,c| s | Omino.neighbors_of_cell(c,possible_set)}
  end

  def feasible_neighbors_of_cells(cells,possible_set)
    cells.inject(Set.new()) do |nbs,c|
      nbs | Omino.neighbors_of_cell(c,possible_set)
    end
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

  def contiguous?(possible_set)
    growing = @cells.take(1)
    unclaimed = @cells.drop(1)
    next_layer = feasible_neighbors_of_cells(growing,possible_set)
    new_neighbors = next_layer & unclaimed

    until new_neighbors.empty? || unclaimed.empty?
      growing = Set.new(growing) | new_neighbors
      unclaimed = Set.new(unclaimed) - new_neighbors
      next_layer = feasible_neighbors_of_cells(growing,possible_set)
      new_neighbors = next_layer & unclaimed
    end

    return unclaimed.empty?
  end

  def touching?(other_omino,possible_set)
    mine = self.feasible_neighbors(possible_set)
    !(mine & other_omino.cells).empty?
  end

  def merge_cells(other_omino)
    self.cells | other_omino.cells
  end

  def self.all_feasible_splits(cells,size1,space)
    parts = cells.to_a.sort
    subdivisions = Set.new()
    parts.combination(size1).each do |combo|
      x1 = Omino.new(:x1,combo)
      x2 = Omino.new(:x2,parts - combo)
      if x1.contiguous?(space)
        if x2.contiguous?(space)
          subdivisions.add([x1.cells,x2.cells])
        end
      end
    end
    return subdivisions
  end
end

starting_ominoes = [
  Omino.new(:A,[0,1,2,3,4].product([0])),
  Omino.new(:B,[0,1,2,3,4].product([1])),
  Omino.new(:C,[0,1,2,3,4].product([2])),
  Omino.new(:D,[0,1,2,3,4].product([3])),
  Omino.new(:E,[0,1,2,3,4].product([4]))
]

puts Omino.draw_cells(starting_ominoes,space)
ab = starting_ominoes[0].merge_cells(starting_ominoes[1])
# puts ab.inspect
newAB =  Omino.all_feasible_splits(ab,5,space)
# draw them all
newAB.each do |d|
  puts "\n\n" + Omino.draw_cells([Omino.new(:a,d[0]),Omino.new(:b,d[1])]+starting_ominoes[2..-1],space)
end
