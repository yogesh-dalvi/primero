class StatusOnFinancialNeedsController < ApplicationController
	def index
		@by_status= Child.all['total_rows']
	end
	
	def generate_pdf
    respond_to do |format|
      format.html
      format.pdf do
        pdf = StatusOnFinancialNeedsPdf.new(@users,params[:data])
        send_data pdf.render, filename: 'report.pdf', type: 'application/pdf',disposition: "inline"
      end
    end
  end
  
end
