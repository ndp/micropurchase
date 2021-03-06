class Admin::EditAuctionViewModel
  attr_reader :auction

  def initialize(auction)
    @auction = auction
  end

  def record
    auction
  end

  def new_record?
    false
  end

  def date_default(field)
    dc_time(field).to_date
  end

  def hour_default(field)
    dc_time(field).strftime('%l').strip
  end

  def minute_default(field)
    dc_time(field).strftime('%M').strip
  end

  def meridiem_default(field)
    dc_time(field).strftime('%p').strip
  end

  private

  def dc_time(field)
    DcTimePresenter.convert(field_value(field))
  end

  def field_value(field)
    auction.send("#{field}_at") || default_date_time
  end

  def default_date_time
    @_default_date_time ||= DefaultDateTime.new.convert
  end
end
