FactoryGirl.define do
  factory :event do
    title { Faker::Name.title }
    duration { Faker::Number.digit }
    start_time { Faker::Time.forward(2, :morning) }
    email { Faker::Internet.email }
    timezone "UTC"
    description "Test Description should be pretty long.Test Description should be pretty long.Test Description should be pretty long."
  end
end