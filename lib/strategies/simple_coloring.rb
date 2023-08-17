class Strategy::SimpleColoring < Strategy::BaseStrategy
  def self.apply(board)
    board.each_candidate do |cand|
      all_conjugate_pair_cells = board.houses.map do |house|
        house.conjugate_pair(cand)
      end.flatten.uniq

      begin
        cell_colors = {}

        all_conjugate_pair_cells.each do |cell|
          # if the cell hasnt been seen yet, mark it with an arbitray color
          current_color = cell_colors[cell] ||= :violet
          opposite_color = current_color == :violet ? :orange : :violet

          seen_cells = board.empty_cells_seen_by(cell).intersection(all_conjugate_pair_cells)

          if seen_cells.length == 1
            # if a conjugate pair cell can only see it's partner and is not part of any chain,
            # reset coloring and continue to next cell
            cell_colors = {}
            next
          end

          seen_cells.each do |seen_cell|
            # if a cell has already been seen and it's marked with the current color,
            # there's a problem!
            if cell_colors[seen_cell] && cell_colors[seen_cell] == current_color
              raise ColorError.new(current_color, cell_colors.except(cell))
            end
            # otherwise mark it with the opposite color
            cell_colors[seen_cell] = opposite_color
          end
        end
      rescue ColorError => err
        true_cells = err.cell_colors.keys.select { |cell| err.cell_colors[cell] == err.false_color }
        # debugger
        board.each_empty_cell(true_cells) do |cell|
          board.state.register_change(
            board,
            cell,
            [cand],
            {strategy: name, strategy_id: "#{true_cells.map(&:id)}|#{cand}"}
          )
        end
      end
    end
  end

  class ColorError < StandardError
    attr_reader :false_color, :cell_colors

    def initialize(false_color, cell_colors)
      @false_color = false_color
      @cell_colors = cell_colors
      super()
    end
  end
end
