class CasesWhereIdentifiedController < ApplicationController
	
	def index
		cases_where_identi_res_not_met = Child.by_cases_where_identi_res_not_met['rows']
		type_of_reasons=['child turned hostile','family is untraceable','police io filed closure report in jjb']
		@temp=[]
		for j in type_of_reasons
			@emotional_psychological_count=0
			@shelterprotection_needs_count=0
			@educational_vocational_count=0
			@financial_needs_count=0
			@paralegal_needs_count=0
			@familial_needs_count=0
			
			for i in cases_where_identi_res_not_met
				if !i['key'].empty?
					if j.match(i['key'])
						unless i['value'].empty?
							for z in i['value']
							
								@emotional_psychological_count += 1
							
							
						
								@shelterprotection_needs_count += 1
								
								@educational_vocational_count += 1
								
								@financial_needs_count += 1
								
								@paralegal_needs_count += 1
								
								@familial_needs_count += 1
													
							end
						end
					end
				end
			end
			@temp.push(
				{
					"type_of_reason": j,
					"values":{
						"emotional_psychological_count": @emotional_psychological_count,
						"shelterprotection_needs_count": @shelterprotection_needs_count,
						"educational_vocational_count": @educational_vocational_count,
						"financial_needs_count": @financial_needs_count,
						"paralegal_needs_count": @paralegal_needs_count,
						"familial_needs_count": @familial_needs_count
					}
				})
		end	
		puts @temp
	end
end











