require 'rails_helper'

RSpec.describe PlaceBid do
  let(:place_bid) { PlaceBid.new(params: params, user: current_user) }
  let(:place_second_bid) { PlaceBid.new(params: second_params, user: current_user) }
  let(:current_user) { FactoryGirl.create(:user, sam_status: :sam_accepted) }
  let(:second_user) { FactoryGirl.create(:user, sam_status: :sam_accepted) }
  let(:amount) { 1005 }
  let(:params) do
    {
      auction_id: auction_id,
      bid: {
        amount: amount
      }
    }
  end
  let(:second_amount) { 1000 }
  let(:second_params) do
    {
      auction_id: auction_id,
      bid: {
        amount: second_amount
      }
    }
  end
  let(:auction_id) { auction.id }
  let(:auction) do
    FactoryGirl.create(:auction,
                       :multi_bid,
                       started_at: Time.now - 3.days,
                       ended_at: Time.now + 7.days)
  end

  context 'when the auction start price is above the micro-purchase threshold' do
    let(:auction) { create(:auction, :between_micropurchase_and_sat_threshold) }

    context 'and the vendor is not a small business' do
      let(:current_user) { create(:user, :not_small_business) }

      it 'should reject the bid' do
        expect { place_bid.perform }.to raise_error(UnauthorizedError)
      end

      it 'should not create a new bid' do
        # need to rescue otherwise the raising of UnauthorizedError
        # causes the test to error before the change can be evaluated
        expect do
          begin
            place_bid.perform
          rescue
          end
        end.not_to change { Bid.count }
      end
    end

    context 'and the vendor is a small business' do
      let(:current_user) { create(:user, :small_business) }

      it 'should allow the bid' do
        expect { place_bid.perform }.to change { Bid.count }.by(1)
      end
    end
  end

  context 'when the auction is single-bid' do
    let(:auction) do
      FactoryGirl.create(:auction,
                         :single_bid,
                         :with_bidders,
                         started_at: Time.now - 3.days,
                         ended_at: Time.now + 7.days)
    end

    it 'should reject bids when the user has already bid on the given auction' do
      expect do
        place_bid.perform
        place_second_bid.perform
      end.to raise_error(UnauthorizedError)
    end

    it 'should allow tie bids' do
      params = {
        auction_id: auction_id,
        bid: {
          amount: 10
        }
      }
      expect do
        PlaceBid.new(params: params, user: current_user).perform
        PlaceBid.new(params: params, user: second_user).perform
      end.to_not raise_error
    end
  end

  context 'when auction cannot be found' do
    let(:auction) { double('auction', id: 1000) }

    it 'should raise a not found' do
      expect { place_bid.perform }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when the auction has expired' do
    let(:auction) do
      FactoryGirl.create(:auction,
                         started_at: Time.now - 5.days,
                         ended_at: Time.now - 3.day)
    end

    it 'should raise an authorization error (because we have that baked in)' do
      expect { place_bid.perform }.to raise_error(UnauthorizedError)
    end
  end

  context 'when the auction has not started yet' do
    let(:auction) do
      FactoryGirl.create(:auction,
                         started_at: Time.now + 5.days,
                         ended_at: Time.now + 7.days)
    end

    it 'should raise an authorization error (same as above)' do
      expect { place_bid.perform }.to raise_error(UnauthorizedError)
    end
  end

  context 'when the bid amount is in increments small than one dollar' do
    let(:amount) { 1_000.99 }

    it 'should raise an authorization error' do
      expect { place_bid.perform }.to raise_error(UnauthorizedError)
    end
  end

  context 'when the bid amount is above the starting price' do
    let(:amount) { 3600 }

    it 'should raise an authorization error' do
      expect { place_bid.perform }.to raise_error(UnauthorizedError)
    end
  end

  context 'when the bid amount is above the current bid price' do
    let(:amount) { 405 }

    it 'should raise an authorization error' do
      FactoryGirl.create(:bid, auction: auction, amount: amount - 5)
      expect { place_bid.perform }.to raise_error(UnauthorizedError)
    end
  end

  context 'when the bid amount is above the auction start price and there are no bids' do
    let(:amount) { 3600 }

    it 'should raise an authorization error' do
      expect { place_bid.perform }.to raise_error(UnauthorizedError)
    end
  end

  context 'when the bid amount is equal to the current bid price' do
    let(:amount) { 400 }

    it 'should raise an authorization error' do
      FactoryGirl.create(:bid, auction: auction, amount: amount)
      expect { place_bid.perform }.to raise_error(UnauthorizedError)
    end
  end

  context 'when the bid amount is equal to the auction start price and there are no bids' do
    let(:amount) { 3500 }

    it 'should raise an authorization error' do
      expect { place_bid.perform }.to raise_error(UnauthorizedError)
    end
  end

  context 'when the bid amount is negative' do
    let(:amount) { '-10' }

    it 'should raise an authorization error' do
      expect { place_bid.perform }.to raise_error(UnauthorizedError)
    end
  end

  context 'when the bid amount is 0' do
    let(:amount) { 0 }

    it 'should raise an authorization error' do
      expect { place_bid.perform }.to raise_error(UnauthorizedError)
    end
  end

  context 'when the amount has a comma' do
    let(:bid)    { place_bid.bid }
    let(:amount) { '1,000' }

    it 'should disregard the comma' do
      place_bid.perform
      expect(bid.amount).to eq(1000)
    end
  end

  context 'when all the data is great' do
    let(:bid) { place_bid.bid }

    it 'creates a bid' do
      expect { place_bid.perform }.to change { Bid.count }.by(1)
      expect(bid.auction_id).to eq(auction.id)
      expect(bid.bidder_id).to eq(current_user.id)
    end

    it 'rounds the amount to two decimal places' do
      place_bid.perform
      bid.reload
      expect(bid.amount).to eq(1005)
    end
  end
end
