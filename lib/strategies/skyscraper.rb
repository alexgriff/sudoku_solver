class Strategy::Skyscraper < Strategy::BaseStrategy
  def self.apply(board)
    self.apply_to_line(:column, board)
    self.apply_to_line(:row, board)
  end

  def self.apply_to_line(line_type, board)
    other_axis_line_type = line_type == :row ? :column : :row

    board.each_candidate do |cand|
      lines_with_cand_2x = board.send("#{line_type}s").select { |ln| ln.candidate_counts[cand] == 2 }
      lines_with_cand_2x.combination(2).each do |pair|
        next unless pair.all? { |ln| ln.candidate_counts[cand] == 2 } # todo use enumerator

        pair_cells = pair.map { |ln| ln.cells_with_candidates([cand]) }
        pair_cells_other_axis_ids = pair_cells.map { |cells| cells.map(&:"#{other_axis_line_type}_id") }
        shared_other_axis_lines = pair_cells_other_axis_ids.reduce(:intersection)
        
        if shared_other_axis_lines.length == 1
          all_cells = pair_cells.flatten
          aligned_cells = all_cells.select { |cell| cell.send("#{other_axis_line_type}_id") == shared_other_axis_lines.first }
          non_aligned_cells = all_cells - aligned_cells
          board.each_cell_with_candidates(
            non_aligned_cells.map { |c| board.empty_cells_seen_by(c) }.reduce(:intersection),
            [cand]
          ) do |cell|
            board.state.register_change(
              board,
              cell,
              cell.candidates - [cand],
              {strategy: name, skyscraper: "#{aligned_cells.map(&:id).sort.join('-')}|#{cand}"}
            )
          end
        end
      end
    end
  end
end
