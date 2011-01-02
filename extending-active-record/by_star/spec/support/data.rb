Post.create(:text => "First post!")
Post.create(:text => "So last year!", :created_at => Time.now - 1.year)
Post.create(:text => "First published post!", :published_at => Time.now)
Event.create(:name => "The Party", :date => Time.now)