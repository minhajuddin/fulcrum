class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.string :file
      t.integer :story_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end
