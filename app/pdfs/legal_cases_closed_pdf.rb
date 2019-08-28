class LegalCasesClosedPdf < Prawn::Document
	def initialize(legal_case)
		@legal = legal_case
		case_closed
	end
	
	def case_closed
		move_down 1
		table case_closed_all do
		end
      
	end
	
	def case_closed_all
		[["Case ID","Pseudonyms", "Closing Year", "Stage at the time of closure", "Reasons for closure"]] +
		@legal.map do |close|
			[close["case_id"],close["pseudonyms"], close["year_closure"], close["closure_reason"], close["stage"]]
		end
	end
    
end
       