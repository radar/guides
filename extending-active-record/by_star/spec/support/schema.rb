ActiveRecord::Schema.define do
  self.verbose = false

  create_table :posts, :force => true do |t|
    t.string :text
    t.timestamps
    t.datetime :published_at
  end
  
  create_table :events, :force => true do |t|
    t.string :name
    t.date :date
  end
end