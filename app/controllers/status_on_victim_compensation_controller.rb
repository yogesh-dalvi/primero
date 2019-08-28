class StatusOnVictimCompensationController < ApplicationController
	
	def index
		
	end
	
	def redirect_to_index
		redirect_to '/all_reports/status_on_victim_compensation'
	end
	
	def submit_form
		start_date = params[:start_date]
		end_date = params[:end_date]
		end_date = (Date.parse(end_date)+1).to_s
		calculate_report(start_date,end_date)
	end
	
	def calculate_report(start_date, end_date)
		@victim_comp = []

		start_year = start_date.split('-')[0]
		end_year = end_date.split('-')[0]

		end_year = end_year.to_i 
		start_year = start_year.to_i
		diff_year = end_year-start_year
		year_array = [start_year]

		(1..diff_year).each do |i|
			year_array.push(start_year+i)
    end
		
		by_victim_comp= Child.by_victim_compensation.startkey([start_date]).endkey([end_date,{}])['rows']
		
			for i in by_victim_comp
				@victim_comp.push({"case_id":i['key'][1],"court":i['key'][2],"client_name":i['key'][3],"grant_date":i['key'][4],"amount":i['key'][5],"final_grant_date":i['key'][6],"final_amount":i['key'][7]})
			end
    render "show_report"
	end
end
