class FixRoomColumnName < ActiveRecord::Migration[5.0]
  def change
    rename_column :song_queues, :name, :room
  end
end
