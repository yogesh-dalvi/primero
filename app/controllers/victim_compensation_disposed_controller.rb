class VictimCompensationDisposedController < ApplicationController
	def index
		
	end
	
	def submit_form
		start_date = params[:start_date]
		end_date = params[:end_date]
		end_date = (Date.parse(end_date)+1).to_s
		calculate_report(start_date,end_date)
	end
	
	def redirect_to_index
		redirect_to '/all_reports/victim_compensation_disposed'
	end

	def calculate_report(start_date, end_date)
		@victim_comp_dis = []

		start_year = start_date.split('-')[0]
		end_year = end_date.split('-')[0]

		end_year = end_year.to_i 
		start_year = start_year.to_i
		diff_year = end_year-start_year
		year_array = [start_year]

		(1..diff_year).each do |i|
			year_array.push(start_year+i)
    end
		
		victim_compensation_disposed = Child.by_victim_compensation_disposed.startkey([start_date]).endkey([end_date,{}])['rows']
		
		for i in victim_compensation_disposed
			@victim_comp_dis.push({"case_id":i['key'][1],"court":i['key'][2],"pseudonym":i['key'][3],"vc":i['key'][4]})
		end
    @start_date = start_date
		@end_date = (Date.parse(end_date)-1).to_s
		render "show_report"
	end
end
