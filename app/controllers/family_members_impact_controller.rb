class FamilyMembersImpactController < ApplicationController
	def index
		
	end
	def submit_form
		year = params[:date]
		calculate_report(year['start_year'],year['end_year'])
	end
	
	def calculate_report(start_year, end_year)
		@data = []
		end_year = end_year.to_i 
		start_year = start_year.to_i
		diff_year = end_year-start_year
		year_array = [start_year]

		(1..diff_year).each do |i|
			year_array.push(start_year+i)
			end
	
	end_year += 1
	family_members_directely_impacted = Child.by_family_members_directely_impacted.startkey([start_year]).endkey([end_year])['rows']
	
	for year in year_array
		@family_support_edu = 0
		@in_family_knw_nd_under_csa = 0
		@family_stop_blame = 0
		@family_und_imp = 0
		for i in family_members_directely_impacted
				if i['key'][0]!=nil and i['key'][0] == year
					if i['key'][1]!=nil
						if i['key'][1].include? "yes"
							@family_support_edu += 1
						end
					end
				
					if i['key'][2]!=nil
						if i['key'][2].include? "yes"
							@in_family_knw_nd_under_csa += 1
						end
					end
					if i['key'][3]!=nil
						if i['key'][3].include? "yes"
							@family_stop_blame += 1
						end
					end
					if i['key'][4]!=nil
						if i['key'][4].include? "yes"
							@family_und_imp += 1
						end
					end
				end
		end
		
			
			@data.push({
				"year" => year,
				"family_support_edu" => @family_support_edu,
				"in_family_knw_nd_under_csa" => @in_family_knw_nd_under_csa,
				"family_stop_blame" => @family_stop_blame,
				"family_und_imp" => @family_und_imp
			})
			
	end
		render "show_report"		
	end
end




