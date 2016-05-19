FactoryGirl.define do
  factory :auction do
    association :user, factory: :admin_user
    start_datetime { Time.now - 3.days }
    end_datetime { Time.now + 3.days }
    result :not_applicable
    title { Faker::Company.catch_phrase }
    type :multi_bid
    published :published
    summary Faker::Lorem.paragraph
    description Faker::Lorem.paragraphs(3, true).join("\n\n")
    delivery_deadline { Time.now + 10.days }

    trait :single_bid_with_tie do
      single_bid

      after(:create) do |auction|
        Timecop.freeze(auction.start_datetime) do
          Timecop.scale(3600)
          2.times do
            create(:bid, auction: auction, amount: 3000)
          end
        end
      end
    end

    trait :with_bidders do
      published
      transient do
        bidder_ids []
      end

      after(:build) do |instance|
        Timecop.freeze(instance.start_datetime) do
          Timecop.scale(3600)
          (1..2).each do |i|
            amount = 3499 - (20 * i) - rand(10)
            instance.bids << create(:bid, auction: instance, amount: amount)
          end
        end
      end

      after(:create) do |auction, evaluator|
        evaluator.bidder_ids.each_with_index do |bidder_id, index|
          lowest_bid = auction.bids.sort_by(&:amount).first
          amount = lowest_bid.amount - (10 * index) - rand(10)
          auction.bids << create(:bid, bidder_id: bidder_id, auction: auction, amount: amount)
        end
      end
    end

    trait :between_micropurchase_and_sat_threshold do
      association :user, factory: :contracting_officer
      start_price do
        rand(StartPriceThresholds::MICROPURCHASE+1..StartPriceThresholds::SAT)
      end
    end

    trait :below_micropurchase_threshold do
      start_price { rand(1..StartPriceThresholds::MICROPURCHASE) }
    end

    trait :available do
      start_datetime { Time.now - 2.days }
      end_datetime { Time.now + 2.days }
    end

    trait :closed do
      end_datetime { Time.now - 2.days }
    end

    trait :delivered do
      end_datetime { Time.now - 2.days }
      delivery_deadline { Time.now - 1.day }
      delivery_url 'https://github.com/foo/bar'
    end

    trait :not_delivered do
      delivery_url nil
    end

    trait :paid do
      delivered
      awardee_paid_status :paid
    end

    trait :running do
      with_bidders
    end

    trait :expiring do
      end_datetime { Time.now + 3.hours }
    end

    trait :future do
      start_datetime { Time.now + 1.day }
    end

    trait :delivery_deadline_expired do
      closed
      delivery_deadline { end_datetime + 1.day }
    end

    trait :accepted do
      result :accepted
    end

    trait :rejected do
      result :rejected
    end

    trait :paid do
      awardee_paid_status :paid
    end

    trait :not_paid do
      awardee_paid_status :not_paid
    end

    trait :cap_submitted do
      cap_proposal_url 'https://cap.18f.gov/proposals/2486'
    end

    trait :not_evaluated do
      result :not_applicable
    end

    trait :published do
      published :published
    end

    trait :unpublished do
      published :unpublished
    end

    trait :single_bid do
      type :single_bid
    end

    trait :multi_bid do
      type :multi_bid
    end

    trait :complete_and_successful do
      with_bidders
      delivery_deadline_expired
      delivered
      accepted
      cap_submitted
      paid
    end

    trait :payment_pending do
      delivered
      accepted
      cap_submitted
      not_paid
      delivery_deadline_expired
    end

    trait :payment_needed do
      accepted
      delivered
    end

    trait :evaluation_needed do
      delivered
      not_evaluated
      delivery_deadline_expired
    end

    trait :delivery_past_due do
      not_delivered
      delivery_deadline_expired
    end
  end
end
