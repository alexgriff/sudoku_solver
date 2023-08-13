class Strategy::XWing < Strategy::BaseStrategy
  def self.execute(board, cell)
    n = 2
    cell.candidates.each do |cand|
      self.execute_for_line(:row, board, cell, cand)
    end
    cell.candidates.each do |cand|
      self.execute_for_line(:column, board, cell, cand)
    end
  end

  def self.execute_for_line(line_type, board, cell, cand)
    n = 2
    other_axis_line_type = line_type == :row ? :column : :row
    # for a cand in a line (weed out singles)
    # look for n other lines, where the cand is present in a total of exactly n of the other-axis lines
    # ie if a cand is in 2 rows, is it in the same col in each of those rows?
    current_line = cell.send(line_type, board)

    if current_line.cells_with_any_of_candidates([cand]).length >= 2
      other_axis_ids_current_line = current_line.cells_with_any_of_candidates([cand]).map { |ln_cell| ln_cell.send("#{other_axis_line_type}_id") }
      other_lines_w_cand = (board.send("#{line_type}s") - [current_line]).select { |ln| ln.has_any_of_candidates?([cand]) }
        
      # is there another line of my type where the other-axis ids 'match' mine...
      # ..meaning there is a set comprised of me + some other lines
      # where togeher our set is of size n,
      # and where as a whole we have exactly n other-axis ids for the cand

      # for all of the other lines, build sets of size n - 1 (when you add in the current line it size will equal n)
      other_lines_w_cand.permutation(n - 1).each do |set|
        next unless set.all? { |ln| ln.has_any_of_candidates?([cand]) } # accounts for state having changed - TODO do this better
        other_axis_ids_in_set = set.map { |ln| ln.cells_with_any_of_candidates([cand]).map(&:"#{other_axis_line_type}_id") }
        common_axis_ids_in_set = [*other_axis_ids_in_set].reduce(&:intersection)

        uniq_other_axis_ids = (other_axis_ids_current_line + common_axis_ids_in_set).uniq
        
        if uniq_other_axis_ids.length == n
          uniq_other_axis_ids.each do |other_axis_id|
            other_axis = board.send("#{other_axis_line_type}s")[other_axis_id]

            # filter out cells that intersect with the lines in the current set
            full_set = [current_line] + set
            intersecting_cells = full_set.map(&:cells).flatten
            other_axis.other_cells_with_any_of_candidates(intersecting_cells, [cand]).each do |other_axis_cell|
              new_candidates = other_axis_cell.candidates - [cand]
              board.state.register_change(
                board,
                other_axis_cell,
                other_axis_cell.candidates - [cand],
                {strategy: name, originating_cell_id: cell.id, x_wing_id: "#{line_type}-#{full_set.map(&:id)}|#{other_axis_line_type}-#{uniq_other_axis_ids}|locked-#{cand}"}
              )
            end
          end
        end
      end
    end
  end
end
