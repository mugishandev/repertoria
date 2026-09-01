class AddChessUsernameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :chess_username, :string
  end
end
