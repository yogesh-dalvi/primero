class BailApplicationMovedController < ApplicationController
	
	def index
	
	end
	
	def redirect_to_index
		redirect_to '/all_reports/bail_application_moved'
	end
	
	def submit_form
		start_date = params[:start_date]
		end_date = params[:end_date]
		end_date = (Date.parse(end_date)+1).to_s
		calculate_report(start_date,end_date)
	end
	
	def calculate_report(start_date, end_date)
		@data = []

		start_year = start_date.split('-')[0]
		end_year = end_date.split('-')[0]

		end_year = end_year.to_i 
		start_year = start_year.to_i
		diff_year = end_year-start_year
		year_array = [start_year]

		(1..diff_year).each do |i|
			year_array.push(start_year+i)
    end
    
    bail_application_moved = Child.by_bail_application_moved.startkey([start_date]).endkey([end_date,{}])['rows']
		
		for year in year_array
			bail_application_moved_on_behalf_of_name_of_accused = 0
			allowed = 0
			dismissed = 0
			pending = 0
			for i in bail_application_moved
				if i['key'][0].split("-")[0].to_i == year
					for j in i['key'][1]
						if j.has_key?('bail_application_moved_on_behalf_of_name_of_accused')
							bail_application_moved_on_behalf_of_name_of_accused += 1
						end
						if j.has_key?('bail_status_bail_information')
							if j['bail_status_bail_information'].include? "allowed"
								allowed += 1
							elsif j['bail_status_bail_information'].include? "dismissed"
								dismissed += 1
							elsif j['bail_status_bail_information'].include? "pending"
								pending += 1
							end 
						end
					end
				end
			end
			@data.push({
				"year" => year,
				"bail_application_moved_on_behalf_of_name_of_accused" => bail_application_moved_on_behalf_of_name_of_accused, 
				"allowed" => allowed,
				"dismissed" => dismissed,
				"pending" => pending
				})
		end
		render "show_report"
		@start_date = start_date
		@end_date = (Date.parse(end_date)-1).to_s
	end
end
		
