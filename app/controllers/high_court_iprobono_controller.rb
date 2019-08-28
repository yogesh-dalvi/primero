class HighCourtIprobonoController < ApplicationController
	def index
		
	end
	
	def redirect_to_index
		redirect_to '/all_reports/high_court_iprobono'
	end
	
	def submit_form
		start_date = params[:start_date]
		end_date = params[:end_date]
		end_date = (Date.parse(end_date)+1).to_s
		calculate_report(start_date,end_date)
	end
	
	def calculate_report(start_date, end_date)
		@high_court = []

		start_year = start_date.split('-')[0]
		end_year = end_date.split('-')[0]

		end_year = end_year.to_i 
		start_year = start_year.to_i
		diff_year = end_year-start_year
		year_array = [start_year]

		(1..diff_year).each do |i|
			year_array.push(start_year+i)
    end
    
    high_court_iprobono= Child.high_court_iprobono.startkey([start_date]).endkey([end_date,{}])['rows']
		for i in high_court_iprobono
			@high_court.push({"case_id":i['key'][1],"name":i['key'][2],"purpose":i['key'][3],"groundreasons":i['key'][4],"court":i['key'][5],"case_number":i['key'][6],"case_title":i['key'][7],"case_is_handled_by":i['key'][8],"date_of_filing":i['key'][9],"date_of_disposal":i['key'][10],"outcome":i['key'][11],"child_status":i['key'][12]})
		end
		@start_date = start_date
		@end_date = (Date.parse(end_date)-1).to_s
		render "show_report"
	end
end

