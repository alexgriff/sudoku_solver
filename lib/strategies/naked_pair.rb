class Strategy::NakedPair < Strategy::BaseStrategy
  def self.execute(board, cell_id)
    cell = Cell.from_state(id: cell_id, state: board.state[:cells2][cell_id])
    if cell.candidates.length == 2
      naked_pair_cands = cell.candidates
      
      row = Row.for_cell(board, cell)
      col = Column.for_cell(board, cell)
      box = Box.for_cell(board, cell)
      
      houses_with_naked_pair = [row, col, box].select do |house|
        house.other_cells([cell_id]).any? do |other_cell|
          other_cell.candidates == naked_pair_cands
        end
      end

      houses_with_naked_pair.each do |house|
        non_naked_pair_cells = house.empty_cells.reject { |c| c.candidates == naked_pair_cands }
        
        non_naked_pair_cells.each do |non_paired_cell|
          new_candidates = non_paired_cell.candidates - naked_pair_cands
          # @id=13439
          if new_candidates != non_paired_cell.candidates
            if new_candidates.length == 1
              # board.reducer.dispatch(
              #   Action.new(
              #     type: Action::UPDATE_CANDIDATES,
              #     cell_id: non_paired_cell.id,
              #     naked_pair_cell_id: cell.id,
              #     new_candidates: new_candidates,
              #     strategy: name
              #   )
              # )
              board.reducer.dispatch(
                Action.new(
                  type: Action::FILL_CELL,
                  cell_id: non_paired_cell.id,
                  value: new_candidates.first,
                  naked_pair_cell_id: cell.id,
                  strategy: name
                )
              )
            else
              board.reducer.dispatch(
                Action.new(
                  type: Action::UPDATE_CANDIDATES,
                  cell_id: non_paired_cell.id,
                  naked_pair_cell_id: cell.id,
                  new_candidates: new_candidates,
                  strategy: name
                )
              )
            end
          end
        end
      end
    end
  end
end
