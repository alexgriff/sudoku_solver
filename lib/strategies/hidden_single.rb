class Strategy::HiddenSingle < Strategy::BaseStrategy
  def self.apply(board)
    board.each_empty_cell do |cell|
      if cell.candidates.length > 1
        uniq_candidate = (
          (cell.intersecting_candidates(board.rows[cell.row_id].uniq_candidates)).first ||
          (cell.intersecting_candidates(board.columns[cell.column_id].uniq_candidates)).first ||
          (cell.intersecting_candidates(board.boxes[cell.box_id].uniq_candidates)).first
        )
        if uniq_candidate
          board.state.register_change(board, cell,  [uniq_candidate], {strategy: name})
        end
      end
    end
  end
end
