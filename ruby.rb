require 'watir'
require 'json'


h = {
	"accounts" => [{
		"name" => "",
		"balance" => "",
		"currency_code" => "",
		"transactions" => []
	}]
}

input_array = []


class Transaction

	attr_accessor :date, :description, :amount

	def initialize(date, description, amount)
		@date = date
		@description = description
		@amount = amount
	end

end


browser = Watir::Browser.new :chrome
puts "enter url to go... (e.g. da.victoriabank.md)"
website = gets.chomp
#website = "da.victoriabank.md"
browser.goto website


puts "Login:"
user_login = gets.chomp
browser.text_field(name: 'Login').set(user_login)

puts "Password:"
user_pswd = gets.chomp
browser.text_field(name: 'password').set(user_pswd)

puts "Captcha:"
captcha = gets.chomp
browser.text_field(name: 'captchaText').set(captcha)

browser.form(:id, "FORM_FAST_LOGIN").submit; 


h['accounts'][0]['name'] = browser.element(:xpath => "//ul[@class='owwb-cs-slide-list-properties-list']/li[last()]/div[@class='owwb-cs-slide-list-properties-list-property-value']/span").text
h['accounts'][0]['currency_code'] = browser.span(:class => 'owwb-cs-slide-list-amount-currency').text
h['accounts'][0]['balance'] = browser.span(:class => 'owwb-cs-slide-list-amount-value').text

puts h['accounts'][0]['name']
puts h['accounts'][0]['currency_code']
puts h['accounts'][0]['balance']

browser.a(:name => 'main_menu_CP_HISTORY').click


li_list = browser.ul(:class => "owwb-ws-history")
#puts li_list.lis.length
li_list.lis.each do |li|
	date = li.div(:class => "owwb-ws-history-item-date").text
	description = li.element(:xpath => "//div[@class='owwb-ws-history-item-title']/div/a/span[last()]").text
 	amount = li.div(:class => "owwb-ws-history-item-amount").text
 	input_array << [date, description, amount]
end

puts input_array

transactions = []

input_array.each do |k| 
	transactions << Transaction.new(k[0], k[1], k[2])
end

transactions.each do |transaction| 
	h['accounts'][0]['transactions'] << {"date"=>transaction.date,"description"=>transaction.description, "amount"=>transaction.amount}
end


File.open('work/ruby/accounts.json','w') do |f|
	f.write(h.to_json)
end

sleep 320000
browser.close