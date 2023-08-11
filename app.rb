get '/solve/:board' do
  content_type :json
  board = Board.from_txt(params['board'])
  Solve.new.solve(board)
  {
    history: board.state.history.all,
    summary: board.summary
  }.to_json
end
