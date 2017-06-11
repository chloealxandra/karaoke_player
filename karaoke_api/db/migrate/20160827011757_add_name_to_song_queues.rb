class AddNameToSongQueues < ActiveRecord::Migration[5.0]
  def change
    add_column :song_queues, :name, :int
  end
end
