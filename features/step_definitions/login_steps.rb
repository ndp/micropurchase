When(/^I sign in$/) do
  step "I visit the home page"
  within(".header-account") do
    click_on "Login"
  end
  click_on "Authorize with GitHub"
end

Given(/^I am signed in$/) do
  step("I sign in")
end

Given(/^I am an authenticated vendor$/) do
  step("I am a user with a verified SAM account")
  step("I sign in")
end

When(/^I sign in and verify my account information/) do
  step "I sign in"
  step "I visit my profile page"
  click_on "Submit"
end
