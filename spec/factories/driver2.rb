FactoryBot.define do
    factory :driver2, class: Driver do
       sequence(:email) { |id| "user#{id}@gmail.com"}
       password {'password'}
       first_name { 'Jeff' }
       last_name {'brown'}
       phone {'336-345-1570'}
       organization
    end
end