class MonthlyReportPdf < Prawn::Document
    def initialize(users,data)
        @data=data
        super()
        user_id
    end

    def user_id
        move_down 8
        stroke_horizontal_rule
        pad(4) { text "SPECIAL CELLS FOR WOMEN", size: 15, style: :bold, align: :center }
        stroke_horizontal_rule
        pad(4) {text "CONSOLIDATED MONTHLY PROGRESS REPORT	", size: 15, style: :bold, align: :center }
        stroke_horizontal_rule

        table user_id_all do
            rows(0).width = 75
            row(0).align = :center
            column(0).align = :center
            column(2).align = :center
            row(0).font_style = :bold
            self.row_colors = ["DDDDDD", "FFFFFF"]
            #style(rows(1..-1), :padding => [4, 36, 4, 36])
            #style(row(0), padding: [4,10], :font_style => :bold)
            #style(row(1), padding: [4, 10], :font_style => :bold)
            #style(row(11), padding: [4, 10], :font_style => :bold)
            #style(row(12), padding: [4, 10], :font_style => :bold)
            #style(row(13), padding: [4, 10], :font_style => :bold)
            #style(row(20), padding: [4, 10], :font_style => :bold)
            row(1).font_style = :bold 
            row(11).font_style = :bold
            row(12).font_style = :bold
            row(13).font_style = :bold
            row(16).font_style = :bold
            row(17).font_style = :bold
            row(18).font_style = :bold
            row(19).font_style = :bold
            row(20).font_style = :bold
            row(21).font_style = :bold
            row(22).font_style = :bold
            self.header = true  
        end 
    end

    def user_id_all
        move_down 20
        [ ["Sr. No.","DETAILS", "COUNT"],
        ["1","New Registered applications",@Null],
        ["1.1","Police",@data[0] ],
        ["1.2","Ex-clients",@data[1] ],
        ["1.3","Word of mouth", @data[2]],
        ["1.4","Self (info. through media / poster / internet etc.)	", @data[3]],
        ["1.5","Lawyers/ legal organisations	", @data[4]],
        ["1.6","Non-Govermental Organisation", @data[5]],
        ["1.7","Govermental Organisation", @data[6]],
        ["1.8","Independent Community Worker/ Political worker", @data[7]],
        ["1.9","Any other (for ex. Pvt. Hospitals etc.)", @data[8]],
        ["2","Ongoing intervention (from previous months/not registered in this month)", @data[23]],
        ["3","One Time Intervention", @data[9]],
        ["4","Home visits/Outreach details	", @Null],
        ["4.1","Home visits	",@data[10]],
        ["4.2","Collateral visits", @data[11]],
        ["5","Individual meeting/sessions", @data[12]],
        ["6","Group meetings and sessions (Joint meeting)", @data[13]],
        ["7","Engaging police help", @data[24]],
        ["8","Participation in workshops/conferences/ programmes/seminars/ meetings", @data[14]],
        ["9","Programmes organised", @data[15]],
        ["10","Conducted or facilitated a session or programme as a resource person", @data[16]],
        ["11","Referred to:	", @Null],
        ["11.1","Police", @data[17]],
        ["11.2","Medical", @data[18]],
        ["11.3","Shelter", @data[19]],
        ["11.4","Legal services	", @data[20]],
        ["11.5","Protection officer	", @data[21]],
        ["11.6","NGO/CBO/Any other/Zila lok shiyakat niwaran karyalya/Govt. Offices	", @data[22]]]
    end
end
