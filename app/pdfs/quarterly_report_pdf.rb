class QuarterlyReportPdf < Prawn::Document
    def initialize(users,data)
        @data=data
        super()
        user_id
    end

    def user_id
        move_down 4
        pad(4) { text "Location : "+@data[122], align: :left }
        if @data[123]!=""
            pad(4) { text "Cell : "+@data[123], align: :left }
        end
        pad(4) { text "From Date : "+@data[124], align: :left }
        pad(4) { text "To Date : "+@data[125], align: :left }
        move_down 10
        stroke_horizontal_rule
        pad(4) { text "SPECIAL CELLS FOR WOMEN", size: 15, style: :bold, align: :center }
        stroke_horizontal_rule
        pad(4) {text "QUARTERLY PROGRESS REPORT", size: 15, style: :bold, align: :center }
        stroke_horizontal_rule

        table user_id_all do

            rows(0).width = 72
            self.row_colors = ["DDDDDD", "FFFFFF"]
            row(0).font_style = :bold
            row(4).font_style = :bold
            column(0).align = :center
            column(2).align = :center
            #style(rows(1..-1), :padding => [6, 25, 5, 25], :borders => [])
            style(row(1), padding: [7, 10], :font_style => :bold)
            style(row(5), padding: [7, 35])
            style(row(6), padding: [7, 10], :font_style => :bold)
            style(row(17), padding: [7, 10], :font_style => :bold)
            style(row(23), padding: [7, 10], :font_style => :bold)
            style(row(32), padding: [7, 10], :font_style => :bold)
            style(row(42), padding: [7, 10], :font_style => :bold)
            style(row(70), padding: [7, 10], :font_style => :bold)
            self.header = true  
        end 
        second_table
    end

    def user_id_all
        move_down 40
        [ ["Sr. No.","Client Profile & Details" , "Count"],["1","Total clients with whom there was interaction",@null],["1.1","Number of applications registered in this quarter only",@data[0]],["1.2","Ongoing clients (applications registered before this quarter, but interventions are continuing in this quarter",@data[1]],
        ["1.3","One­ time intervention in this quarter",@null],[@null,"Number of people provided support by the cell without having registered application.",@data[2]],
        ["2","Clients (applications registered in this quarter only) referred by",@null],[@null,"Ex­clients",@data[3]],[@null,"Self (info. through media / poster / internet etc )",@data[4]],[@null,"Police",@data[5]],[@null,"NGO",@data[6]],[@null,"Community based organizations ( TMGS / SHG / Mahila Mandal etc.)",@data[7]],[@null,"Independent community worker/ Political worker",@data[8]],[@null,'Word of mouth',@data[9]],[@null,'GO (WCD/ MAVIM/ ICDS/ Asha worker etc)',@data[10]],[@null,'Lawyers/ legal organisations',@data[11]],[@null,'Any other (please specify)',@data[12]],["3","Gender of the complainants/ clients",@null],[@null,"Adults (female)",@data[13]],[@null,"Adults (male)",@data[14]],[@null,"Children (female )",@data[15]],[@null,"Children (male)",@data[16]],[@null,"Third gender/ others",@data[17]],["4","Age of the clients",@null],[@null,"Less than 14 years",@data[18]],[@null,"15 – 17 years",@data[19]],[@null,"18 – 24 years",@data[20]],[@null,"25 – 34 years",@data[21]],[@null,"35 – 44 years",@data[22]],[@null,"45 – 54 years",@data[23]],[@null,"Above 55 Years",@data[24]],[@null,"Information not available",@data[25]],["5","Education of the clients ",@null],[@null,"Non­ Literate",@data[26]],[@null,"Functional literacy",@data[27]],[@null,"Primary level (class 4)",@data[28]],[@null,"Upto SSC",@data[29]],[@null,"Upto HSC",@data[30]],[@null,"Graduation",@data[31]],[@null,"Post Graduation/ Higher studies",@data[32]],[@null,"Any other (please specify)",@data[33]],[@null,"Information not available",@data[34]],["6","Reasons for registering at the Special Cell",@null],[@null,"Physical violence by husband",@data[35]],[@null,"Emotional / mental violence by husband",@data[36]],[@null,"Sexual violence by husband",@data[37]],[@null,"Financial violence by husband",@data[38]],[@null,"Out of marriage relationship/second marriage by husband",@data[39]],[@null,"Refusal to give streedhan",@data[40]],[@null,"Alcohol abuse/ substance abuse by husband",@data[41]],[@null,"Desertion by husband",@data[42]],[@null,"Child custody disputes/ disputes over visitation rights",@data[43]],[@null,"Physical violence by marital family",@data[44]],[@null,"Emotional/ mental violence by marital family",@data[45]],[@null,"Sexual violence by marital family",@data[46]],[@null,"Financial violence by marital family",@data[47]],[@null,"Harassment of natal family members of the woman by the husband/family",@data[48]],[@null,"Deprivation of matrimonial residence",@data[49]],[@null,"Child­battering (by husband/family)",@data[50]],[@null,"Dowry demands (by husband/family)",@data[51]],[@null,"Harassment by natal family",@data[52]],[@null,"Harassment by children and their spouses",@data[53]],[@null,"Wife has left the matrimonial home (male clients)",@data[54]],[@null,"Harassment at work",@data[55]],[@null,"Harassment by live­in partner",@data[56]],[@null,"Sexual assault",@data[57]],[@null,"Sexual harassment in other situation",@data[58]],[@null,"Breach of trust in intimate relationship",@data[59]],[@null,"Harassment by neighbours",@data[60]],[@null,"Any other (please specify)",@data[61]],["7","Previous intervention before coming to the Cell",@null],[@null,"Natal family/ marital family",@data[62]],[@null,"Police",@data[63]],[@null,"Court / lawyers",@data[64]],[@null,"NGOs",@data[65]],[@null,"Panchyat members/Jati Panchyat",@data[66]],[@null,"Any other(please specify)",@data[67]]] 
    end

    def second_table
        table second_table_all do
            rows(0).width = 72
            self.row_colors = ["DDDDDD", "FFFFFF"]
            row(0).font_style = :bold
            style(rows(1..-1), :padding => [6, 10, 6, 10])
            style(row(1), padding: [7, 20], :font_style => :bold)
            style(row(11), padding: [7, 20], :font_style => :bold)
            style(row(19), padding: [7, 20], :font_style => :bold)
            style(row(26), padding: [7, 20], :font_style => :bold)
            self.header = true  
        end
    end

    def second_table_all
            move_down 40
            [["Sr. No.","Client Profile & Details","New Clients","Ongoing Clients"],["8","Intervention by the Special Cell (multiple response)",@null,@null],[@null,"Providing emotional support and strengthening psychological self",@data[68],@data[69]],[@null,"Negotiating non­violence with stakeholder",@data[70],@data[71]],[@null,"Building support system",@data[72],@data[73]],[@null,"Enlisting police help or intervention",@data[74],@data[75]],[@null,"Legal aid/ legal referral/ pre­litigation counselling",@data[76],@data[77]],[@null,"Working with men in the interest of violated woman",@data[78],@data[79]],[@null,"Advocacy for financial entitlements",@data[80],@data[81]],[@null,"Referral for shelter/ other services",@data[82],@data[83]],[@null,"Developmental counselling",@data[84],@data[85]],["9","Referrals (multiple response)",@null,@null],[@null,"Police",@data[86],@data[87]],[@null,"Court/DLSA",@data[88],@data[89]],[@null,"Shelter home",@data[90],@data[91]],[@null,"Medical",@data[92],@data[93]],[@null,"Lawyer",@data[94],@data[95]],[@null,"Protection Officer",@data[96],@data[97]],[@null,"Any other (specify):­ for work & school",@data[98],@data[99]],["10","Other interventions in the community","","Count"],[@null,"Home visits","",@data[100]],[@null,"Visits to institutions (hospitals/ shelter homes etc.)","",@data[101]],[@null,"Community education programmes","",@data[102]],[@null,"Meetings with local groups/social organisations etc","",@data[103]],[@null,"Interaction with police","",@data[104]],[@null,"Any other (specify) :­ organizations","",@data[105]],["11","Outcomes(multiple response)",@null,@null],[@null,"Helped in case filed for divorce/ separation/mutual divorce",@data[106],@data[107]],[@null,"Streedhan retrieval",@data[108],@data[109]],[@null,"Case filed under PWDVA 2005",@data[110],@data[111]],[@null,"Case filed under 498A",@data[112],@data[113]],[@null,"One – time maintenance/ other financial entitlements",@data[114],@data[115]],[@null,"Non­violent reconciliation",@data[116],@data[117]],[@null,"Court orders in the best interest of the woman",@data[118],@data[119]],[@null,"Any other (specify) : Assurance paper in stalking case from respondent",@data[120],@data[121]]]
    end
end
