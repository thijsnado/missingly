Given(/^the following class definition:$/) do |evaled_code|
  eval evaled_code
end

When(/^I create a new instance of "(.*?)"$/) do |class_name|
  @instance = eval "#{class_name}.new"
end

When(/^I call respond_to\? with "(.*?)" on that instance$/) do |method_name|
  @result = @instance.respond_to?(method_name)
end

Then(/^I should get (true|false)$/) do |boolean|
  if boolean == "true"
    @result.should be_true
  else
    @result.should be_false
  end
end

