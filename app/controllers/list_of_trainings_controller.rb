class ListOfTrainingsController < ApplicationController
	def index
		
	end
	
	def redirect_to_index
		redirect_to '/all_reports/list_of_trainings'
	end
	
	def submit_form
		start_date = params[:start_date]
		end_date = params[:end_date]
		end_date = (Date.parse(end_date)+1).to_s
		calculate_report(start_date,end_date)
	end
	
	def calculate_report(start_date, end_date)
		@training_list = []

		start_year = start_date.split('-')[0]
		end_year = end_date.split('-')[0]

		end_year = end_year.to_i 
		start_year = start_year.to_i
		diff_year = end_year-start_year
		year_array = [start_year]

		(1..diff_year).each do |i|
			year_array.push(start_year+i)
    end
    
    list_of_training= Child.list_of_training.startkey([start_date]).endkey([end_date,{}])['rows']
		
		for i in list_of_training
			@training_list.push({"date_of_training":i['key'][1],"facilitated_by":i['key'][2],"organised":i['key'][3],"description":i['key'][4],"number_of_participants":i['key'][5]})
		end
		@start_date = start_date
		@end_date = (Date.parse(end_date)-1).to_s
    render "show_report"
	end
end
