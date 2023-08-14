module SmartEnumerators
  module Base
    def safe_each(collection, condition=Proc.new { true }, &block)
      i = 0
      while i < collection.length
        yield collection[i] if condition
        i += 1
      end
    end
  end

  module BoardEnumerators
    include Base
  
    def each_empty_cell(cell_collection=nil, &block)
      safe_each(
        cell_collection || cells,
        Proc.new { |cell| cell.empty? },
        &block
      )
    end

    def each_incomplete_box(&block)
      safe_each(
        boxes,
        Proc.new { |box| !box.complete? },
        &block
      )
    end

    def each_candidate(&block)
      # can be made smarter to skip already solved cands
      safe_each(
        Cell::ALL_CANDIDATES.dup,
        &block
      )
    end
  end

  module HouseEnumerators
    include Base

    def each_cell(cell_collection=nil, &block)
      safe_each(
        cell_collection || cells,
        Proc.new { |cell| cell.empty? },
        &block
      )
    end

    def each_cell_with_candidates(cell_collection=nil, cands, &block)
      safe_each(
        cell_collection || cells,
        Proc.new { |cell| cell.empty? && cell.has_candidates?(cands) },
        &block
      )
    end

    def each_non_uniq_candidate(&block)
      safe_each(
        candidates,
        Proc.new { |cand| candidates.include?(cand) && !uniq_candidates.include?(cand) },
        &block
      )
    end
  end
end
