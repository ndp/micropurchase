class CreateAuction
  attr_reader :auction

  def initialize(params, user)
    @params = params
    @user = user
    @auction = Auction.new(attributes)
  end

  private

  attr_reader :params, :user

  def attributes
    parser.attributes
  end

  def parser
    AuctionParser.new(params, user)
  end
end
