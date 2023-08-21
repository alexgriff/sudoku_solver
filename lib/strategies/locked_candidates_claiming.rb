class Strategy::LockedCandidatesClaiming < Strategy::BaseStrategy
  def self.apply(board)
    apply_to_line(:row, board)
    apply_to_line(:column, board)
  end

  def self.apply_to_line(line_type, board)
    board.each_incomplete_box do |box|
      box.each_non_uniq_candidate do |cand|
        cells = box.cells_with_candidates([cand])
        # if cand is in found in only 2 lines in a box is there another box with cand in same 2 lines
        cand_line_ids = cells.map(&:"#{line_type}_id").uniq
        if cand_line_ids.count == 2
          line = board.send("#{line_type}s")[cells.first.send("#{line_type}_id")]
          matched_box = (line.boxes - [box]).find do |other_box|
            cand_line_ids == other_box.cells_with_candidates([cand]).map(&:"#{line_type}_id").uniq
          end

          # if so, the third box cant have the cand in those lines
          if matched_box
            third_box = (line.boxes - [box, matched_box]).first
            claiming_line = (third_box.send("#{line_type}s") - cand_line_ids.map { |id| board.send("#{line_type}s")[id] }).first

            third_box.each_cell_with_candidates(
              third_box.cells - claiming_line.cells,
              [cand]
            ) do |cell|
              board.state.register_change(
                board,
                cell,
                cell.candidates - [cand],
                {strategy: name, strategy_application_id: "Box-#{third_box.id}|#{line_type}-#{cand_line_ids}|Locked-#{cand}"}
              )
            end
          end
        end
      end
    end
  end
end
