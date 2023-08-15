module Strategy
  class BaseStrategy
    def self.name
      self.to_s
          .sub(/.*?::/, '')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
          .to_sym
    end

    def self.apply(board)
      raise ".apply is not implemented in #{self}"
    end
  end

  module NakedSubsetN
    def naked_subset_n(n, board)
      board.each_empty_cell do |cell|
        if cell.candidates.length == n
          board.houses_for(cell).each do |house|
            naked_buddy_cells = house.cells_with_candidates(cell.candidates).reject do |other_cell|
              (other_cell.candidates - cell.candidates).any?
            end

            if naked_buddy_cells.length == n
              house.each_cell(house.cells - naked_buddy_cells) do |non_buddied_cell|
                board.state.register_change(
                  board,
                  non_buddied_cell,
                  non_buddied_cell.candidates - cell.candidates,
                  {strategy: name, naked_buddies: naked_buddy_cells.map(&:id)}
                )
              end
            end
          end
        end
      end
    end
  end


  module HiddenSubsetN
    def hidden_subset_n(n, board)
      board.each_empty_cell do |cell|
        # are any n of my candidates found in exactly n cells
        if cell.candidates.length >= n
          board.houses_for(cell).each do |house|
            next if (cell.candidates.intersection(house.uniq_candidates)).any? # a hidden single is handled separately

            cell.candidate_combinations(n).each do |cand_permutation|
              hidden_buddys = house.cells_with_candidates(cand_permutation)
              if hidden_buddys.length == n
                hidden_buddys.each do |hidden_buddy_cell|
                  board.state.register_change(
                    board,
                    hidden_buddy_cell,
                    hidden_buddy_cell.candidates.intersection(cand_permutation),
                    {strategy: name, hidden_buddies: hidden_buddys.map(&:id)}
                  )
                end
              end
            end
          end
        end
      end
    end
  end

  module BasicFish
    def basic_fish_n(n, board)
      apply_to_line(:row, n, board)
      apply_to_line(:column, n, board)
    end

    def apply_to_line(line_type, n, board)
      other_axis_line_type = line_type == :row ? :column : :row
      # for each cand, is it found in exactly n lines
      # where it's location in those lines is only in n of the other-axis lines
      # ie if a cand is found in only 2 rows, is it in the same col in each of those rows?
      board.each_candidate do |cand|
        lines_with_cand = board.send("#{line_type}s").select { |ln| ln.candidate_counts[cand] }

        # build sets of size n lines
        # is there some set where the position of the cells with cand
        # are, in total, in only n other-axis positions
        lines_with_cand.combination(n).to_a.each do |line_set|
          next unless line_set.all? { |ln| ln.has_candidates?([cand]) } # do i need this
          other_axis_ids = line_set.map do |ln|
            ln.cells_with_candidates([cand]).map(&:"#{other_axis_line_type}_id")
          end

          matched_other_axis_ids = other_axis_ids.flatten.uniq

          if matched_other_axis_ids.length == n # there's alignment!
            # filter out cells that intersect with the lines in the current set
            intersecting_cells = line_set.map(&:cells).flatten

            matched_other_axis_ids.each do |id|
              other_axis_line = board.send("#{other_axis_line_type}s")[id]

              other_axis_line.each_cell_with_candidates(
                other_axis_line.cells_with_candidates([cand]) - intersecting_cells,
                [cand]
              ) do |cell|
                board.state.register_change(
                  board,
                  cell,
                  cell.candidates - [cand],
                  {strategy: name, fish_id: "#{line_type}-#{line_set.map(&:id)}|#{other_axis_line_type}-#{matched_other_axis_ids}|locked-#{cand}"}
                )
              end
            end
          end
        end
      end
    end
  end
end
