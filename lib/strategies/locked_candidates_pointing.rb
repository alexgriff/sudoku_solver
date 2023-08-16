class Strategy::LockedCandidatesPointing < Strategy::BaseStrategy
  def self.apply(board)
    board.each_incomplete_box do |box|      
      box.each_non_uniq_candidate do |shared_cand|
        cells_with_shared_cand = box.cells_with_candidates([shared_cand])
        
        line_house = if cells_with_shared_cand.map(&:row_id).uniq.count == 1
                       board.rows[cells_with_shared_cand.first.row_id]
                     elsif cells_with_shared_cand.map(&:column_id).uniq.count == 1
                       board.columns[cells_with_shared_cand.first.column_id]
                     end

        if line_house
          line_house.each_cell_with_candidates(
            line_house.cells_with_candidates([shared_cand]) - box.cells,
            [shared_cand]
          ) do |outside_current_box_cell|
            board.state.register_change(
              board,
              outside_current_box_cell,
              outside_current_box_cell.candidates - [shared_cand],
              {strategy: name, strategy_id: "Box-#{box.id}|#{line_house.class}-#{line_house.id}|Locked-#{shared_cand}"}
            )
          end
        end
      end
    end
  end
end
