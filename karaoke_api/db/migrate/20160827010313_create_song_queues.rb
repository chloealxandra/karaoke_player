class CreateSongQueues < ActiveRecord::Migration[5.0]
  def change
    create_table :song_queues do |t|
      t.json :contents

      t.timestamps
    end
  end
end
