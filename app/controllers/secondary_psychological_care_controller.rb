class SecondaryPsychologicalCareController < ApplicationController
	def index
		
	end

	def submit_form
		start_date = params[:start_date]
		end_date = params[:end_date]
		end_date = (Date.parse(end_date)+1).to_s
		calculate_report(start_date,end_date)
	end
	
	def redirect_to_index
		redirect_to '/all_reports/secondary_psychological_care'
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
	
		secondary_psychological_care_data = Child.by_secondary_psychological_care.startkey([start_date]).endkey([end_date,{}])['rows']
		
		for year in year_array
			@secondary_psycho_needs = 0
			@in_house = 0
			@total_case = 0
			for i in secondary_psychological_care_data
				if i['key'][0]!=nil
					if i['key'][0].split("-")[0].to_i == year
						@total_case += 1
						if i['key'][1]!=nil
							if i['key'][1].include? "yes"
								@secondary_psycho_needs += 1
							end
						end
					
						if i['key'][2]!=nil
							if i['key'][2].include? "yes"
								@in_house += 1
							end
						end
					end
				end
			end
			@total_count = @secondary_psycho_needs + @in_house

			@data.push({
				"year" => year,
				"total_case" => @total_case,
				"secondary_psycho_needs" => @secondary_psycho_needs,
				"in_house" => @in_house,
				"total_count" => @total_count
			})
		end
		
		@start_date = start_date
		@end_date = (Date.parse(end_date)-1).to_s
		render "show_report"
	end
end
