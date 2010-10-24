Given /^there are the following forums:$/ do |table|
  table.hashes.each do |attributes|
    ForThem::Forum.create(attributes)
  end
end

