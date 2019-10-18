class MonthlyReportsController < ApplicationController

  def initialize
    super()
    
    @location_array = ::LOCATION_ARRAY
    @maha_location_array = ::MAHARASHTRA
    @delh_location_array = DELHI
    @ncw_location_array = NCW
    @cell_map_array = CELL_MAP_ARRAY
    @location_map_array = LOCATION_MAP_ARRAY
    @mpr_data = []
    @month_array = MONTH_ARRAY
  end
    

  def index
    authorize! :index, Child 
    set_end_date_empty=false
    set_start_date_empty=false
    set_state_empty=false
    @location_not_selected = false
    @start_date_not_selected = false
    @end_date_not_selected = false
    @date_validation = false
    @location_not_selected = params[:state_not_selected].to_s
    @start_date_not_selected = params[:start_date_not_selected].to_s
    @end_date_not_selected = params[:end_date_not_selected].to_s
    @date_validation = params[:x].to_s
    @start_date_for_display = params[:s_d].to_s
    @end_date_for_display = params[:e_d].to_s
  end

  def submit_form
    state = params[:location]
    district = params[:district]
    cell = params[:cell]
    start_date = ""
    end_date = ""

    selected_month = params[:month_select].to_s.to_i
    selected_year = params[:date]['year'].to_s.to_i
    
    if selected_month != nil
      start_date = Date.new(selected_year, selected_month, 1)
      end_date = Date.new(selected_year, selected_month, -1)
      start_date = start_date.to_s
      end_date = end_date.to_s
    end

    if !state.empty? && !start_date.empty? && !end_date.empty?
      end_date_in_date=Date.parse(end_date)
      start_date_in_date=Date.parse(start_date)
      end_date = (end_date_in_date+1).to_s
      if start_date_in_date <= end_date_in_date
        redirect_to action: "show_mpr",state: state, district: district, cell: cell, start_date: start_date, end_date: end_date
      end
    end

    if state.empty? 
      set_location_empty=true
    end
    if start_date.empty? 
      set_start_date_empty=true
    end
    if end_date.empty? 
      set_end_date_empty=true
    end
    if !start_date.empty? && !end_date.empty?
      start_date_in_date=Date.parse(start_date)
      end_date_in_date=Date.parse(end_date)
      if start_date_in_date > end_date_in_date
        set_start_date_greater_than_end_date=true
      end
    end    
    if set_location_empty == true || set_start_date_empty==true || set_end_date_empty==true || set_start_date_greater_than_end_date==true
      redirect_to action: "index", location_not_selected: set_location_empty, start_date_not_selected: set_start_date_empty, end_date_not_selected:set_end_date_empty, x:set_start_date_greater_than_end_date,s_d: start_date, e_d: end_date
    end
  end
    

  def show_mpr
    @data=[]
    @new_mpr_data=[]
    selected_state = params[:state]
    selected_district =params[:district]
    selected_cell = params[:cell]
    start_date = params[:start_date]
    end_date = params[:end_date]
    @selected = ''

    @selected_state= selected_state
    @selected_district= selected_district
    @selected_cell= selected_cell

    @district_to_show_in_view = @location_map_array[@selected_state.to_sym]

    # check if district is selected or not i.e whether it is nil or blank
    if @selected_district!=nil
      if !@selected_district.include? ""
        
        if @selected_district.length > 1
          # if more than 1 district selected
          @selected = "multi_district_selected"
          check_key_present selected_state, @selected_district, start_date, end_date, "", @selected 
        else
          @cell_to_show_in_view = @cell_map_array[@selected_district[0].to_sym]
          # if only 1 district is selected
          # check if cell is selected or not i.e whether it is nil or blank
          if @selected_cell!=nil 
            if !@selected_cell.include? ""

              @selected = "inner_cell_selected"
              check_key_present selected_state, @selected_cell, start_date, end_date, selected_district[0], @selected
            else
              @selected = "single_district_selected"
              check_key_present selected_state, @selected_district, start_date, end_date, "", @selected
            end
          else
            @selected = "single_district_selected"
            check_key_present selected_state, @selected_district, start_date, end_date, "", @selected
          end
        end  
      else
        @selected = "state_selected"
        calculate_mpr selected_state, "", start_date, end_date, "",@selected
      end
    else
      @selected = "state_selected"
      calculate_mpr selected_state, "", start_date, end_date, "",@selected
    end  
    
    district_array=[]
    district_gt_1_array=[]
    dist_count_gt_1 = false
    if !@mpr_data.empty?
      for i in @mpr_data
        if i['district']!= ""
          district_array.push(i['district'])
        end
      end
      district_array = district_array.uniq

      if district_array.length > 0
        for i in district_array
          district_count=0
          for j in @mpr_data
            if i == j['district']
              district_count += 1 
            end
          end
          if district_count > 1
            dist_count_gt_1 = true
            district_gt_1_array.push(i)
          end
        end 
      end
    end
   
    dist_not_gt_1_array = district_gt_1_array - district_array | district_array - district_gt_1_array
    
    if district_gt_1_array.length > 0
      if dist_not_gt_1_array.length > 0
        for i in dist_not_gt_1_array
          for j in @mpr_data
            if j['district']== i
              j['cell']=''
              @new_mpr_data.push(j)
            end
          end
        end
      end

      for i in district_gt_1_array
        for j in @mpr_data
          if j['district']== i
            if @new_mpr_data.empty? or !@new_mpr_data.any? {|h| h['district'] == i}
              @new_mpr_data.push({
                'state' => j['state'],
                'district' => j['district'],
                'cell' => '',
                'new_registered_application_that_was_previously_one_time_intervention' => j['new_registered_application_that_was_previously_one_time_intervention'],
                'engaing_police_help_count' => j['engaing_police_help_count'],
                'new_reg_app_total' => j['new_reg_app_total'],
                'new_reg_app_dat_were_prev_one_time_intervention' => j['new_reg_app_dat_were_prev_one_time_intervention'],
                'on_going_intevention_count' => j['on_going_intevention_count'],
                'ex_clients_word_of_mouth_count' => j['ex_clients_word_of_mouth_count'],
                'medical_healthcare_referred_by_count' => j['medical_healthcare_referred_by_count'],
                'protection_officer_clients_referred_by' => j['protection_officer_clients_referred_by'],
                'telephonic_helpline_clients_referred_by' => j['telephonic_helpline_clients_referred_by'],
                'referred_to_us_as_a_service_under_pwdv_2005' => j['referred_to_us_as_a_service_under_pwdv_2005'],
                'cases_where_police_took_help_from_social_worker' => j['cases_where_police_took_help_from_social_worker'],
                'individual_meeting_count_total_count' => j['individual_meeting_count_total_count'],
                'individual_meeting_with_survivor_count' => j['individual_meeting_with_survivor_count'],
                'individual_meeting_other_than_survivor_count' => j['individual_meeting_other_than_survivor_count'],
                'ngo_and_cbo_referred_to' => j['ngo_and_cbo_referred_to'],
                'other_gov_org_services_referred_to' => j['other_gov_org_services_referred_to'],
                'exclients_count' => j['exclients_count'],
                'self_count' => j['self_count'],
                'police_count' => j['police_count'],
                'ngo_count' => j['ngo_count'],
                'community_based_org_count' => j['community_based_org_count'],
                'icw_pw_count' => j['icw_pw_count'],
                'word_of_mouth_count' => j['word_of_mouth_count'],
                'go_count' => j['go_count'],
                'lawyers_legal_org_count' => j['lawyers_legal_org_count'],
                'any_other_count' => j['any_other_count'],
                'individual_meeting_count' => j['individual_meeting_count'],
                'group_meeting_count' => j['group_meeting_count'],
                'police_reffered_to_count' => j['police_reffered_to_count'],
                'medical_count' => j['medical_count'],
                'shelter_count' => j['shelter_count'],
                'legal_services_count' => j['legal_services_count'],
                'protection_officer_count' => j['protection_officer_count'],
                'lok_shiyakat_niwaran_count' => j['lok_shiyakat_niwaran_count'],
                'one_time_intervention_count' => j['one_time_intervention_count'],
                'home_visit_count' => j['home_visit_count'],
                'collateral_visits_count' => j['collateral_visits_count'],
                'participation_count' => j['participation_count'],
                'conducted_session_or_prog_count' => j['conducted_session_or_prog_count'],
                'programs_organised_count' => j['programs_organised_count'],
                'referred_by_total_count' => j['referred_by_total_count'],
                'home_visit_outreach_detail' => j['home_visit_outreach_detail'],
                'individual_meeting_session' => j['individual_meeting_session'],
                'on_going_cases_from_prev_month_count' => j['on_going_cases_from_prev_month_count'],
                'cases_sent_back_to_eo' => j['cases_sent_back_to_eo'],
                'non_violent_reconcilation' => j['non_violent_reconcilation'],
                'sent_back_to_eo_fr_legal_action' => j['sent_back_to_eo_fr_legal_action'],
                'sent_back_to_eo_for_dv_act' => j['sent_back_to_eo_for_dv_act'],
                'sent_back_to_eo_for_mediation' => j['sent_back_to_eo_for_mediation'],
                'any_other_intervention_outcomes' => j['any_other_intervention_outcomes'],
                'reffered_to' => j['reffered_to']

                    })
          
            else
              for k in @new_mpr_data
                if k['district'] == i
                  k['new_registered_application_that_was_previously_one_time_intervention'] += j['new_registered_application_that_was_previously_one_time_intervention']
                  k['engaing_police_help_count'] += j['engaing_police_help_count']
                  k['new_reg_app_total'] += j['new_reg_app_total']
                  k['new_reg_app_dat_were_prev_one_time_intervention'] += j['new_reg_app_dat_were_prev_one_time_intervention']
                  k['on_going_intevention_count'] += j['on_going_intevention_count']
                  k['ex_clients_word_of_mouth_count'] += j['ex_clients_word_of_mouth_count']
                  k['medical_healthcare_referred_by_count'] += j['medical_healthcare_referred_by_count']
                  k['protection_officer_clients_referred_by'] += j['protection_officer_clients_referred_by']
                  k['telephonic_helpline_clients_referred_by'] += j['telephonic_helpline_clients_referred_by']
                  k['referred_to_us_as_a_service_under_pwdv_2005'] += j['referred_to_us_as_a_service_under_pwdv_2005']
                  k['cases_where_police_took_help_from_social_worker'] += j['cases_where_police_took_help_from_social_worker']
                  k['individual_meeting_count_total_count'] += j['individual_meeting_count_total_count']
                  k['individual_meeting_with_survivor_count'] += j['individual_meeting_with_survivor_count']
                  k['individual_meeting_other_than_survivor_count'] += j['individual_meeting_other_than_survivor_count']
                  k['ngo_and_cbo_referred_to'] += j['ngo_and_cbo_referred_to']
                  k['other_gov_org_services_referred_to'] += j['other_gov_org_services_referred_to']
                  k['exclients_count'] += j['exclients_count']
                  k['self_count'] += j['self_count']
                  k['police_count'] += j['police_count']
                  k['ngo_count'] += j['ngo_count']
                  k['community_based_org_count'] += j['community_based_org_count']
                  k['icw_pw_count'] += j['icw_pw_count']
                  k['word_of_mouth_count'] += j['word_of_mouth_count']
                  k['go_count'] += j['go_count']
                  k['lawyers_legal_org_count'] += j['lawyers_legal_org_count']
                  k['any_other_count'] += j['any_other_count']
                  k['individual_meeting_count'] += j['individual_meeting_count']
                  k['group_meeting_count'] += j['group_meeting_count']
                  k['police_reffered_to_count'] += j['police_reffered_to_count']
                  k['medical_count'] += j['medical_count']
                  k['shelter_count'] += j['shelter_count']
                  k['legal_services_count'] += j['legal_services_count']
                  k['protection_officer_count'] += j['protection_officer_count']
                  k['lok_shiyakat_niwaran_count'] += j['lok_shiyakat_niwaran_count']
                  k['one_time_intervention_count'] += j['one_time_intervention_count']
                  k['home_visit_count'] += j['home_visit_count']
                  k['collateral_visits_count'] += j['collateral_visits_count']
                  k['participation_count'] += j['participation_count']
                  k['conducted_session_or_prog_count'] += j['conducted_session_or_prog_count']
                  k['programs_organised_count'] += j['programs_organised_count']
                  k['referred_by_total_count'] += j['referred_by_total_count']
                  k['home_visit_outreach_detail'] += j['home_visit_outreach_detail']
                  k['individual_meeting_session'] += j['individual_meeting_session']
                  k['on_going_cases_from_prev_month_count'] += j['on_going_cases_from_prev_month_count']
                  k['cases_sent_back_to_eo'] += j['cases_sent_back_to_eo']
                  k['non_violent_reconcilation'] += j['non_violent_reconcilation']
                  k['sent_back_to_eo_fr_legal_action'] += j['sent_back_to_eo_fr_legal_action']
                  k['sent_back_to_eo_for_dv_act'] += j['sent_back_to_eo_for_dv_act']
                  k['sent_back_to_eo_for_mediation'] += j['sent_back_to_eo_for_mediation']
                  k['any_other_intervention_outcomes'] += j['any_other_intervention_outcomes']
                  k['reffered_to'] += j['reffered_to']

                end
              end 
            end
          end
        end
      end
      @mpr_data = @new_mpr_data
    end  

    if !@mpr_data.empty?
      if @selected == "multi_district_selected" or (@selected == "inner_cell_selected" and @selected_cell.length > 1)
        @mpr_data.push({
          'state' => j['state'],
          'district' => 'Total',
          'cell' => '',
          'new_registered_application_that_was_previously_one_time_intervention' => 0,
          'new_reg_app_total' => 0,
          'new_reg_app_dat_were_prev_one_time_intervention' => 0,
          'engaing_police_help_count' => 0,
          'on_going_intevention_count' => 0,
          'ex_clients_word_of_mouth_count' => 0,
          'medical_healthcare_referred_by_count' => 0,
          'protection_officer_clients_referred_by' => 0,
          'telephonic_helpline_clients_referred_by' => 0,
          'referred_to_us_as_a_service_under_pwdv_2005' => 0,
          'cases_where_police_took_help_from_social_worker' => 0,
          'individual_meeting_count_total_count' => 0,
          'individual_meeting_with_survivor_count' => 0,
          'individual_meeting_other_than_survivor_count' => 0,
          'ngo_and_cbo_referred_to' => 0,
          'other_gov_org_services_referred_to' => 0,
          'exclients_count' => 0,
          'self_count' =>0,
          'police_count' => 0,
          'ngo_count' => 0,
          'community_based_org_count' => 0,
          'icw_pw_count' => 0,
          'word_of_mouth_count' => 0,
          'go_count' =>0,
          'lawyers_legal_org_count' => 0,
          'any_other_count' => 0,
          'individual_meeting_count' => 0,
          'group_meeting_count' => 0,
          'police_reffered_to_count' => 0,
          'medical_count' => 0,
          'shelter_count' => 0,
          'legal_services_count' => 0,
          'protection_officer_count' => 0,
          'lok_shiyakat_niwaran_count' => 0,
          'one_time_intervention_count' => 0,
          'home_visit_count' => 0,
          'collateral_visits_count' => 0,
          'participation_count' => 0,
          'conducted_session_or_prog_count' => 0,
          'programs_organised_count' => 0,
          'referred_by_total_count' => 0,
          'home_visit_outreach_detail' => 0,
          'individual_meeting_session' => 0,
          'on_going_cases_from_prev_month_count' => 0,
          'cases_sent_back_to_eo' => 0,
          'non_violent_reconcilation' => 0,
          'sent_back_to_eo_fr_legal_action' => 0,
          'sent_back_to_eo_for_dv_act' => 0,
          'sent_back_to_eo_for_mediation' => 0,
          'any_other_intervention_outcomes' => 0,
          'reffered_to' => 0
        })  
      end
      
      report_length = @mpr_data.length
      index_count = 0
      for j in @mpr_data
        index_count += 1
        if index_count != report_length
          @mpr_data[report_length-1]['new_registered_application_that_was_previously_one_time_intervention'] += j['new_registered_application_that_was_previously_one_time_intervention']
          @mpr_data[report_length-1]['engaing_police_help_count'] += j['engaing_police_help_count']
          @mpr_data[report_length-1]['new_reg_app_total'] += j['new_reg_app_total']
          @mpr_data[report_length-1]['new_reg_app_dat_were_prev_one_time_intervention'] += j['new_reg_app_dat_were_prev_one_time_intervention']
          @mpr_data[report_length-1]['on_going_intevention_count'] += j['on_going_intevention_count']
          @mpr_data[report_length-1]['ex_clients_word_of_mouth_count'] += j['ex_clients_word_of_mouth_count']
          @mpr_data[report_length-1]['medical_healthcare_referred_by_count'] += j['medical_healthcare_referred_by_count']
          @mpr_data[report_length-1]['protection_officer_clients_referred_by'] += j['protection_officer_clients_referred_by']
          @mpr_data[report_length-1]['telephonic_helpline_clients_referred_by'] += j['telephonic_helpline_clients_referred_by']
          @mpr_data[report_length-1]['referred_to_us_as_a_service_under_pwdv_2005'] += j['referred_to_us_as_a_service_under_pwdv_2005']
          @mpr_data[report_length-1]['individual_meeting_count_total_count'] += j['individual_meeting_count_total_count']
          @mpr_data[report_length-1]['individual_meeting_with_survivor_count'] += j['individual_meeting_with_survivor_count']
          @mpr_data[report_length-1]['individual_meeting_other_than_survivor_count'] += j['individual_meeting_other_than_survivor_count']
          @mpr_data[report_length-1]['ngo_and_cbo_referred_to'] += j['ngo_and_cbo_referred_to']
          @mpr_data[report_length-1]['other_gov_org_services_referred_to'] += j['other_gov_org_services_referred_to']
          @mpr_data[report_length-1]['cases_where_police_took_help_from_social_worker'] += j['cases_where_police_took_help_from_social_worker']
          @mpr_data[report_length-1]['exclients_count'] += j['exclients_count']
          @mpr_data[report_length-1]['self_count'] += j['self_count']
          @mpr_data[report_length-1]['police_count'] += j['police_count']
          @mpr_data[report_length-1]['ngo_count'] += j['ngo_count']
          @mpr_data[report_length-1]['community_based_org_count'] += j['community_based_org_count']
          @mpr_data[report_length-1]['icw_pw_count'] += j['icw_pw_count']
          @mpr_data[report_length-1]['word_of_mouth_count'] += j['word_of_mouth_count']
          @mpr_data[report_length-1]['go_count'] += j['go_count']
          @mpr_data[report_length-1]['lawyers_legal_org_count'] += j['lawyers_legal_org_count']
          @mpr_data[report_length-1]['any_other_count'] += j['any_other_count']
          @mpr_data[report_length-1]['individual_meeting_count'] += j['individual_meeting_count']
          @mpr_data[report_length-1]['group_meeting_count'] += j['group_meeting_count']
          @mpr_data[report_length-1]['police_reffered_to_count'] += j['police_reffered_to_count']
          @mpr_data[report_length-1]['medical_count'] += j['medical_count']
          @mpr_data[report_length-1]['shelter_count'] += j['shelter_count']
          @mpr_data[report_length-1]['legal_services_count'] += j['legal_services_count']
          @mpr_data[report_length-1]['protection_officer_count'] += j['protection_officer_count']
          @mpr_data[report_length-1]['lok_shiyakat_niwaran_count'] += j['lok_shiyakat_niwaran_count']
          @mpr_data[report_length-1]['one_time_intervention_count'] += j['one_time_intervention_count']
          @mpr_data[report_length-1]['home_visit_count'] += j['home_visit_count']
          @mpr_data[report_length-1]['collateral_visits_count'] += j['collateral_visits_count']
          @mpr_data[report_length-1]['participation_count'] += j['participation_count']
          @mpr_data[report_length-1]['conducted_session_or_prog_count'] += j['conducted_session_or_prog_count']
          @mpr_data[report_length-1]['programs_organised_count'] += j['programs_organised_count']
          @mpr_data[report_length-1]['referred_by_total_count'] += j['referred_by_total_count']
          @mpr_data[report_length-1]['home_visit_outreach_detail'] += j['home_visit_outreach_detail']
          @mpr_data[report_length-1]['individual_meeting_session'] += j['individual_meeting_session']
          @mpr_data[report_length-1]['on_going_cases_from_prev_month_count'] += j['on_going_cases_from_prev_month_count']
          @mpr_data[report_length-1]['cases_sent_back_to_eo'] += j['cases_sent_back_to_eo']
          @mpr_data[report_length-1]['non_violent_reconcilation'] += j['non_violent_reconcilation']
          @mpr_data[report_length-1]['sent_back_to_eo_fr_legal_action'] += j['sent_back_to_eo_fr_legal_action']
          @mpr_data[report_length-1]['sent_back_to_eo_for_dv_act'] += j['sent_back_to_eo_for_dv_act']
          @mpr_data[report_length-1]['sent_back_to_eo_for_mediation'] += j['sent_back_to_eo_for_mediation']
          @mpr_data[report_length-1]['any_other_intervention_outcomes'] += j['any_other_intervention_outcomes']
          @mpr_data[report_length-1]['reffered_to'] += j['reffered_to']
        end
      end
    end
      
    @state_name = ''
    @district_name = ''
    @cell_name = ''
    @district_in_csv = ''
    @cell_in_csv = ''

    for i in @location_array
      if i[1]!= nil
        if i[1] == @selected_state
          @state_name = i[0]
        end
      end
    end

    if @selected == "multi_district_selected" or @selected == "single_district_selected"
      location = @location_map_array[@selected_state.to_sym]
      count_district=0
      for i in location 
        if i[1]!=nil 
          for j in @selected_district
            if i[1] == j
              if count_district == 0
                count_district += 1
                @district_name += i[0]
                @district_in_csv += i[0]
              else
                count_district += 1
                @district_name += ", "+i[0]
                @district_in_csv += "/ "+i[0]
              end
            end
          end
        end
      end
    end

    count_cell=0
    if @selected == "inner_cell_selected"
      cell = @cell_map_array[@selected_district[0].to_sym]
      for i in cell
        if i[1]!=nil 
          for j in @selected_cell
            if i[1] == j
              if count_cell == 0
                count_cell += 1
                @cell_name += i[0]
                @cell_in_csv += i[0]
              else
                count_cell += 1
                @cell_name += ", "+i[0]
                @cell_in_csv += "/ "+i[0]
              end
            end
          end
        end
      end
    end

    @array_length = @mpr_data.length + 2
    end_date = (Date.parse(end_date)-1).to_s
    @end_date_for_display = end_date
    @start_date_for_display = Date.parse(start_date)

    @start_date_in_pdf=Date.parse(start_date).strftime("%d-%m-%Y")
    @end_date_in_pdf=Date.parse(end_date).strftime("%d-%m-%Y")

    @year_to_display = Date.parse(start_date).strftime("%Y")
    @month_to_display = Date.parse(end_date).strftime("%m")
    @month = ""
    for i in MONTH_ARRAY
      if i[1] == @month_to_display
        @month = i[0]
        break
      end  
    end

    s_n = @state_name.downcase
    render s_n+"_mpr"
    
    # @data.push(@police_count,@exclients_count,@word_of_mouth_count,@self_count,@lawyers_legal_org_count,@ngo_count,@go_count,@icw_pw_count,@any_other_count,@one_time_intervention_count,@home_visit_count,@collateral_visits_count,@individual_meeting_count,@group_meeting_count,@participation_count,@programs_organised_count,@conducted_session_or_prog_count,@police_reffered_to_count,@medical_count,@shelter_count,@legal_services_count,@protection_officer_count,@lok_shiyakat_niwaran_count,@on_going_intevention_count,@engaing_police_help_count,@state_in_pdf,@district_in_pdf,@start_date_in_pdf,@end_date_in_pdf)
  end

  def check_key_present(state,district_list,start_date,end_date, main_district,selected)
    for i in district_list
      x = i.to_sym
      # if false if selected cells doesnt have multiple locations.
      if @cell_map_array.has_key? (x) 
        location = @location_map_array[state.to_sym]
        for j in location   
          if j[1] == i
            main_district = j[0]
            break
          end
        end
        list = @cell_map_array[x]
        for j in list
          if j[1]!=nil
            calculate_mpr state, j[1], start_date, end_date, main_district, selected
          end
        end
      elsif @location_map_array.has_key? (state.to_sym)
        location = @location_map_array[state.to_sym]
        check_cell_present=0
        for j in location
          if j[1] == i
            check_cell_present += 1 
            calculate_mpr state, j[1], start_date, end_date, j[0], selected
            break
          end
        end

        if check_cell_present == 0
          calculate_mpr state, i , start_date, end_date, main_district, selected
        end
      end
    end
  end

  def calculate_mpr(state,district,start_date,end_date,main_district, selected)

      @new_registered_application_that_was_previously_one_time_intervention = 0

      #new variables
      @new_reg_app_total = 0
      @new_reg_app_dat_were_prev_one_time_intervention = 0
      @referred_by_total_count = 0
      @medical_healthcare_referred_by_count = 0
      @protection_officer_clients_referred_by = 0
      @telephonic_helpline_clients_referred_by = 0
      @referred_to_us_as_a_service_under_pwdv_2005 = 0
      @cases_where_police_took_help_from_social_worker = 0
      @individual_meeting_count_total_count = 0
      @individual_meeting_with_survivor_count = 0
      @individual_meeting_other_than_survivor_count = 0
      @referred_to_other_gov_org_services = 0
      @referred_to_ngo_cbo = 0
      @ex_clients_word_of_mouth_count = 0
      @ngo_and_cbo_referred_to = 0
      @other_gov_org_services_referred_to = 0
      
      @on_going_cases_from_prev_month_count = 0
      @cases_sent_back_to_eo = 0
      @non_violent_reconcilation = 0
      @sent_back_to_eo_fr_legal_action = 0
      @sent_back_to_eo_for_dv_act = 0
      @sent_back_to_eo_for_mediation = 0
      @any_other_intervention_outcomes = 0

      @engaing_police_help_count=0
      @on_going_intevention_count=0
     
      # / clients reffered by declaration of variables/
      @exclients_count=0
      @self_count=0
      @police_count=0
      @ngo_count=0
      @community_based_org_count=0
      @icw_pw_count=0
      @word_of_mouth_count=0
      @go_count=0
      @lawyers_legal_org_count=0
      @any_other_count=0
      
      # / end------------------------------/

      # meeting declaration variables 
      @individual_meeting_count=0
      @group_meeting_count=0
      # ------------------
      

      @police_reffered_to_count=0
      @medical_count=0
      @shelter_count=0
      @legal_services_count=0
      @protection_officer_count=0
      @lok_shiyakat_niwaran_count=0

      @one_time_intervention_count=0
      @home_visit_count=0
      @collateral_visits_count=0
      @participation_count=0
      @conducted_session_or_prog_count=0
      @programs_organised_count=0
      @ongoing_clients = 0

      end_date_for_ongoing_clients = start_date
      start_date_for_ongoing_clients = "1000-01-01"

      if district.empty?
        intervention_by_special_cell = Child.by_state_date_intervention_by_special_cell.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
        new_registered_application_that_was_previously_one_time_intervention = Child.by_state_date_new_registered_application_that_was_previously_one_time_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']
        total_clients_in_this_quarter = Child.by_state_date_clients_registered_in_this_quarter.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']
        ongoing_clients_in_this_quarter = Child.by_state_date_ongoing_clients_not_registered_in_this_quarter.startkey([state,1,start_date_for_ongoing_clients]).endkey([state,1,end_date_for_ongoing_clients,{}])['rows']
        clients_reffered_by = Child.by_state_date_clients_reffered_by.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
        nature_of_interaction = Child.by_state_date_nature_of_interaction.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
        new_refferals_array = Child.by_state_date_new_refferals.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
        one_time_intervention_array= Child.by_state_date_onetime_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']
        home_visits_array= Child.by_state_date_other_interevention_home_visits.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']  
        collateral_visits_array= Child.by_state_date_collateral_visits.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']
        participation_array= Child.by_state_date_programme_participation.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']  
        individual_meeting_session = Child.by_state_date_individual_meeting_session.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
        outcomes_new_clients_ongoing_clients = Child.by_state_date_outcomes_new_clients_ongoing_clients.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
        cases_sent_back_to_eo = Child.by_state_date_cases_sent_back_to_eo.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      else
        intervention_by_special_cell = Child.by_intervention_by_special_cell.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
        new_registered_application_that_was_previously_one_time_intervention = Child.by_new_registered_application_that_was_previously_one_time_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
        total_clients_in_this_quarter = Child.by_clients_registered_in_this_quarter.startkey([state,district,start_date]).endkey([state,district,end_date,{}])['rows']
        ongoing_clients_in_this_quarter = Child.by_ongoing_clients_not_registered_in_this_quarter.startkey([state,district,start_date_for_ongoing_clients]).endkey([state,district,end_date_for_ongoing_clients,{}])['rows']
        clients_reffered_by = Child.by_clients_reffered_by.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
        nature_of_interaction = Child.by_nature_of_interaction.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
        new_refferals_array = Child.by_new_refferals.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
        one_time_intervention_array= Child.by_onetime_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}])['rows']
        home_visits_array= Child.by_other_interevention_home_visits.startkey([state,district,start_date]).endkey([state,district,end_date,{}])['rows']
        collateral_visits_array= Child.by_collateral_visits.startkey([state,district,start_date]).endkey([state,district,end_date,{}])['rows']
        participation_array= Child.by_programme_participation.startkey([state,district,start_date]).endkey([state,district,end_date,{}])['rows']  
        individual_meeting_session = Child.by_individual_meeting_session.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
        outcomes_new_clients_ongoing_clients = Child.by_outcomes_new_clients_ongoing_clients.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
        cases_sent_back_to_eo = Child.by_cases_sent_back_to_eo.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      end


      for i in new_registered_application_that_was_previously_one_time_intervention
        if !i['key'][0].empty? && !i['key'][2].empty? 
          if i['key'][3]!=nil
            if i['key'][3] == true
              @new_registered_application_that_was_previously_one_time_intervention += i['value']
            end
          end
        end
      end

      for i in intervention_by_special_cell
        if !i['key'][0].empty? && !i['key'][2].empty?
          if i['key'][3]!=nil and !i['key'][3].empty?
            for j in i['key'][3]
              if j.include? "enlisting_police_help_or_intervention"
                @engaing_police_help_count += i['value']
              end
            end
          end
        end
      end

      for i in ongoing_clients_in_this_quarter
        if i['key'][3]!= nil  
          if i['key'][3].length!= 0
            for j in i['key'][3]
              if j.has_key? "ongoing_followup" and !j["ongoing_followup"].empty?
                date = Date.parse(j["ongoing_followup"])
                if date >= Date.parse(start_date) and date < Date.parse(end_date)
                  @on_going_intevention_count += 1
                  break
                end
              end
            end
          end
        end
      end  

      for i in total_clients_in_this_quarter
        @new_reg_app_total += i['value']
      end  

      for i in clients_reffered_by
        if !i['key'][0].empty? && !i['key'][2].empty?
          if i['key'][3]!= nil
            if i['key'][3].include? "ex_clients"
              @exclients_count += i['value']
            end
            if i['key'][3].include? "word_of_mouth"
              @word_of_mouth_count += i['value']
            end
            if i['key'][3].include? "word_of_mouth" or i['key'][3].include? "ex_clients"
              @ex_clients_word_of_mouth_count += i['value']
            end
            if i['key'][3].include? "health_system_hospital"
              @medical_healthcare_referred_by_count += i['value']
            end
            if i['key'][3].include? "protection_officer"
              @protection_officer_clients_referred_by += i['value']
            end
            if i['key'][3].include? "telephonic_helpline"
              @telephonic_helpline_clients_referred_by += i['value']
            end
            if i['key'][3].include? "referred_to_us_as_a_service_provider_under_pwdv_act_2005"
              @referred_to_us_as_a_service_under_pwdv_2005 += i['value']
            end
            if i['key'][3].include? "independent_community_worker_political_worker"
              @icw_pw_count += i['value']
            end
            if i['key'][3].include? "police"
              @police_count += i['value']
            end
            if i['key'][3].include? "self"
              @self_count += i['value']
            end
            if i['key'][3].include? "government_organisation_go"
              @go_count += i['value']
            end
            if i['key'][3].include? "non_governmental_organisation_ngo" or i['key'][3].include? "community_based_organisations"
              @ngo_count += i['value']
            end
            if i['key'][3].include? "lawyers_legal_organisations"
              @lawyers_legal_org_count += i['value']
            end
            if i['key'][3].include? "any_other" or i['key'][3].include? "others_specify"
              @any_other_count += i['value']
            end
          end
        end
      end
    
      for i in nature_of_interaction
        if !i['key'][0].empty? && !i['key'][2].empty?
          if i['key'][3]!= nil and i['key'][3].length > 0
            for j in i['key'][3]
              if j.include? "group_meetings" or j.include? "joint_meetings" or j.include? "joint_meetings_group_meetings"
                @group_meeting_count += i['value']
              end
              if j.include? "individual_meetings_sessions"
                @individual_meeting_count += i['value']
              end
            end
          end
        end
      end
      
      for i in individual_meeting_session
        if !i['key'][0].empty? && !i['key'][2].empty?
          if i['key'][3]!= nil
            if i['key'][3].include? "individual_meeting_with_survivor"
              @individual_meeting_with_survivor_count += i['value']
            elsif i['key'][3].include? "individual_meeting_with_those_other_than_survivor"
              @individual_meeting_other_than_survivor_count += i['value']
            end
          end
        end
      end
      
      for i in new_refferals_array
        if !i['key'][0].empty? && !i['key'][2].empty?
          if i['key'][3]!=nil and i['key'][3].length > 0
            for j in i['key'][3]
              if j.include? "court_dlsa" or j.include? "lawyer" or j.include? "court_lawyers_legal_organisations"
                @legal_services_count += i['value']
              end
              if j.include? "medical_service" or j.include? "mental_health_services" 
                @medical_count+= i['value']
              end
              if j.include? "police"
                @police_reffered_to_count+= i['value']
              end
              if j.include? "protection_officer"
                @protection_officer_count+= i['value']
              end
              if j.include? "shelter_home"
                @shelter_count+= i['value']
              end
              if j.include? "government_organisation_go" or j.include? "non_governmental_organisation_ngo" or j.include? "community_based_organisations_cbo" or j.include? "any_other" or j.include? "others_specify"
                @lok_shiyakat_niwaran_count+= i['value']
              end
              if j.include? "non_governmental_organisation_ngo" or j.include? "community_based_organisations_cbo"
                @ngo_and_cbo_referred_to+= i['value']
              end
              if j.include? "any_other" or j.include? "others_specify" or j.include? "government_organisation_go"
                @other_gov_org_services_referred_to+= i['value']
              end
            end
          end
        end
      end

      for i in one_time_intervention_array
        if !i['key'][0].empty? && !i['key'][2].empty?
          @one_time_intervention_count += i['value']
          if i['key'][4]!=nil
            if !i['key'][3].include? "direct_intervention_with_client"
              @cases_where_police_took_help_from_social_worker += i['value']
            end
          end
        end
      end

      for i in home_visits_array
        @home_visit_count += i['value']
      end

      for i in collateral_visits_array
        @collateral_visits_count += i['value']
      end

      for i in participation_array
        if !i['key'][0].empty? && !i['key'][2].empty?
          if i['key'][3].include? "conducted_or_facilitated_a_session_or_programme_as_a_resource_person"
            @conducted_session_or_prog_count += i['value']
          elsif i['key'][3].include? "participated_in_workshops_conferences_meetings_seminars"
            @participation_count += i['value']
          elsif i['key'][3].include? "organised_programme"
            @programs_organised_count += i['value']
          end
        end
      end 

      for i in outcomes_new_clients_ongoing_clients
        if !i['key'][0].empty? && !i['key'][2].empty?
          if i['key'][3]!= nil and i['key'][3].length > 0
            for j in i['key'][3]
              if j.include? "case_sent_back_to_eo"
                @cases_sent_back_to_eo += i['value']
              end
              if j.include? "any_other" or j.include? "others_specify"
                @any_other_intervention_outcomes += i['value']
              end
              if j.include? "non_violent_reconciliation"
                @non_violent_reconcilation += i['value']
              end
            end
          end
        end
      end

      for i in cases_sent_back_to_eo
        if !i['key'][0].empty? && !i['key'][2].empty?
          if i['key'][3]!= nil and i['key'][3].length > 0
            for j in i['key'][3]
              if j.include? "sent_back_to_eo_dv_act"
                @sent_back_to_eo_for_dv_act += i['value']
              end 
              if j.include? "sent_back_to_eo_for_mediation"
                @sent_back_to_eo_for_mediation += i['value']
              end
              if j.include? "sent_back_to_eo_for_legal_action"
                @sent_back_to_eo_fr_legal_action += i['value']
              end
            end
          end
        end
      end
      

    # @start_date_for_display = Date.parse(start_date)
    
    state_name= ''
    for i in @location_array
      if i[1]!= nil
        if i[1] == state
          state_name = i[0]
        end
      end
    end

    if selected == "inner_cell_selected"
      if @cell_map_array.has_key? (main_district.to_sym)
        cell_array = @cell_map_array[main_district.to_sym]
        for i in cell_array
          if i[1]!= nil
            if i[1] == district
              main_district = i[0]
              break
            end
          end
        end
      end
    end

    @mpr_data.push({
      'state' => state,
      'district' => main_district,
      'cell' => district,
      'new_registered_application_that_was_previously_one_time_intervention' => @new_registered_application_that_was_previously_one_time_intervention,
      'new_reg_app_total' => @new_reg_app_total,
      'new_reg_app_dat_were_prev_one_time_intervention' => @new_reg_app_dat_were_prev_one_time_intervention,
      'engaing_police_help_count' => @engaing_police_help_count,
      'on_going_intevention_count' => @on_going_intevention_count,
      'ex_clients_word_of_mouth_count' => @ex_clients_word_of_mouth_count,
      'medical_healthcare_referred_by_count' => @medical_healthcare_referred_by_count,
      'protection_officer_clients_referred_by' => @protection_officer_clients_referred_by,
      'telephonic_helpline_clients_referred_by' => @telephonic_helpline_clients_referred_by,
      'referred_to_us_as_a_service_under_pwdv_2005' => @referred_to_us_as_a_service_under_pwdv_2005,
      'cases_where_police_took_help_from_social_worker' => @cases_where_police_took_help_from_social_worker,
      'individual_meeting_count_total_count' => @individual_meeting_count_total_count,
      'individual_meeting_with_survivor_count' => @individual_meeting_with_survivor_count,
      'individual_meeting_other_than_survivor_count' => @individual_meeting_other_than_survivor_count,
      'ngo_and_cbo_referred_to' => @ngo_and_cbo_referred_to,
      'other_gov_org_services_referred_to' => @other_gov_org_services_referred_to,
      'exclients_count' => @exclients_count,
      'self_count' => @self_count,
      'police_count' => @police_count,
      'ngo_count' => @ngo_count,
      'community_based_org_count' => @community_based_org_count,
      'icw_pw_count' => @icw_pw_count,
      'word_of_mouth_count' => @word_of_mouth_count,
      'go_count' => @go_count,
      'lawyers_legal_org_count' => @lawyers_legal_org_count,
      'any_other_count' => @any_other_count,
      'individual_meeting_count' => @individual_meeting_count,
      'group_meeting_count' => @group_meeting_count,
      'police_reffered_to_count' => @police_reffered_to_count,
      'medical_count' => @medical_count,
      'shelter_count' => @shelter_count,
      'legal_services_count' => @legal_services_count,
      'protection_officer_count' => @protection_officer_count,
      'lok_shiyakat_niwaran_count' => @lok_shiyakat_niwaran_count,
      'one_time_intervention_count' => @one_time_intervention_count,
      'home_visit_count' => @home_visit_count,
      'collateral_visits_count' => @collateral_visits_count,
      'participation_count' => @participation_count,
      'conducted_session_or_prog_count' => @conducted_session_or_prog_count,
      'programs_organised_count' => @programs_organised_count,
      'referred_by_total_count' => @exclients_count + @self_count + @police_count + @ngo_count + @community_based_org_count + @icw_pw_count + @word_of_mouth_count + @go_count + @lawyers_legal_org_count + @any_other_count,
      'home_visit_outreach_detail' => @home_visit_count + @collateral_visits_count,
      'individual_meeting_session' => @group_meeting_count + @engaing_police_help_count + @participation_count + @programs_organised_count + @conducted_session_or_prog_count,
      'reffered_to' => @police_reffered_to_count + @medical_count + @shelter_count + @legal_services_count + @protection_officer_count + @lok_shiyakat_niwaran_count,
      'on_going_cases_from_prev_month_count' => @on_going_cases_from_prev_month_count,
      'cases_sent_back_to_eo' => @cases_sent_back_to_eo,
      'non_violent_reconcilation' => @non_violent_reconcilation,
      'sent_back_to_eo_fr_legal_action' => @sent_back_to_eo_fr_legal_action,
      'sent_back_to_eo_for_dv_act' => @sent_back_to_eo_for_dv_act,
      'sent_back_to_eo_for_mediation' => @sent_back_to_eo_for_mediation,
      'any_other_intervention_outcomes' => @any_other_intervention_outcomes
    })
  end
end

  

