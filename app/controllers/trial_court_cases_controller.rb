class TrialCourtCasesController < ApplicationController
	def index
		
	end
	
	def submit_form
		start_date = params[:start_date]
		end_date = params[:end_date]
		end_date = (Date.parse(end_date)+1).to_s
		calculate_report(start_date,end_date)
	end
	
	def redirect_to_index
		redirect_to '/all_reports/trial_court_cases'
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
    
    trial_court_cases = Child.by_trial_court_cases.startkey([start_date]).endkey([end_date,{}])['rows']
		for year in year_array
			@legal_cases = 0
			@closed_cases = 0
			for i in trial_court_cases
				if i['key'][0]!=nil
					if i['key'][0].split("-")[0].to_i == year
						if i['key'][1][0]!=nil
							if i['key'][1][0].include? "legal"
								@legal_cases += 1
							end
						end
						if i['key'][1][0]!=nil	
							if i['key'][1][0].include? "legal" and i['key'][1][1].include? "closed"
								@closed_cases += 1
							end
						end
					end
				end	
			end
			@remaining = @legal_cases - @closed_cases
			
			@data.push({
				"year" => year,
				"legal_cases" => @legal_cases,
				"closed_cases" => @closed_cases,
				"remaining" => @remaining
			})
				
		end
		render "show_report"
	end
end
