class Strategy::HiddenSingle < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.get_cell(cell_id)
    if cell.candidates.length > 1
      uniq_candidate = (
        (cell.intersecting_candidates(Row.for_cell(board, cell).uniq_candidates)).first ||
        (cell.intersecting_candidates(Column.for_cell(board, cell).uniq_candidates)).first ||
        (cell.intersecting_candidates(Box.for_cell(board, cell).uniq_candidates)).first
      )
      if uniq_candidate
        board.update_cell(cell_id,  [uniq_candidate], {strategy: name})
      end
    end
  end
end
