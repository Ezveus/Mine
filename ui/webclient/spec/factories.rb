FactoryGirl.define do
  factory :user do
    name "Ezveus"
    email "ciappam@gmail.com"
    password "plopitude"
    password_confirmation "plopitude"
    isAdmin 1
    website "http://localhost:3000"
  end
end
