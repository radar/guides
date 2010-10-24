class CreateForThemForums < ActiveRecord::Migration
  def self.up
    create_table :for_them_forums do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :for_them_forums
  end
end
