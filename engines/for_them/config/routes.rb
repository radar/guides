Rails.application.routes.draw do
  scope :module => "for_them" do
    root :to => "forums#index"
  end
end