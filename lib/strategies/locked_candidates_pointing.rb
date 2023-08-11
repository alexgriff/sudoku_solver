class Strategy::LockedCandidatesPointing < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.state.get_cell(cell_id)
    box = cell.box(board)
    cands_with_multiple_in_box = box.candidate_counts.select { |k, v| v == 2 || v == 3 }.keys

    cell.intersecting_candidates(cands_with_multiple_in_box).each do |shared_cand|
      cell_ids_with_shared_cand = box.other_cell_ids_with_any_of_candidates([cell_id], [shared_cand])
      next if cell_ids_with_shared_cand.empty?
      
      line_house = if cell_ids_with_shared_cand.all? { |cell_id| Cell.new(id: cell_id).row_id == cell.row_id }
                      cell.row(board)
                   elsif cell_ids_with_shared_cand.all? { |cell_id| Cell.new(id: cell_id).column_id == cell.column_id }
                      cell.column(board)
                   end

      if line_house
        line_house.other_cell_ids_with_any_of_candidates(box.cell_ids, [shared_cand]).each do |outside_box_cell_id|
          outside_box_cell = board.state.get_cell(outside_box_cell_id)
          new_candidates = outside_box_cell.candidates - [shared_cand]

          if new_candidates != outside_box_cell.candidates
            board.state.register_change(
              board,
              outside_box_cell.id,
              new_candidates,
              {strategy: name, locked_alignment_id: "Box-#{box.id}|Row-#{cell.row(board).id}|Locked-#{shared_cand}"}
            )
          end
        end
      end
    end
  end
end
