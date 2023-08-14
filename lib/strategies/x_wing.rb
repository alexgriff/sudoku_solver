class Strategy::XWing < Strategy::BaseStrategy
  def self.apply(board)
    apply_to_line(:row, board)
    apply_to_line(:column, board)
  end

  def self.apply_to_line(line_type, board)
    n = 2
    other_axis_line_type = line_type == :row ? :column : :row
    # for each cand, is it found in exactly n lines
    # where it's location in those lines is only in n of the other-axis lines
    # ie if a cand is found in only 2 rows, is it in the same col in each of those rows?
    board.each_candidate do |cand|
      lines_with_cand = board.send("#{line_type}s").select { |ln| ln.candidate_counts[cand] }

      # build sets of size n lines
      # is there some set where the position of the cells with cand
      # are, in total, in only n other-axis positions
      lines_with_cand.combination(n).to_a.each do |line_set|
        next unless line_set.all? { |ln| ln.has_candidates?([cand]) } # do i need this
        other_axis_ids = line_set.map do |ln|
          ln.cells_with_candidates([cand]).map(&:"#{other_axis_line_type}_id")
        end

        matched_other_axis_ids = other_axis_ids.flatten.uniq
        
        if matched_other_axis_ids.length == n # there's alignment!
          # filter out cells that intersect with the lines in the current set
          intersecting_cells = line_set.map(&:cells).flatten

          matched_other_axis_ids.each do |id|
            other_axis_line = board.send("#{other_axis_line_type}s")[id]

            other_axis_line.each_cell_with_candidates(
              other_axis_line.cells_with_candidates([cand]) - intersecting_cells,
              [cand]
            ) do |cell|
              board.state.register_change(
                board,
                cell,
                cell.candidates - [cand],
                {strategy: name, fish_id: "#{line_type}-#{line_set.map(&:id)}|#{other_axis_line_type}-#{matched_other_axis_ids}|locked-#{cand}"}
              )
            end
          end
        end
      end
    end
  end
end
