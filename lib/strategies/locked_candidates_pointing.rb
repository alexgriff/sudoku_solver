class Strategy::LockedCandidatesPointing < Strategy::BaseStrategy
  def self.execute(board, cell)
    box = cell.box(board)
    cands_with_multiple_in_box = box.candidate_counts.select { |k, v| v == 2 || v == 3 }.keys

    cell.intersecting_candidates(cands_with_multiple_in_box).each do |shared_cand|
      cells_with_shared_cand = box.other_cells_with_any_of_candidates([cell], [shared_cand])
      next if cells_with_shared_cand.empty?
      
      line_house = if cells_with_shared_cand.all? { |c| c.row_id == cell.row_id }
                      cell.row(board)
                   elsif cells_with_shared_cand.all? { |c| c.column_id == cell.column_id }
                      cell.column(board)
                   end

      if line_house
        line_house.other_cells_with_any_of_candidates(box.cells, [shared_cand]).each do |outside_current_box_cell|
          board.state.register_change(
            board,
            outside_current_box_cell,
            outside_current_box_cell.candidates - [shared_cand],
            {strategy: name, locked_alignment_id: "Box-#{box.id}|Row-#{cell.row(board).id}|Locked-#{shared_cand}"}
          )
        end
      end
    end
  end
end
