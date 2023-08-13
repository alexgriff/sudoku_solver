class Strategy::HiddenSingle < Strategy::BaseStrategy
  def self.execute(board, cell)
    if cell.candidates.length > 1
      uniq_candidate = (
        (cell.intersecting_candidates(cell.row(board).uniq_candidates)).first ||
        (cell.intersecting_candidates(cell.column(board).uniq_candidates)).first ||
        (cell.intersecting_candidates(cell.box(board).uniq_candidates)).first
      )
      if uniq_candidate
        board.state.register_change(board, cell,  [uniq_candidate], {strategy: name})
      end
    end
  end
end
