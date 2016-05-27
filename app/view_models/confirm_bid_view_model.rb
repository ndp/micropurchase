class ConfirmBidViewModel
  attr_reader :auction, :bid

  def initialize(auction:, bid:)
    @auction = auction
    @bid = bid
  end

  def auction_id
    auction.id
  end

  def bid_amount
    bid.amount
  end

  def title
    auction.title
  end

  def time_left_partial
    if available?
      'bids/distance_of_time'
    else
      'components/null'
    end
  end

  def html_description
    return '' if auction.description.blank?
    MarkdownRender.new(auction.description).to_s
  end

  def distance_of_time
    "#{HumanTime.new(time: auction.ended_at).distance_of_time} left"
  end

  private

  def available?
    AuctionStatus.new(auction).available?
  end
end