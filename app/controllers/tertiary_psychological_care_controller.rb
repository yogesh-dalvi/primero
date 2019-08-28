class TertiaryPsychologicalCareController < ApplicationController
	def index
		
	end

	def submit_form
		start_date = params[:start_date]
		end_date = params[:end_date]
		end_date = (Date.parse(end_date)+1).to_s
		calculate_report(start_date,end_date)
	end
	
	def redirect_to_index
		redirect_to '/all_reports/tertiary_psychological_care'
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
		
		tertiary_psychological_care_data = Child.by_tertiary_psychological_care.startkey([start_date]).endkey([end_date,{}])['rows']
		
		for year in year_array
			@tertiary_psycho_needs = 0
			@intervention_prov = 0
			@total_case = 0
			for i in tertiary_psychological_care_data
				if i['key'][0]!=nil
					if i['key'][0].split("-")[0].to_i == year
						@total_case += 1
						if i['key'][1]!=nil
							if i['key'][1].include? "yes"
								@tertiary_psycho_needs += 1
							end
						end
					
						if i['key'][2]!=nil
							if i['key'][2].include? "yes"
								@intervention_prov += 1
							end
						end
					end
				end
			end

			@data.push({
				"year" => year,
				"total_case" => @total_case,
				"tertiary_psycho_needs" => @tertiary_psycho_needs,
				"intervention_prov" => @intervention_prov
			})			
		end
		@start_date = start_date
		@end_date = (Date.parse(end_date)-1).to_s
		render "show_report"
	end
end

