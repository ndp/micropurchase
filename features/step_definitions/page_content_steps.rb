Then(/^I should see "(.+)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^I should not see "(.+)"$/) do |text|
  expect(page).to_not have_content(text)
end

Then(/^I should see a message about no auctions$/) do
  expect(page).to have_content(
    "There are no current open auctions on the site. " \
    "Please check back soon to view micropurchase opportunities.")
end

Then(/^I should see a message about no bids$/) do
  expect(page).to have_content("No bids yet.")
end

Then(/^I should see a current bid amount( of \$([\d\.]+))?$/) do |_, amount|
  expect(page).to have_content(/Current bid: \$[\d,\.]+/)
  expect(page).to have_content(amount) unless amount.nil?
end

Then(/^I should see a winning bid amount( of \$([\d\.]+))?$/) do |_, amount|
  expect(page).to have_content(/Winning bid \([^\)]+\): \$[\d,\.]+/)
  expect(page).to have_content(amount) unless amount.nil?
end

Then(/^I should see a link to the auction issue URL$/) do
  page.find("a[href='#{@auction.issue_url}']")
end

Then(/^I should see a confirmation for \$(.+)$/) do |amount|
  expect(page).to have_content("Confirm your bid: $#{amount}")
end

Then(/^I should see a link to give feedback$/) do
  expect(page).to have_link('Feedback')
end

Then(/^I should see an email link to get in touch$/) do
  mailto_link = '//a[@href="mailto:micropurchase@gsa.gov"]'
  expect(page).to have_xpath(mailto_link)
  expect(page).to have_content('micropurchase@gsa.gov')
end

Then(/^I should see a link to the github repository$/) do
  expect(page).to have_link('View Our Code on GitHub')
end

Then(/^I will not see a warning I must be an admin$/) do
  expect(page).to_not have_text('must be an admin')
end
