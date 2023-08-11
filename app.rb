require 'sinatra'
require_relative './environment.rb'

test_board = "1..6....9.9247..5......9.7...9....38.1..3..2.53....1...5.9......2..4586.8....1..4"

get '/solve/:board' do
  board = Board.from_txt(params['board'])
  Solve.new.solve(board)
  {
    history: board.state.history.all,
    summary: board.summary
  }.to_json
end
