class Strategy::HiddenSingle < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = board.state.get_cell(cell_id)
    if cell.candidates.length > 1
      uniq_candidate = (
        (cell.intersecting_candidates(cell.row(board).uniq_candidates)).first ||
        (cell.intersecting_candidates(cell.column(board).uniq_candidates)).first ||
        (cell.intersecting_candidates(cell.box(board).uniq_candidates)).first
      )
      if uniq_candidate
        board.state.register_change(board, cell_id,  [uniq_candidate], {strategy: name})
      end
    end
  end
end
