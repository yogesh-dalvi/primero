class CasesClosedByLawyersController < ApplicationController
	
	def index
		
	end
	
	def redirect_to_index
		redirect_to '/all_reports/cases_closed_by_lawyers'
	end
	
	def submit_form
		start_date = params[:start_date]
		end_date = params[:end_date]
		end_date = (Date.parse(end_date)+1).to_s
		calculate_report(start_date,end_date)
	end
	
	def calculate_report(start_date, end_date)
		@cases_closed = []

		start_year = start_date.split('-')[0]
		end_year = end_date.split('-')[0]

		end_year = end_year.to_i 
		start_year = start_year.to_i
		diff_year = end_year-start_year
		year_array = [start_year]

		(1..diff_year).each do |i|
			year_array.push(start_year+i)
    end
		
		by_lawyer_case_closed = Child.by_lawyer_case_closed.startkey([start_date]).endkey([end_date,{}])['rows']
		
		for i in by_lawyer_case_closed
			@cases_closed.push({"case_id":i['key'][1],"first_name":i['key'][2],"case_title":i['key'][3],"stage":i['key'][4],"closure_reason":i['key'][5]})
		end
    render "show_report"
    @start_date = start_date
    @end_date = (Date.parse(end_date)-1).to_s
	end
end
