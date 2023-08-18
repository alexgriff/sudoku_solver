class Strategy::SimpleColoring < Strategy::BaseStrategy
  COLORS = [:violet, :orange]
  
  def self.apply(board)
    board.each_candidate do |cand|
      all_conjugate_pairs = board.houses.map { |house| house.conjugate_pair(cand) }.reject(&:empty?)
      # Map of cell pointing to arrays of cells that it makes a conjugate pair with in any house
      # {Cell => [Cell],  Cell => [Cell, Cell], ...}
      cell_to_conjugate_pairs = all_conjugate_pairs.each_with_object({}) do |pair, res|
        pair.each do |single|
          res[single] ||= []
          res[single] = res[single].union(pair - [single])
        end
      end

      
      # Note - I suspect a lot of the chain stuff below can be abstracted out and re-used for
      # different types of chains. Not gonna totally refactor this yet because of that.

      sub_chains = cell_to_conjugate_pairs.map { |k, v| [k] + v }
      # chains is an array of arrays of cells. Each subarray representing a contiguous chain
      # where cell A can see cell B which can see cell C, etc,
      # there can be loops in the chain but each cell will be present 1x   
      chains = sub_chains.each_with_object([]) do |sub_chain, res|
        sub_chains.difference(sub_chain).each do |other_sub_chain|
          if sub_chain.intersection(other_sub_chain).any?
            new_sub_chain = sub_chain.union(other_sub_chain)
            
            # TODO: better note on why we need to loop again here
            # (accounts for intersecting elements from an earlier iteration - a later intersection implies an earlier missed intersection)
            intersecting_index = res.index { |other_partial_chain| other_partial_chain.intersection(new_sub_chain).any? }
            if intersecting_index
              res[intersecting_index] = new_sub_chain.union(res[intersecting_index])
            else
              res << new_sub_chain
            end
          end
        end
      end

      # Combine the ideas above,
      # represent each continuous chain in a data structure like cell_to_conjugate_pairs
      conj_pair_chains = chains.map { |chain| cell_to_conjugate_pairs.slice(*chain) }

      conj_pair_chains.each do |chain|
        begin
          cell_colors = color_in(chain)
          same_color_cells = COLORS.map do |color|
            cell_colors.keys.select { |cell| cell_colors[cell] == color }
          end

          # Check if the same house has the same color in it more than once.
          # If so, that's bad! That color cannot be true
          same_color_cells.each.with_index do |one_color_cells, i|
            house_set = Set.new
            one_color_cells.each do |cell|
              board.houses_for(cell).each do |house|
                raise ColorError.new(COLORS[i]) unless house_set.add?(house)
              end
            end
          end

          # Check if there are any cells with the cand that can see both colors
          # if so, that cell can't be the cand
          other_cells_with_cand = board.cells_with_candidates([cand]) - same_color_cells.flatten

          seen_by_both_colors = same_color_cells.map do |one_color_cells|
            one_color_cells.map { |colored_cell| board.empty_cells_seen_by(colored_cell) }
                          .flatten
                          .intersection(other_cells_with_cand)
          end.reduce(&:intersection)

          board.each_empty_cell(seen_by_both_colors) do |cell|
            board.state.register_change(
              board,
              cell,
              cell.candidates - [cand],
              {strategy: name, seen_by_opposite_colors: true, strategy_id: "#{seen_by_both_colors.map(&:id).sort}|#{cand}"}
            )
          end
        rescue ColorError => color_err
          true_color = opposite_color_for(color_err.false_color)
          true_color_cells = cell_colors.keys.select { |cell| cell_colors[cell] == true_color }
          true_color_cells.each do |cell|
            board.state.register_change(
              board,
              cell,
              [cand],
              {strategy: name, same_color_in_same_house: true, strategy_id: "#{true_color_cells.map(&:id).sort}|#{cand}"}
            )
          end
        end
      end
    end
  end

  def self.color_in(chain)
    # mark the first cell with an arbitrary color
    cell = chain.keys.first
    cell_colors = {}
    cell_colors[cell] = COLORS.first
    recursive_color_in(cell, chain, cell_colors)
  end

  def self.recursive_color_in(cell, chain, cell_colors)
    # return if every cell has been marked with a color
    return cell_colors if chain.keys.length == cell_colors.keys.length
    current_color = cell_colors[cell]
    opposite_color = opposite_color_for(current_color)
    
    chain[cell].each do |seen_cell|
      # Mark cells the current cell can see with the opposite color,
      # and recur to mark cells the seen cell can see.
      # Skip if cell has already been marked
      if cell_colors[seen_cell].nil?
        cell_colors[seen_cell] = opposite_color
        cell_colors = recursive_color_in(seen_cell, chain, cell_colors)
      end
    end
    cell_colors
  end

  def self.opposite_color_for(color)
    color == COLORS[0] ? COLORS[1] : COLORS[0]
  end

  class ColorError < StandardError
    attr_reader :false_color

    def initialize(false_color)
      @false_color = false_color
      super()
    end
  end
end
