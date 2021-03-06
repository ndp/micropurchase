require 'rails_helper'

describe 'GET /auctions' do
  include RequestHelpers

  context 'when the API key is invalid' do
    it 'ignores the key and returns a 200 HTTP response' do
      login
      api_key = FakeGitHub::INVALID_API_KEY

      get auctions_path, nil, headers(api_key)

      expect(response.status).to eq 200
    end
  end

  context 'when the API key is missing' do
    it 'returns a 200 HTTP response' do
      login
      api_key = nil

      get auctions_path, nil, headers(api_key)

      expect(response.status).to eq 200
    end
  end

  context 'when the API key is valid' do
    it 'returns a 200 HTTP response' do
      login
      api_key = FakeGitHub::VALID_API_KEY

      get auctions_path, nil, headers(api_key)

      expect(response.status).to eq 200
    end

    it 'returns valid auctions' do
      login
      create(:auction, :with_bidders)

      get auctions_path, nil, headers

      expect(response).to match_response_schema('auctions')
    end

    it 'returns iso8601 dates' do
      login
      create(:auction)

      get auctions_path, nil, headers

      expect(json_auctions.map {|a| a['created_at'] }).to all(be_iso8601)
      expect(json_auctions.map {|a| a['updated_at'] }).to all(be_iso8601)
      expect(json_auctions.map {|a| a['started_at'] }).to all(be_iso8601)
      expect(json_auctions.map {|a| a['ended_at'] }).to all(be_iso8601)
    end

    context 'when the auction is multi bid' do
      context 'and the auction is running' do
        it 'veils all bidder information' do
          login
          create(:auction, :running, :multi_bid, :with_bidders)

          get auctions_path, nil, headers

          json_bids.each do |bid|
            expect(bid['bidder_id']).to be_nil
            bidder = bid['bidder']
            expect(bidder['id']).to be_nil
            expect(bidder['name']).to be_nil
            expect(bidder['duns_number']).to be_nil
            expect(bidder['github_id']).to be_nil
            expect(bidder['created_at']).to be_nil
            expect(bidder['updated_at']).to be_nil
            expect(bidder['sam_status']).to be_nil
          end
        end

        context 'and the auction is closed' do
          it 'unveils all bidder information' do
            login
            create(:auction, :closed, :multi_bid, :with_bidders)

            get auctions_path, nil, headers

            json_bids.each do |bid|
              expect(bid['bidder_id']).to_not be_nil
              bidder = bid['bidder']
              expect(bidder['id']).to_not be_nil
              expect(bidder['name']).to_not be_nil
              expect(bidder['duns_number']).to_not be_nil
              expect(bidder['github_id']).to_not be_nil
              expect(bidder['created_at']).to_not be_nil
              expect(bidder['updated_at']).to_not be_nil
              expect(bidder['sam_status']).to_not be_nil
            end
          end
        end
      end
    end

    context 'when the auction is single bid' do
      context 'and the auction is running' do
        it 'veils all bids' do
            login
            create(:auction, :running, :single_bid, :with_bidders)

            get auctions_path, nil, headers

            expect(json_bids).to be_empty
        end

        context 'and the auction is closed' do
          it 'unveils all bids' do
            login
            auction = create(:auction, :closed, :single_bid, :with_bidders)

            get auctions_path, nil, headers

            json_bids.each do |bid|
              expect(bid['bidder_id']).to_not be_nil
              bidder = bid['bidder']
              expect(bidder['id']).to_not be_nil
              expect(bidder['name']).to_not be_nil
              expect(bidder['duns_number']).to_not be_nil
              expect(bidder['github_id']).to_not be_nil
              expect(bidder['created_at']).to_not be_nil
              expect(bidder['updated_at']).to_not be_nil
            end

            expect(json_bids.length).to eq(auction.bids.length)
          end
        end
      end
    end

    def json_bids
      json_auctions.first['bids']
    end

    def json_auctions
      json_response['auctions']
    end
  end
end
