class OneTimeInterventionController < ApplicationController

  def initialize
    super()
    
    @location_array = ::LOCATION_ARRAY
    @maha_location_array = ::MAHARASHTRA
    @delh_location_array = DELHI
    @ncw_location_array = NCW
    @cell_map_array = CELL_MAP_ARRAY
    @location_map_array = LOCATION_MAP_ARRAY
    @quarter_array = QUARTER_ARRAY
    @qpr_data = []
    @month_array = MONTH_ARRAY
  end
    

  def index
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
    
    selected_month = params[:month_select].to_s.to_i
    selected_year = params[:date]['year'].to_s.to_i
    
    if selected_month != nil
      start_date = Date.new(selected_year, selected_month, 1)
      end_date = Date.new(selected_year, selected_month, -1)
      start_date = start_date.to_s
      end_date = end_date.to_s
    end

    set_location_empty=false
    set_start_date_empty=false
    set_end_date_empty=false
    set_start_date_greater_than_end_date=false

    if !state.empty? && !start_date.empty? && !end_date.empty?
      end_date_in_date=Date.parse(end_date)
      start_date_in_date=Date.parse(start_date)
      end_date = (end_date_in_date+1).to_s
      if start_date_in_date <= end_date_in_date
        redirect_to action: "show_one_time_intervention_report",state: state, district: district, cell: cell, start_date: start_date, end_date: end_date
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
    
  def show_one_time_intervention_report
    @data=[]
    @new_qpr_data=[]
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
        calculate_qpr selected_state, "", start_date, end_date, "",@selected
      end
    else
      @selected = "state_selected"
      calculate_qpr selected_state, "", start_date, end_date, "",@selected
    end  
    
    district_array=[]
    district_gt_1_array=[]
    dist_count_gt_1 = false
    if !@qpr_data.empty?
      for i in @qpr_data
        if i['district']!= ""
          district_array.push(i['district'])
        end
      end
      district_array = district_array.uniq

      if district_array.length > 0
        for i in district_array
          district_count=0
          for j in @qpr_data
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
          for j in @qpr_data
            if j['district']== i
              j['cell']=''
              @new_qpr_data.push(j)
            end
          end
        end
      end

      for i in district_gt_1_array
        for j in @qpr_data
          if j['district']== i
            if @new_qpr_data.empty? or !@new_qpr_data.any? {|h| h['district'] == i}
              @new_qpr_data.push({
                'state' => j['state'],
                'district' => j['district'],
                'cell' => '',

                'outcomes_sent_back_to_eo_fr_legal_action' => j['outcomes_sent_back_to_eo_fr_legal_action'],
                'sent_back_to_eo_for_dv_act' => j['sent_back_to_eo_for_dv_act'],
                'outcomes_sent_back_to_eo_for_mediation' => j['outcomes_sent_back_to_eo_for_mediation'],

                'other_special_cell_clients_reffered_by' =>  j['other_special_cell_clients_reffered_by'],
                'jamat_samaj_jan_panchayat_clients_referred_by' =>  j['jamat_samaj_jan_panchayat_clients_referred_by'],
                'religious_education_count' =>  j['religious_education_count'],
                'diploma_education_count' =>  j['diploma_education_count'],
                'prev_interv_fcc_zpcc' =>  j['prev_interv_fcc_zpcc'],
                'prev_interv_government_organisation_go' =>  j['prev_interv_government_organisation_go'],
                'spcell_negotiating_to_stop_non_violence' =>  j['spcell_negotiating_to_stop_non_violence'],
                'spcell_negotiating_for_non_violence_reconciliation' =>  j['spcell_negotiating_for_non_violence_reconciliation'],
                'spcell_negotiating_for_seperation' =>  j['spcell_negotiating_for_seperation'],
                'spcell_negotiating_for_divorce' =>  j['spcell_negotiating_for_divorce'],
                'spcell_negotiating_for_child_custody' =>  j['spcell_negotiating_for_child_custody'],
                'spcell_retrieval_of_streedhan' =>  j['spcell_retrieval_of_streedhan'],
                'spcell_reestablishing_the_woman_s_relationship_to_her_property' =>  j['spcell_reestablishing_the_woman_s_relationship_to_her_property'],
                'ngo_referral_count' =>  j['ngo_referral_count'],
                'cbo_referral_count' =>  j['cbo_referral_count'],
                'go_referral_count' =>  j['go_referral_count'],
                'ngo_referral_count_ongoing_client' =>  j['ngo_referral_count_ongoing_client'],
                'cbo_referral_count_ongoing_client' =>  j['cbo_referral_count_ongoing_client'],
                'go_referral_count_ongoing_client' =>  j['go_referral_count_ongoing_client'],
                'othr_inter_representation_on_sexual_harrassment_committee' =>  j['othr_inter_representation_on_sexual_harrassment_committee'],
                'outcomes_helped_in_filing_case_for_divorce_seperation' =>  j['outcomes_helped_in_filing_case_for_divorce_seperation'],
                'outcomes_talaq_khula' =>  j['outcomes_talaq_khula'],
                'outcomes_fir_registered' =>  j['outcomes_fir_registered'],
                'outcome_nc_registration' =>  j['outcome_nc_registration'],
                'outcome_child_custody' =>  j['outcome_child_custody'],
                'outcome_without_court_seperation' =>  j['outcome_without_court_seperation'],
                'outcomes_helped_in_filing_case_in_court_for_mediation' =>  j['outcomes_helped_in_filing_case_in_court_for_mediation'],
                'outcomes_other_than_498A' =>  j['outcomes_other_than_498A'],
                'outcome_other_than_498A_count_ongoing_client' =>  j['outcome_other_than_498A_count_ongoing_client'],
                'outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients' =>  j['outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients'],

                  # / variable declaration/
                'total_client_with_whom_interaction' =>  j['total_client_with_whom_interaction'],
                'ongoing_clients' =>  j['ongoing_clients'],
                'one_time_intervention_in_this_quarter' =>  j['one_time_intervention_in_this_quarter'],
                'no_of_ppl_prvded_supp' =>  j['no_of_ppl_prvded_supp'],
            
                # ------------------
                'total_clients' =>  j['total_clients'],
            
                "clients" => j["clients"],
                # / clients reffered by declaration of variables/
                'exclients_count' =>  j['exclients_count'],
                'self_count' =>  j['self_count'],
                'police_count' =>  j['police_count'],
                'ngo_count' =>  j['ngo_count'],
                'community_based_org_count' =>  j['community_based_org_count'],
                'icw_pw_count' =>  j['icw_pw_count'],
                'word_of_mouth_count' =>  j['word_of_mouth_count'],
                'go_count' =>  j['go_count'],
                'lawyers_legal_org_count' =>  j['lawyers_legal_org_count'],
                'any_other_clients_refferd_count' =>  j['any_other_clients_refferd_count'], 
                # / end------------------------------/
            
                "gender" => j["gender"],
                # Gender of the complainants/ clients ----variable declaration
                'adult_male_count' =>  j['adult_male_count'],
                'adult_female_count' =>  j['adult_female_count'],
                'child_male_count' =>  j['child_male_count'],
                'child_female_count' =>  j['child_female_count'],
                'third_gender_count' =>  j['third_gender_count'],
                # -----------------------
            
                "age" => j["age"],
                # Age of the clients----variable declaration
                'less_than_14_count' =>  j['less_than_14_count'],
                'in_15_17_count' =>  j['in_15_17_count'],
                'in_18_24_count' =>  j['in_18_24_count'],
                'in_25_34_count' =>  j['in_25_34_count'],
                'in_35_44_count' =>  j['in_35_44_count'],
                'in_45_54_count' =>  j['in_45_54_count'],
                'above_55_count' =>  j['above_55_count'],
                'no_age_info_count' =>  j['no_age_info_count'],
                # --------------------
            
                "education" => j["education"],
                #Education of the clients ----variable declaration
                'non_literate_count' =>  j['non_literate_count'],
                'functional_literacy_count' =>  j['functional_literacy_count'],
                'primary_level_class_4_count' =>  j['primary_level_class_4_count'],
                'upto_ssc_count' =>  j['upto_ssc_count'],
                'upto_hsc_count' =>  j['upto_hsc_count'],
                'upto_grad_count' =>  j['upto_grad_count'],
                'post_grad_count' =>  j['post_grad_count'],
                'any_other_edu_count' =>  j['any_other_edu_count'],
                'no_edu_info_count' =>  j['no_edu_info_count'],
                # ----------------------
            
                "reasons_special_cell" => j["reasons_special_cell"],
                # Reasons for registering at the Special Cell ----variable declaration
                'phy_vio_by_hus_count' =>  j['phy_vio_by_hus_count'],
                'emo_men_vio_by_hus_count' =>  j['emo_men_vio_by_hus_count'],
                'sex_vio_by_hus_count' =>  j['sex_vio_by_hus_count'],
                'fin_vio_by_hus_count' =>  j['fin_vio_by_hus_count'],
                'sec_marr_by_hus_count' =>  j['sec_marr_by_hus_count'],
                'ref_to_strredhan_by_hus_count' =>  j['ref_to_strredhan_by_hus_count'],
                'alch_vio_by_hus_count' =>  j['alch_vio_by_hus_count'],
                'desertion_by_hus_count' =>  j['desertion_by_hus_count'],
                'child_custody_vio_count' =>  j['child_custody_vio_count'],
                'phy_vio_by_mart_family_count' =>  j['phy_vio_by_mart_family_count'],
                'emo_vio_by_mart_family_count' =>  j['emo_vio_by_mart_family_count'],
                'sex_vio_by_mart_family_count' =>  j['sex_vio_by_mart_family_count'],
                'fin_vio_by_mart_family_count' =>  j['fin_vio_by_mart_family_count'],
                'harr_natal_family_by_hus_count' =>  j['harr_natal_family_by_hus_count'],
                'dep_matr_res_count' =>  j['dep_matr_res_count'],
                'childbattering_count' =>  j['childbattering_count'],
                'dowry_count' =>  j['dowry_count'],
                'harr_by_natal_family_count' =>  j['harr_by_natal_family_count'],
                'harr_by_chil_spouse_count' =>  j['harr_by_chil_spouse_count'],
                'wife_left_matr_home_count' =>  j['wife_left_matr_home_count'],
                'harr_at_work_count' =>  j['harr_at_work_count'],
                'harr_by_live_in_partner_count' =>  j['harr_by_live_in_partner_count'],
                'sex_assault_count' =>  j['sex_assault_count'],
                'sex_har_in_other_sit_count' =>  j['sex_har_in_other_sit_count'],
                'breach_of_trust_count' =>  j['breach_of_trust_count'],
                'harr_by_neigh_count' =>  j['harr_by_neigh_count'],
                'any_other_harr_count' =>  j['any_other_harr_count'],
                # ---------------------------
            
                "prev_inter_bef_comming_to_cell" => j["prev_inter_bef_comming_to_cell"],
                # Previous intervention before coming to the Cell ----variable declaration
                'prev_inter_natal_family_marital_family_count' =>  j['prev_inter_natal_family_marital_family_count'],
                'prev_inter_police_count' =>  j['prev_inter_police_count'],
                'prev_inter_court_count' =>  j['prev_inter_court_count'],
                'prev_interv_ngo_count' =>  j['prev_interv_ngo_count'],
                'prev_interv_panch_mem_count' =>  j['prev_interv_panch_mem_count'],
                'prev_interv_any_other_count' =>  j['prev_interv_any_other_count'],
                # ------------------------------------------------------------------------
            
                "intervension_by_spec_cell" => j["intervension_by_spec_cell"],
                # Intervention by the Special Cell
                'spec_cell_prov_emo_support_count' =>  j['spec_cell_prov_emo_support_count'],
                'spec_cell_neg_nonvio_with_stakeholder_count' =>  j['spec_cell_neg_nonvio_with_stakeholder_count'],
                'spec_cell_build_support_system_count' =>  j['spec_cell_build_support_system_count'],
                'spec_cell_enlist_police_help_count' =>  j['spec_cell_enlist_police_help_count'],
                'spec_cell_pre­litigation_counsel_count' =>  j['spec_cell_pre­litigation_counsel_count'],
                'spec_cell_work_with_men_count' =>  j['spec_cell_work_with_men_count'],
                'spec_cell_adv_fin_ent_count' =>  j['spec_cell_adv_fin_ent_count'],
                'spec_cell_refferal_for_shelter_count' =>  j['spec_cell_refferal_for_shelter_count'],
                'spec_cell_dev_counsel_count' =>  j['spec_cell_dev_counsel_count'],
                # ------------------------------
            
                "intervension_by_spec_cell_ongoing" => j["intervension_by_spec_cell_ongoing"],
                # Intervention by the Special Cell ongoing ----variable declaration
                'spec_cell_prov_emo_support_count_ongoing_client' =>  j['spec_cell_prov_emo_support_count_ongoing_client'],
                'spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client' =>  j['spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client'],
                'spec_cell_build_support_system_count_ongoing_client' =>  j['spec_cell_build_support_system_count_ongoing_client'],
                'spec_cell_enlist_police_help_count_ongoing_client' =>  j['spec_cell_enlist_police_help_count_ongoing_client'],
                'spec_cell_pre­litigation_counsel_count_ongoing_client' =>  j['spec_cell_pre­litigation_counsel_count_ongoing_client'],
                'spec_cell_work_with_men_count_ongoing_client' =>  j['spec_cell_work_with_men_count_ongoing_client'],
                'spec_cell_adv_fin_ent_count_ongoing_client' =>  j['spec_cell_adv_fin_ent_count_ongoing_client'],
                'spec_cell_refferal_for_shelter_count_ongoing_client' =>  j['spec_cell_refferal_for_shelter_count_ongoing_client'],
                'spec_cell_dev_counsel_count_ongoing_client' =>  j['spec_cell_dev_counsel_count_ongoing_client'],
                # ------------------------------
            
                "refferals" => j["refferals"],
                # Refferals --variable declaration
                'police_refferal_count' =>  j['police_refferal_count'],
                'medical_refferal_count' =>  j['medical_refferal_count'],
                'shelter_refferal_count' =>  j['shelter_refferal_count'],
                'lawer_services_refferal_count' =>  j['lawer_services_refferal_count'],
                'protection_officer_refferal_count' =>  j['protection_officer_refferal_count'],
                'court_dlsa_refferal_count' =>  j['court_dlsa_refferal_count'], 
                'any_other_refferal_count' =>  j['any_other_refferal_count'],
                # -----------------------------
            
                "refferals_ongoing" => j["refferals_ongoing"],
                # Refferals ongoing --variable declaration
                'police_refferal_count_ongoing_client' =>  j['police_refferal_count_ongoing_client'],
                'medical_refferal_count_ongoing_client' =>  j['medical_refferal_count_ongoing_client'],
                'shelter_refferal_count_ongoing_client' =>  j['shelter_refferal_count_ongoing_client'],
                'lawer_services_refferal_count_ongoing_client' =>  j['lawer_services_refferal_count_ongoing_client'],
                'protection_officer_refferal_count_ongoing_client' =>  j['protection_officer_refferal_count_ongoing_client'],
                'court_dlsa_refferal_count_ongoing_client' =>  j['court_dlsa_refferal_count_ongoing_client'], 
                'any_other_refferal_count_ongoing_client' =>  j['any_other_refferal_count_ongoing_client'],
                # -----------------------------
            
                "other_intervention" => j["other_intervention"],
                #Other interventions in the community  --variable declaration
                'othr_inter_home_visit_count' =>  j['othr_inter_home_visit_count'],
                'othr_inter_visit_inst_count' =>  j['othr_inter_visit_inst_count'],
                'othr_inter_comm_edu_count' =>  j['othr_inter_comm_edu_count'],
                'othr_inter_meet_local_count' =>  j['othr_inter_meet_local_count'],
                'othr_inter_inter_with_police_count' =>  j['othr_inter_inter_with_police_count'],
                'othr_inter_any_other_count' =>  j['othr_inter_any_other_count'],
            
                # -------------------------------
            
                "outcomes" => j["outcomes"],
                # Outcomes   --variable declaration
                'outcomes_helped_in_case_filed_for_divorce_count' =>  j['outcomes_helped_in_case_filed_for_divorce_count'],
                'outcome_streedhan_retrival_count' =>  j['outcome_streedhan_retrival_count'],
                'outcome_pwdva_2005_count' =>  j['outcome_pwdva_2005_count'],
                'outcome_498A_count' =>  j['outcome_498A_count'],
                'outcome_maintenence_count' =>  j['outcome_maintenence_count'],
                'outcome_non_violent_recon_count' =>  j['outcome_non_violent_recon_count'],
                'outcome_court_order_count' =>  j['outcome_court_order_count'],
                'outcome_any_other_count' =>  j['outcome_any_other_count'],
                # ----------------------------------
            
                "outcomes_ongoing" => j["outcomes_ongoing"],
                # Outcomes ongoing --variable declaration
                'outcomes_helped_in_case_filed_for_divorce_count_ongoing_client' =>  j['outcomes_helped_in_case_filed_for_divorce_count_ongoing_client'],
                'outcome_streedhan_retrival_count_ongoing_client' =>  j['outcome_streedhan_retrival_count_ongoing_client'],
                'outcome_pwdva_2005_count_ongoing_client' =>  j['outcome_pwdva_2005_count_ongoing_client'],
                'outcome_498A_count_ongoing_client' =>  j['outcome_498A_count_ongoing_client'],
                'outcome_maintenence_count_ongoing_client' =>  j['outcome_maintenence_count_ongoing_client'],
                'outcome_non_violent_recon_count_ongoing_client' =>  j['outcome_non_violent_recon_count_ongoing_client'],
                'outcome_court_order_count_ongoing_client' =>  j['outcome_court_order_count_ongoing_client'],
                'outcome_any_other_count_ongoing_client' => j['outcome_any_other_count_ongoing_client']
                    })
          
            else
              for k in @new_qpr_data
                if k['district'] == i
                     # / variable declaration/

                k['outcomes_sent_back_to_eo_fr_legal_action'] += j['outcomes_sent_back_to_eo_fr_legal_action']
                k['sent_back_to_eo_for_dv_act'] += j['sent_back_to_eo_for_dv_act']
                k['outcomes_sent_back_to_eo_for_mediation'] += j['outcomes_sent_back_to_eo_for_mediation']
                k['other_special_cell_clients_reffered_by'] += j['other_special_cell_clients_reffered_by']
                k['jamat_samaj_jan_panchayat_clients_referred_by'] += j['jamat_samaj_jan_panchayat_clients_referred_by']
                k['religious_education_count'] += j['religious_education_count']
                k['diploma_education_count'] += j['diploma_education_count']
                k['prev_interv_fcc_zpcc'] += j['prev_interv_fcc_zpcc']
                k['prev_interv_government_organisation_go'] += j['prev_interv_government_organisation_go']
                k['spcell_negotiating_to_stop_non_violence'] += j['spcell_negotiating_to_stop_non_violence']
                k['spcell_negotiating_for_non_violence_reconciliation'] += j['spcell_negotiating_for_non_violence_reconciliation']
                k['spcell_negotiating_for_seperation'] += j['spcell_negotiating_for_seperation']
                k['spcell_negotiating_for_divorce'] += j['spcell_negotiating_for_divorce']
                k['spcell_negotiating_for_child_custody'] += j['spcell_negotiating_for_child_custody']
                k['spcell_retrieval_of_streedhan'] += j['spcell_retrieval_of_streedhan']
                k['spcell_reestablishing_the_woman_s_relationship_to_her_property'] += j['spcell_reestablishing_the_woman_s_relationship_to_her_property']
                k['ngo_referral_count'] += j['ngo_referral_count']
                k['cbo_referral_count'] += j['cbo_referral_count']
                k['go_referral_count'] += j['go_referral_count']
                k['ngo_referral_count_ongoing_client'] += j['ngo_referral_count_ongoing_client']
                k['cbo_referral_count_ongoing_client'] += j['cbo_referral_count_ongoing_client']
                k['go_referral_count_ongoing_client'] += j['go_referral_count_ongoing_client']
                k['othr_inter_representation_on_sexual_harrassment_committee'] += j['othr_inter_representation_on_sexual_harrassment_committee']
                k['outcomes_helped_in_filing_case_for_divorce_seperation'] += j['outcomes_helped_in_filing_case_for_divorce_seperation']
                k['outcomes_talaq_khula'] += j['outcomes_talaq_khula']
                k['outcomes_fir_registered'] += j['outcomes_fir_registered']
                k['outcome_nc_registration'] += j['outcome_nc_registration']
                k['outcome_child_custody'] += j['outcome_child_custody']
                k['outcome_without_court_seperation'] += j['outcome_without_court_seperation']
                k['outcomes_helped_in_filing_case_in_court_for_mediation'] += j['outcomes_helped_in_filing_case_in_court_for_mediation']
                k['outcomes_other_than_498A'] += j['outcomes_other_than_498A']
                k['outcome_other_than_498A_count_ongoing_client'] += j['outcome_other_than_498A_count_ongoing_client']
                k['outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients'] += j['outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients']

                k['total_client_with_whom_interaction'] +=  j['total_client_with_whom_interaction']
                k['ongoing_clients'] +=  j['ongoing_clients']
                k['one_time_intervention_in_this_quarter'] +=  j['one_time_intervention_in_this_quarter']
                k['no_of_ppl_prvded_supp'] +=  j['no_of_ppl_prvded_supp']
            
                # ------------------
                k['total_clients'] +=  j['total_clients']
            
                k["clients"] += j["clients"]
                # / clients reffered by declaration of variables/
                k['exclients_count'] +=  j['exclients_count']
                k['self_count'] +=  j['self_count']
                k['police_count'] +=  j['police_count']
                k['ngo_count'] +=  j['ngo_count']
                k['community_based_org_count'] +=  j['community_based_org_count']
                k['icw_pw_count'] +=  j['icw_pw_count']
                k['word_of_mouth_count'] +=  j['word_of_mouth_count']
                k['go_count'] +=  j['go_count']
                k['lawyers_legal_org_count'] +=  j['lawyers_legal_org_count']
                k['any_other_clients_refferd_count'] +=  j['any_other_clients_refferd_count'] 
                # / end------------------------------/
            
                k["gender"] += j["gender"]
                # Gender of the complainants/ clients ----variable declaration
                k['adult_male_count'] +=  j['adult_male_count']
                k['adult_female_count'] +=  j['adult_female_count']
                k['child_male_count'] +=  j['child_male_count']
                k['child_female_count'] +=  j['child_female_count']
                k['third_gender_count'] +=  j['third_gender_count']
                # -----------------------
            
                k["age"] += j["age"]
                # Age of the clients----variable declaration
                k['less_than_14_count'] +=  j['less_than_14_count']
                k['in_15_17_count'] +=  j['in_15_17_count']
                k['in_18_24_count'] +=  j['in_18_24_count']
                k['in_25_34_count'] +=  j['in_25_34_count']
                k['in_35_44_count'] +=  j['in_35_44_count']
                k['in_45_54_count'] +=  j['in_45_54_count']
                k['above_55_count'] +=  j['above_55_count']
                k['no_age_info_count'] +=  j['no_age_info_count']
                # --------------------
                 
                k["education"] += j["education"]
                #Education of the clients ----variable declaration
                k['non_literate_count'] +=  j['non_literate_count']
                k['functional_literacy_count'] +=  j['functional_literacy_count']
                k['primary_level_class_4_count'] +=  j['primary_level_class_4_count']
                k['upto_ssc_count'] +=  j['upto_ssc_count']
                k['upto_hsc_count'] +=  j['upto_hsc_count']
                k['upto_grad_count'] +=  j['upto_grad_count']
                k['post_grad_count'] +=  j['post_grad_count']
                k['any_other_edu_count'] +=  j['any_other_edu_count']
                k['no_edu_info_count'] +=  j['no_edu_info_count']
                # ----------------------
            
                k["reasons_special_cell"] += j["reasons_special_cell"]
                # Reasons for registering at the Special Cell ----variable declaration
                k['phy_vio_by_hus_count'] +=  j['phy_vio_by_hus_count']
                k['emo_men_vio_by_hus_count'] +=  j['emo_men_vio_by_hus_count']
                k['sex_vio_by_hus_count'] +=  j['sex_vio_by_hus_count']
                k['fin_vio_by_hus_count'] +=  j['fin_vio_by_hus_count']
                k['sec_marr_by_hus_count'] +=  j['sec_marr_by_hus_count']
                k['ref_to_strredhan_by_hus_count'] +=  j['ref_to_strredhan_by_hus_count']
                k['alch_vio_by_hus_count'] +=  j['alch_vio_by_hus_count']
                k['desertion_by_hus_count'] +=  j['desertion_by_hus_count']
                k['child_custody_vio_count'] +=  j['child_custody_vio_count']
                k['phy_vio_by_mart_family_count'] +=  j['phy_vio_by_mart_family_count']
                k['emo_vio_by_mart_family_count'] +=  j['emo_vio_by_mart_family_count']
                k['sex_vio_by_mart_family_count'] +=  j['sex_vio_by_mart_family_count']
                k['fin_vio_by_mart_family_count'] +=  j['fin_vio_by_mart_family_count']
                k['harr_natal_family_by_hus_count'] +=  j['harr_natal_family_by_hus_count']
                k['dep_matr_res_count'] +=  j['dep_matr_res_count']
                k['childbattering_count'] +=  j['childbattering_count']
                k['dowry_count'] +=  j['dowry_count']
                k['harr_by_natal_family_count'] +=  j['harr_by_natal_family_count']
                k['harr_by_chil_spouse_count'] +=  j['harr_by_chil_spouse_count']
                k['wife_left_matr_home_count'] +=  j['wife_left_matr_home_count']
                k['harr_at_work_count'] +=  j['harr_at_work_count']
                k['harr_by_live_in_partner_count'] +=  j['harr_by_live_in_partner_count']
                k['sex_assault_count'] +=  j['sex_assault_count']
                k['sex_har_in_other_sit_count'] +=  j['sex_har_in_other_sit_count']
                k['breach_of_trust_count'] +=  j['breach_of_trust_count']
                k['harr_by_neigh_count'] +=  j['harr_by_neigh_count']
                k['any_other_harr_count'] +=  j['any_other_harr_count']
                # ---------------------------
            
                k["prev_inter_bef_comming_to_cell"] += j["prev_inter_bef_comming_to_cell"]
                # Previous intervention before coming to the Cell ----variable declaration
                k['prev_inter_natal_family_marital_family_count'] +=  j['prev_inter_natal_family_marital_family_count']
                k['prev_inter_police_count'] +=  j['prev_inter_police_count']
                k['prev_inter_court_count'] +=  j['prev_inter_court_count']
                k['prev_interv_ngo_count'] +=  j['prev_interv_ngo_count']
                k['prev_interv_panch_mem_count'] +=  j['prev_interv_panch_mem_count']
                k['prev_interv_any_other_count'] +=  j['prev_interv_any_other_count']
                # ------------------------------------------------------------------------
            
                k["intervension_by_spec_cell"] += j["intervension_by_spec_cell"]
                # Intervention by the Special Cell
                k['spec_cell_prov_emo_support_count'] +=  j['spec_cell_prov_emo_support_count']
                k['spec_cell_neg_nonvio_with_stakeholder_count'] +=  j['spec_cell_neg_nonvio_with_stakeholder_count']
                k['spec_cell_build_support_system_count'] +=  j['spec_cell_build_support_system_count']
                k['spec_cell_enlist_police_help_count'] +=  j['spec_cell_enlist_police_help_count']
                k['spec_cell_pre­litigation_counsel_count'] +=  j['spec_cell_pre­litigation_counsel_count']
                k['spec_cell_work_with_men_count'] +=  j['spec_cell_work_with_men_count']
                k['spec_cell_adv_fin_ent_count'] +=  j['spec_cell_adv_fin_ent_count']
                k['spec_cell_refferal_for_shelter_count'] +=  j['spec_cell_refferal_for_shelter_count']
                k['spec_cell_dev_counsel_count'] +=  j['spec_cell_dev_counsel_count']
                # ------------------------------
            
                k["intervension_by_spec_cell_ongoing"] += j["intervension_by_spec_cell_ongoing"]
                # Intervention by the Special Cell ongoing ----variable declaration
                k['spec_cell_prov_emo_support_count_ongoing_client'] +=  j['spec_cell_prov_emo_support_count_ongoing_client']
                k['spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client'] +=  j['spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client']
                k['spec_cell_build_support_system_count_ongoing_client'] +=  j['spec_cell_build_support_system_count_ongoing_client']
                k['spec_cell_enlist_police_help_count_ongoing_client'] +=  j['spec_cell_enlist_police_help_count_ongoing_client']
                k['spec_cell_pre­litigation_counsel_count_ongoing_client'] +=  j['spec_cell_pre­litigation_counsel_count_ongoing_client']
                k['spec_cell_work_with_men_count_ongoing_client'] +=  j['spec_cell_work_with_men_count_ongoing_client']
                k['spec_cell_adv_fin_ent_count_ongoing_client'] +=  j['spec_cell_adv_fin_ent_count_ongoing_client']
                k['spec_cell_refferal_for_shelter_count_ongoing_client'] +=  j['spec_cell_refferal_for_shelter_count_ongoing_client']
                k['spec_cell_dev_counsel_count_ongoing_client'] +=  j['spec_cell_dev_counsel_count_ongoing_client']
                # ------------------------------
            
                k["refferals"] += j["refferals"]
                # Refferals --variable declaration
                k['police_refferal_count'] +=  j['police_refferal_count']
                k['medical_refferal_count'] +=  j['medical_refferal_count']
                k['shelter_refferal_count'] +=  j['shelter_refferal_count']
                k['lawer_services_refferal_count'] +=  j['lawer_services_refferal_count']
                k['protection_officer_refferal_count'] +=  j['protection_officer_refferal_count']
                k['court_dlsa_refferal_count'] +=  j['court_dlsa_refferal_count'] 
                k['any_other_refferal_count'] +=  j['any_other_refferal_count']
                # -----------------------------
            
                k["refferals_ongoing"] += j["refferals_ongoing"]
                # Refferals ongoing --variable declaration
                k['police_refferal_count_ongoing_client'] +=  j['police_refferal_count_ongoing_client']
                k['medical_refferal_count_ongoing_client'] +=  j['medical_refferal_count_ongoing_client']
                k['shelter_refferal_count_ongoing_client'] +=  j['shelter_refferal_count_ongoing_client']
                k['lawer_services_refferal_count_ongoing_client'] +=  j['lawer_services_refferal_count_ongoing_client']
                k['protection_officer_refferal_count_ongoing_client'] +=  j['protection_officer_refferal_count_ongoing_client']
                k['court_dlsa_refferal_count_ongoing_client'] +=  j['court_dlsa_refferal_count_ongoing_client'] 
                k['any_other_refferal_count_ongoing_client'] +=  j['any_other_refferal_count_ongoing_client']
                # -----------------------------
            
                k["other_intervention"] += j["other_intervention"]
                #Other interventions in the community  --variable declaration
                k['othr_inter_home_visit_count'] +=  j['othr_inter_home_visit_count']
                k['othr_inter_visit_inst_count'] +=  j['othr_inter_visit_inst_count']
                k['othr_inter_comm_edu_count'] +=  j['othr_inter_comm_edu_count']
                k['othr_inter_meet_local_count'] +=  j['othr_inter_meet_local_count']
                k['othr_inter_inter_with_police_count'] +=  j['othr_inter_inter_with_police_count']
                k['othr_inter_any_other_count'] +=  j['othr_inter_any_other_count']
            
                # -------------------------------
            
                k["outcomes"] += j["outcomes"]
                # Outcomes   --variable declaration
                k['outcomes_helped_in_case_filed_for_divorce_count'] +=  j['outcomes_helped_in_case_filed_for_divorce_count']
                k['outcome_streedhan_retrival_count'] +=  j['outcome_streedhan_retrival_count']
                k['outcome_pwdva_2005_count'] +=  j['outcome_pwdva_2005_count']
                k['outcome_498A_count'] +=  j['outcome_498A_count']
                k['outcome_maintenence_count'] +=  j['outcome_maintenence_count']
                k['outcome_non_violent_recon_count'] +=  j['outcome_non_violent_recon_count']
                k['outcome_court_order_count'] +=  j['outcome_court_order_count']
                k['outcome_any_other_count'] +=  j['outcome_any_other_count']
                # ----------------------------------
            
                k["outcomes_ongoing"] += j["outcomes_ongoing"]
                # Outcomes ongoing --variable declaration
                k['outcomes_helped_in_case_filed_for_divorce_count_ongoing_client'] +=  j['outcomes_helped_in_case_filed_for_divorce_count_ongoing_client']
                k['outcome_streedhan_retrival_count_ongoing_client'] +=  j['outcome_streedhan_retrival_count_ongoing_client']
                k['outcome_pwdva_2005_count_ongoing_client'] +=  j['outcome_pwdva_2005_count_ongoing_client']
                k['outcome_498A_count_ongoing_client'] +=  j['outcome_498A_count_ongoing_client']
                k['outcome_maintenence_count_ongoing_client'] +=  j['outcome_maintenence_count_ongoing_client']
                k['outcome_non_violent_recon_count_ongoing_client'] +=  j['outcome_non_violent_recon_count_ongoing_client']
                k['outcome_court_order_count_ongoing_client'] +=  j['outcome_court_order_count_ongoing_client']
                k['outcome_any_other_count_ongoing_client'] += j['outcome_any_other_count_ongoing_client']
                end
              end 
            end
          end
        end
      end
      @qpr_data = @new_qpr_data
    end  

    if !@qpr_data.empty?
      if @selected == "multi_district_selected" or (@selected == "inner_cell_selected" and @selected_cell.length > 1)
        @qpr_data.push({
          'state' => @selected_state,
          'district' => 'Total',
          'cell' => '',

          'outcomes_sent_back_to_eo_fr_legal_action' => 0,
          'sent_back_to_eo_for_dv_act' => 0,
          'outcomes_sent_back_to_eo_for_mediation' => 0,
          'other_special_cell_clients_reffered_by' => 0,
          'jamat_samaj_jan_panchayat_clients_referred_by' => 0,
          'religious_education_count' => 0,
          'diploma_education_count' => 0,
          'prev_interv_fcc_zpcc' => 0,
          'prev_interv_government_organisation_go' => 0,
          'spcell_negotiating_to_stop_non_violence' => 0,
          'spcell_negotiating_for_non_violence_reconciliation' => 0,
          'spcell_negotiating_for_seperation' => 0,
          'spcell_negotiating_for_divorce' => 0,
          'spcell_negotiating_for_child_custody' => 0,
          'spcell_retrieval_of_streedhan' => 0,
          'spcell_reestablishing_the_woman_s_relationship_to_her_property' => 0,
          'ngo_referral_count' => 0,
          'cbo_referral_count' => 0,
          'go_referral_count' => 0,
          'ngo_referral_count_ongoing_client' => 0,
          'cbo_referral_count_ongoing_client' => 0,
          'go_referral_count_ongoing_client' => 0,
          'othr_inter_representation_on_sexual_harrassment_committee' => 0,
          'outcomes_helped_in_filing_case_for_divorce_seperation' => 0,
          'outcomes_talaq_khula' => 0,
          'outcomes_fir_registered' => 0,
          'outcome_nc_registration' => 0,
          'outcome_child_custody' => 0,
          'outcome_without_court_seperation' => 0,
          'outcomes_helped_in_filing_case_in_court_for_mediation' => 0,
          'outcomes_other_than_498A' => 0,
          'outcome_other_than_498A_count_ongoing_client' => 0,
          'outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients' => 0,

            # / variable declaration/
          'total_client_with_whom_interaction' => 0,
          'ongoing_clients' => 0,
          'one_time_intervention_in_this_quarter' => 0,
          'no_of_ppl_prvded_supp' => 0,
      
          # ------------------
          'total_clients' => 0,
      
          "clients" => 0,
          # / clients reffered by declaration of variables/
          'exclients_count' => 0,
          'self_count' => 0,
          'police_count' => 0,
          'ngo_count' => 0,
          'community_based_org_count' => 0,
          'icw_pw_count' => 0,
          'word_of_mouth_count' => 0,
          'go_count' => 0,
          'lawyers_legal_org_count' => 0,
          'any_other_clients_refferd_count' => 0, 
          # / end------------------------------/
      
          "gender" => 0,
          # Gender of the complainants/ clients ----variable declaration
          'adult_male_count' => 0,
          'adult_female_count' => 0,
          'child_male_count' => 0,
          'child_female_count' => 0,
          'third_gender_count' => 0,
          # -----------------------
      
          "age" => 0,
          # Age of the clients----variable declaration
          'less_than_14_count' => 0,
          'in_15_17_count' => 0,
          'in_18_24_count' => 0,
          'in_25_34_count' => 0,
          'in_35_44_count' => 0,
          'in_45_54_count' => 0,
          'above_55_count' => 0,
          'no_age_info_count' => 0,
          # --------------------
      
          "education" => 0,
          #Education of the clients ----variable declaration
          'non_literate_count' => 0,
          'functional_literacy_count' => 0,
          'primary_level_class_4_count' => 0,
          'upto_ssc_count' => 0,
          'upto_hsc_count' => 0,
          'upto_grad_count' => 0,
          'post_grad_count' => 0,
          'any_other_edu_count' => 0,
          'no_edu_info_count' => 0,
          # ----------------------
      
          "reasons_special_cell" => 0,
          # Reasons for registering at the Special Cell ----variable declaration
          'phy_vio_by_hus_count' => 0,
          'emo_men_vio_by_hus_count' => 0,
          'sex_vio_by_hus_count' => 0,
          'fin_vio_by_hus_count' => 0,
          'sec_marr_by_hus_count' => 0,
          'ref_to_strredhan_by_hus_count' => 0,
          'alch_vio_by_hus_count' => 0,
          'desertion_by_hus_count' => 0,
          'child_custody_vio_count' => 0,
          'phy_vio_by_mart_family_count' => 0,
          'emo_vio_by_mart_family_count' => 0,
          'sex_vio_by_mart_family_count' => 0,
          'fin_vio_by_mart_family_count' => 0,
          'harr_natal_family_by_hus_count' => 0,
          'dep_matr_res_count' => 0,
          'childbattering_count' => 0,
          'dowry_count' => 0,
          'harr_by_natal_family_count' => 0,
          'harr_by_chil_spouse_count' => 0,
          'wife_left_matr_home_count' => 0,
          'harr_at_work_count' => 0,
          'harr_by_live_in_partner_count' => 0,
          'sex_assault_count' => 0,
          'sex_har_in_other_sit_count' => 0,
          'breach_of_trust_count' => 0,
          'harr_by_neigh_count' => 0,
          'any_other_harr_count' => 0,
          # ---------------------------
      
          "prev_inter_bef_comming_to_cell" => 0,
          # Previous intervention before coming to the Cell ----variable declaration
          'prev_inter_natal_family_marital_family_count' => 0,
          'prev_inter_police_count' => 0,
          'prev_inter_court_count' => 0,
          'prev_interv_ngo_count' => 0,
          'prev_interv_panch_mem_count' => 0,
          'prev_interv_any_other_count' => 0,
          # ------------------------------------------------------------------------
      
          "intervension_by_spec_cell" => 0,
          # Intervention by the Special Cell
          'spec_cell_prov_emo_support_count' => 0,
          'spec_cell_neg_nonvio_with_stakeholder_count' => 0,
          'spec_cell_build_support_system_count' => 0,
          'spec_cell_enlist_police_help_count' => 0,
          'spec_cell_pre­litigation_counsel_count' => 0,
          'spec_cell_work_with_men_count' => 0,
          'spec_cell_adv_fin_ent_count' => 0,
          'spec_cell_refferal_for_shelter_count' => 0,
          'spec_cell_dev_counsel_count' => 0,
          # ------------------------------
      
          "intervension_by_spec_cell_ongoing" => 0,
          # Intervention by the Special Cell ongoing ----variable declaration
          'spec_cell_prov_emo_support_count_ongoing_client' => 0,
          'spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client' => 0,
          'spec_cell_build_support_system_count_ongoing_client' => 0,
          'spec_cell_enlist_police_help_count_ongoing_client' => 0,
          'spec_cell_pre­litigation_counsel_count_ongoing_client' => 0,
          'spec_cell_work_with_men_count_ongoing_client' => 0,
          'spec_cell_adv_fin_ent_count_ongoing_client' => 0,
          'spec_cell_refferal_for_shelter_count_ongoing_client' => 0,
          'spec_cell_dev_counsel_count_ongoing_client' => 0,
          # ------------------------------
      
          "refferals" => 0,
          # Refferals --variable declaration
          'police_refferal_count' => 0,
          'medical_refferal_count' => 0,
          'shelter_refferal_count' => 0,
          'lawer_services_refferal_count' => 0,
          'protection_officer_refferal_count' => 0,
          'court_dlsa_refferal_count' => 0, 
          'any_other_refferal_count' => 0,
          # -----------------------------
      
          "refferals_ongoing" => 0,
          # Refferals ongoing --variable declaration
          'police_refferal_count_ongoing_client' => 0,
          'medical_refferal_count_ongoing_client' => 0,
          'shelter_refferal_count_ongoing_client' => 0,
          'lawer_services_refferal_count_ongoing_client' => 0,
          'protection_officer_refferal_count_ongoing_client' => 0,
          'court_dlsa_refferal_count_ongoing_client' => 0, 
          'any_other_refferal_count_ongoing_client' => 0,
          # -----------------------------
      
          "other_intervention" => 0,
          #Other interventions in the community  --variable declaration
          'othr_inter_home_visit_count' => 0,
          'othr_inter_visit_inst_count' => 0,
          'othr_inter_comm_edu_count' => 0,
          'othr_inter_meet_local_count' => 0,
          'othr_inter_inter_with_police_count' => 0,
          'othr_inter_any_other_count' => 0,
      
          # -------------------------------
      
          "outcomes" => 0,
          # Outcomes   --variable declaration
          'outcomes_helped_in_case_filed_for_divorce_count' => 0,
          'outcome_streedhan_retrival_count' => 0,
          'outcome_pwdva_2005_count' => 0,
          'outcome_498A_count' => 0,
          'outcome_maintenence_count' => 0,
          'outcome_non_violent_recon_count' => 0,
          'outcome_court_order_count' => 0,
          'outcome_any_other_count' => 0,
          # ----------------------------------
      
          "outcomes_ongoing" => 0,
          # Outcomes ongoing --variable declaration
          'outcomes_helped_in_case_filed_for_divorce_count_ongoing_client' => 0,
          'outcome_streedhan_retrival_count_ongoing_client' => 0,
          'outcome_pwdva_2005_count_ongoing_client' => 0,
          'outcome_498A_count_ongoing_client' => 0,
          'outcome_maintenence_count_ongoing_client' => 0,
          'outcome_non_violent_recon_count_ongoing_client' => 0,
          'outcome_court_order_count_ongoing_client' => 0,
          'outcome_any_other_count_ongoing_client' => 0
        })
      end

      report_length = @qpr_data.length
      index_count = 0


      for j in @qpr_data
        index_count += 1
        if index_count != report_length
         @qpr_data[report_length-1]['total_client_with_whom_interaction']  += j['total_client_with_whom_interaction']
         @qpr_data[report_length-1]['ongoing_clients'] +=  j['ongoing_clients']
         @qpr_data[report_length-1]['one_time_intervention_in_this_quarter'] +=  j['one_time_intervention_in_this_quarter']
         @qpr_data[report_length-1]['no_of_ppl_prvded_supp'] +=  j['no_of_ppl_prvded_supp']

         @qpr_data[report_length-1]['outcomes_sent_back_to_eo_fr_legal_action'] += j['outcomes_sent_back_to_eo_fr_legal_action']
         @qpr_data[report_length-1]['sent_back_to_eo_for_dv_act'] += j['sent_back_to_eo_for_dv_act']
         @qpr_data[report_length-1]['outcomes_sent_back_to_eo_for_mediation'] += j['outcomes_sent_back_to_eo_for_mediation']
         @qpr_data[report_length-1]['other_special_cell_clients_reffered_by'] += j['other_special_cell_clients_reffered_by']
         @qpr_data[report_length-1]['jamat_samaj_jan_panchayat_clients_referred_by'] += j['jamat_samaj_jan_panchayat_clients_referred_by']
         @qpr_data[report_length-1]['religious_education_count'] += j['religious_education_count']
         @qpr_data[report_length-1]['diploma_education_count'] += j['diploma_education_count']
         @qpr_data[report_length-1]['prev_interv_fcc_zpcc'] += j['prev_interv_fcc_zpcc']
         @qpr_data[report_length-1]['prev_interv_government_organisation_go'] += j['prev_interv_government_organisation_go']
         @qpr_data[report_length-1]['spcell_negotiating_to_stop_non_violence'] += j['spcell_negotiating_to_stop_non_violence']
         @qpr_data[report_length-1]['spcell_negotiating_for_non_violence_reconciliation'] += j['spcell_negotiating_for_non_violence_reconciliation']
         @qpr_data[report_length-1]['spcell_negotiating_for_seperation'] += j['spcell_negotiating_for_seperation']
         @qpr_data[report_length-1]['spcell_negotiating_for_divorce'] += j['spcell_negotiating_for_divorce']
         @qpr_data[report_length-1]['spcell_negotiating_for_child_custody'] += j['spcell_negotiating_for_child_custody']
         @qpr_data[report_length-1]['spcell_retrieval_of_streedhan'] += j['spcell_retrieval_of_streedhan']
         @qpr_data[report_length-1]['spcell_reestablishing_the_woman_s_relationship_to_her_property'] += j['spcell_reestablishing_the_woman_s_relationship_to_her_property']
         @qpr_data[report_length-1]['ngo_referral_count'] += j['ngo_referral_count']
         @qpr_data[report_length-1]['cbo_referral_count'] += j['cbo_referral_count']
         @qpr_data[report_length-1]['go_referral_count'] += j['go_referral_count']
         @qpr_data[report_length-1]['ngo_referral_count_ongoing_client'] += j['ngo_referral_count_ongoing_client']
         @qpr_data[report_length-1]['cbo_referral_count_ongoing_client'] += j['cbo_referral_count_ongoing_client']
         @qpr_data[report_length-1]['go_referral_count_ongoing_client'] += j['go_referral_count_ongoing_client']
         @qpr_data[report_length-1]['othr_inter_representation_on_sexual_harrassment_committee'] += j['othr_inter_representation_on_sexual_harrassment_committee']
         @qpr_data[report_length-1]['outcomes_helped_in_filing_case_for_divorce_seperation'] += j['outcomes_helped_in_filing_case_for_divorce_seperation']
         @qpr_data[report_length-1]['outcomes_talaq_khula'] += j['outcomes_talaq_khula']
         @qpr_data[report_length-1]['outcomes_fir_registered'] += j['outcomes_fir_registered']
         @qpr_data[report_length-1]['outcome_nc_registration'] += j['outcome_nc_registration']
         @qpr_data[report_length-1]['outcome_child_custody'] += j['outcome_child_custody']
         @qpr_data[report_length-1]['outcome_without_court_seperation'] += j['outcome_without_court_seperation']
         @qpr_data[report_length-1]['outcomes_helped_in_filing_case_in_court_for_mediation'] += j['outcomes_helped_in_filing_case_in_court_for_mediation']
         @qpr_data[report_length-1]['outcomes_other_than_498A'] += j['outcomes_other_than_498A']
         @qpr_data[report_length-1]['outcome_other_than_498A_count_ongoing_client'] += j['outcome_other_than_498A_count_ongoing_client']
         @qpr_data[report_length-1]['outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients'] += j['outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients']

      
          # ------------------
         @qpr_data[report_length-1]['total_clients'] +=  j['total_clients']
      
         @qpr_data[report_length-1]['clients'] +=  j['clients']
          # / clients reffered by declaration of variables/
         @qpr_data[report_length-1]['exclients_count'] +=  j['exclients_count']
         @qpr_data[report_length-1]['self_count'] +=  j['self_count']
         @qpr_data[report_length-1]['police_count'] +=  j['police_count']
         @qpr_data[report_length-1]['ngo_count'] +=  j['ngo_count']
         @qpr_data[report_length-1]['community_based_org_count'] +=  j['community_based_org_count']
         @qpr_data[report_length-1]['icw_pw_count'] +=  j['icw_pw_count']
         @qpr_data[report_length-1]['word_of_mouth_count'] +=  j['word_of_mouth_count']
         @qpr_data[report_length-1]['go_count'] +=  j['go_count']
         @qpr_data[report_length-1]['lawyers_legal_org_count'] +=  j['lawyers_legal_org_count']
         @qpr_data[report_length-1]['any_other_clients_refferd_count'] +=  j['any_other_clients_refferd_count'] 
          # / end------------------------------/
      
          @qpr_data[report_length-1]['gender'] +=  j['gender']
          # Gender of the complainants/ clients ----variable declaration
         @qpr_data[report_length-1]['adult_male_count'] +=  j['adult_male_count']
         @qpr_data[report_length-1]['adult_female_count'] +=  j['adult_female_count']
         @qpr_data[report_length-1]['child_male_count'] +=  j['child_male_count']
         @qpr_data[report_length-1]['child_female_count'] +=  j['child_female_count']
         @qpr_data[report_length-1]['third_gender_count'] +=  j['third_gender_count']
          # -----------------------
      
          @qpr_data[report_length-1]['age'] +=  j['age']
          # Age of the clients----variable declaration
         @qpr_data[report_length-1]['less_than_14_count'] +=  j['less_than_14_count']
         @qpr_data[report_length-1]['in_15_17_count'] +=  j['in_15_17_count']
         @qpr_data[report_length-1]['in_18_24_count'] +=  j['in_18_24_count']
         @qpr_data[report_length-1]['in_25_34_count'] +=  j['in_25_34_count']
         @qpr_data[report_length-1]['in_35_44_count'] +=  j['in_35_44_count']
         @qpr_data[report_length-1]['in_45_54_count'] +=  j['in_45_54_count']
         @qpr_data[report_length-1]['above_55_count'] +=  j['above_55_count']
         @qpr_data[report_length-1]['no_age_info_count'] +=  j['no_age_info_count']
          # --------------------
      
          @qpr_data[report_length-1]['education'] +=  j['education']
          #Education of the clients ----variable declaration
         @qpr_data[report_length-1]['non_literate_count'] +=  j['non_literate_count']
         @qpr_data[report_length-1]['functional_literacy_count'] +=  j['functional_literacy_count']
         @qpr_data[report_length-1]['primary_level_class_4_count'] +=  j['primary_level_class_4_count']
         @qpr_data[report_length-1]['upto_ssc_count'] +=  j['upto_ssc_count']
         @qpr_data[report_length-1]['upto_hsc_count'] +=  j['upto_hsc_count']
         @qpr_data[report_length-1]['upto_grad_count'] +=  j['upto_grad_count']
         @qpr_data[report_length-1]['post_grad_count'] +=  j['post_grad_count']
         @qpr_data[report_length-1]['any_other_edu_count'] +=  j['any_other_edu_count']
         @qpr_data[report_length-1]['no_edu_info_count'] +=  j['no_edu_info_count']
          # ----------------------
      
          @qpr_data[report_length-1]['reasons_special_cell'] +=  j['reasons_special_cell']
          # Reasons for registering at the Special Cell ----variable declaration
         @qpr_data[report_length-1]['phy_vio_by_hus_count'] +=  j['phy_vio_by_hus_count']
         @qpr_data[report_length-1]['emo_men_vio_by_hus_count'] +=  j['emo_men_vio_by_hus_count']
         @qpr_data[report_length-1]['sex_vio_by_hus_count'] +=  j['sex_vio_by_hus_count']
         @qpr_data[report_length-1]['fin_vio_by_hus_count'] +=  j['fin_vio_by_hus_count']
         @qpr_data[report_length-1]['sec_marr_by_hus_count'] +=  j['sec_marr_by_hus_count']
         @qpr_data[report_length-1]['ref_to_strredhan_by_hus_count'] +=  j['ref_to_strredhan_by_hus_count']
         @qpr_data[report_length-1]['alch_vio_by_hus_count'] +=  j['alch_vio_by_hus_count']
         @qpr_data[report_length-1]['desertion_by_hus_count'] +=  j['desertion_by_hus_count']
         @qpr_data[report_length-1]['child_custody_vio_count'] +=  j['child_custody_vio_count']
         @qpr_data[report_length-1]['phy_vio_by_mart_family_count'] +=  j['phy_vio_by_mart_family_count']
         @qpr_data[report_length-1]['emo_vio_by_mart_family_count'] +=  j['emo_vio_by_mart_family_count']
         @qpr_data[report_length-1]['sex_vio_by_mart_family_count'] +=  j['sex_vio_by_mart_family_count']
         @qpr_data[report_length-1]['fin_vio_by_mart_family_count'] +=  j['fin_vio_by_mart_family_count']
         @qpr_data[report_length-1]['harr_natal_family_by_hus_count'] +=  j['harr_natal_family_by_hus_count']
         @qpr_data[report_length-1]['dep_matr_res_count'] +=  j['dep_matr_res_count']
         @qpr_data[report_length-1]['childbattering_count'] +=  j['childbattering_count']
         @qpr_data[report_length-1]['dowry_count'] +=  j['dowry_count']
         @qpr_data[report_length-1]['harr_by_natal_family_count'] +=  j['harr_by_natal_family_count']
         @qpr_data[report_length-1]['harr_by_chil_spouse_count'] +=  j['harr_by_chil_spouse_count']
         @qpr_data[report_length-1]['wife_left_matr_home_count'] +=  j['wife_left_matr_home_count']
         @qpr_data[report_length-1]['harr_at_work_count'] +=  j['harr_at_work_count']
         @qpr_data[report_length-1]['harr_by_live_in_partner_count'] +=  j['harr_by_live_in_partner_count']
         @qpr_data[report_length-1]['sex_assault_count'] +=  j['sex_assault_count']
         @qpr_data[report_length-1]['sex_har_in_other_sit_count'] +=  j['sex_har_in_other_sit_count']
         @qpr_data[report_length-1]['breach_of_trust_count'] +=  j['breach_of_trust_count']
         @qpr_data[report_length-1]['harr_by_neigh_count'] +=  j['harr_by_neigh_count']
         @qpr_data[report_length-1]['any_other_harr_count'] +=  j['any_other_harr_count']
          # ---------------------------
      
          @qpr_data[report_length-1]['prev_inter_bef_comming_to_cell'] +=  j['prev_inter_bef_comming_to_cell']
          # Previous intervention before coming to the Cell ----variable declaration
         @qpr_data[report_length-1]['prev_inter_natal_family_marital_family_count'] +=  j['prev_inter_natal_family_marital_family_count']
         @qpr_data[report_length-1]['prev_inter_police_count'] +=  j['prev_inter_police_count']
         @qpr_data[report_length-1]['prev_inter_court_count'] +=  j['prev_inter_court_count']
         @qpr_data[report_length-1]['prev_interv_ngo_count'] +=  j['prev_interv_ngo_count']
         @qpr_data[report_length-1]['prev_interv_panch_mem_count'] +=  j['prev_interv_panch_mem_count']
         @qpr_data[report_length-1]['prev_interv_any_other_count'] +=  j['prev_interv_any_other_count']
          # ------------------------------------------------------------------------
      
          @qpr_data[report_length-1]['intervension_by_spec_cell'] +=  j['intervension_by_spec_cell']
          # Intervention by the Special Cell
         @qpr_data[report_length-1]['spec_cell_prov_emo_support_count'] +=  j['spec_cell_prov_emo_support_count']
         @qpr_data[report_length-1]['spec_cell_neg_nonvio_with_stakeholder_count'] +=  j['spec_cell_neg_nonvio_with_stakeholder_count']
         @qpr_data[report_length-1]['spec_cell_build_support_system_count'] +=  j['spec_cell_build_support_system_count']
         @qpr_data[report_length-1]['spec_cell_enlist_police_help_count'] +=  j['spec_cell_enlist_police_help_count']
         @qpr_data[report_length-1]['spec_cell_pre­litigation_counsel_count'] +=  j['spec_cell_pre­litigation_counsel_count']
         @qpr_data[report_length-1]['spec_cell_work_with_men_count'] +=  j['spec_cell_work_with_men_count']
         @qpr_data[report_length-1]['spec_cell_adv_fin_ent_count'] +=  j['spec_cell_adv_fin_ent_count']
         @qpr_data[report_length-1]['spec_cell_refferal_for_shelter_count'] +=  j['spec_cell_refferal_for_shelter_count']
         @qpr_data[report_length-1]['spec_cell_dev_counsel_count'] +=  j['spec_cell_dev_counsel_count']
          # ------------------------------
      
          @qpr_data[report_length-1]['intervension_by_spec_cell_ongoing'] +=  j['intervension_by_spec_cell_ongoing']
          # Intervention by the Special Cell ongoing ----variable declaration
         @qpr_data[report_length-1]['spec_cell_prov_emo_support_count_ongoing_client'] +=  j['spec_cell_prov_emo_support_count_ongoing_client']
         @qpr_data[report_length-1]['spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client'] +=  j['spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client']
         @qpr_data[report_length-1]['spec_cell_build_support_system_count_ongoing_client'] +=  j['spec_cell_build_support_system_count_ongoing_client']
         @qpr_data[report_length-1]['spec_cell_enlist_police_help_count_ongoing_client'] +=  j['spec_cell_enlist_police_help_count_ongoing_client']
         @qpr_data[report_length-1]['spec_cell_pre­litigation_counsel_count_ongoing_client'] +=  j['spec_cell_pre­litigation_counsel_count_ongoing_client']
         @qpr_data[report_length-1]['spec_cell_work_with_men_count_ongoing_client'] +=  j['spec_cell_work_with_men_count_ongoing_client']
         @qpr_data[report_length-1]['spec_cell_adv_fin_ent_count_ongoing_client'] +=  j['spec_cell_adv_fin_ent_count_ongoing_client']
         @qpr_data[report_length-1]['spec_cell_refferal_for_shelter_count_ongoing_client'] +=  j['spec_cell_refferal_for_shelter_count_ongoing_client']
         @qpr_data[report_length-1]['spec_cell_dev_counsel_count_ongoing_client'] +=  j['spec_cell_dev_counsel_count_ongoing_client']
          # ------------------------------
      
          @qpr_data[report_length-1]['refferals'] +=  j['refferals']
          # Refferals --variable declaration
         @qpr_data[report_length-1]['police_refferal_count'] +=  j['police_refferal_count']
         @qpr_data[report_length-1]['medical_refferal_count'] +=  j['medical_refferal_count']
         @qpr_data[report_length-1]['shelter_refferal_count'] +=  j['shelter_refferal_count']
         @qpr_data[report_length-1]['lawer_services_refferal_count'] +=  j['lawer_services_refferal_count']
         @qpr_data[report_length-1]['protection_officer_refferal_count'] +=  j['protection_officer_refferal_count']
         @qpr_data[report_length-1]['court_dlsa_refferal_count'] +=  j['court_dlsa_refferal_count'] 
         @qpr_data[report_length-1]['any_other_refferal_count'] +=  j['any_other_refferal_count']
          # -----------------------------
      
          @qpr_data[report_length-1]['refferals_ongoing'] +=  j['refferals_ongoing']
          # Refferals ongoing --variable declaration
         @qpr_data[report_length-1]['police_refferal_count_ongoing_client'] +=  j['police_refferal_count_ongoing_client']
         @qpr_data[report_length-1]['medical_refferal_count_ongoing_client'] +=  j['medical_refferal_count_ongoing_client']
         @qpr_data[report_length-1]['shelter_refferal_count_ongoing_client'] +=  j['shelter_refferal_count_ongoing_client']
         @qpr_data[report_length-1]['lawer_services_refferal_count_ongoing_client'] +=  j['lawer_services_refferal_count_ongoing_client']
         @qpr_data[report_length-1]['protection_officer_refferal_count_ongoing_client'] +=  j['protection_officer_refferal_count_ongoing_client']
         @qpr_data[report_length-1]['court_dlsa_refferal_count_ongoing_client'] +=  j['court_dlsa_refferal_count_ongoing_client'] 
         @qpr_data[report_length-1]['any_other_refferal_count_ongoing_client'] +=  j['any_other_refferal_count_ongoing_client']
          # -----------------------------
      
          @qpr_data[report_length-1]['other_intervention'] +=  j['other_intervention']
          #Other interventions in the community  --variable declaration
         @qpr_data[report_length-1]['othr_inter_home_visit_count'] +=  j['othr_inter_home_visit_count']
         @qpr_data[report_length-1]['othr_inter_visit_inst_count'] +=  j['othr_inter_visit_inst_count']
         @qpr_data[report_length-1]['othr_inter_comm_edu_count'] +=  j['othr_inter_comm_edu_count']
         @qpr_data[report_length-1]['othr_inter_meet_local_count'] +=  j['othr_inter_meet_local_count']
         @qpr_data[report_length-1]['othr_inter_inter_with_police_count'] +=  j['othr_inter_inter_with_police_count']
         @qpr_data[report_length-1]['othr_inter_any_other_count'] +=  j['othr_inter_any_other_count']
      
          # -------------------------------
      
          @qpr_data[report_length-1]['outcomes'] +=  j['outcomes']
          # Outcomes   --variable declaration
         @qpr_data[report_length-1]['outcomes_helped_in_case_filed_for_divorce_count'] +=  j['outcomes_helped_in_case_filed_for_divorce_count']
         @qpr_data[report_length-1]['outcome_streedhan_retrival_count'] +=  j['outcome_streedhan_retrival_count']
         @qpr_data[report_length-1]['outcome_pwdva_2005_count'] +=  j['outcome_pwdva_2005_count']
         @qpr_data[report_length-1]['outcome_498A_count'] +=  j['outcome_498A_count']
         @qpr_data[report_length-1]['outcome_maintenence_count'] +=  j['outcome_maintenence_count']
         @qpr_data[report_length-1]['outcome_non_violent_recon_count'] +=  j['outcome_non_violent_recon_count']
         @qpr_data[report_length-1]['outcome_court_order_count'] +=  j['outcome_court_order_count']
         @qpr_data[report_length-1]['outcome_any_other_count'] +=  j['outcome_any_other_count']
          # ----------------------------------
      
        @qpr_data[report_length-1]['outcomes_ongoing'] +=  j['outcomes_ongoing']
          # Outcomes ongoing --variable declaration
         @qpr_data[report_length-1]['outcomes_helped_in_case_filed_for_divorce_count_ongoing_client'] +=  j['outcomes_helped_in_case_filed_for_divorce_count_ongoing_client']
         @qpr_data[report_length-1]['outcome_streedhan_retrival_count_ongoing_client'] +=  j['outcome_streedhan_retrival_count_ongoing_client']
         @qpr_data[report_length-1]['outcome_pwdva_2005_count_ongoing_client'] +=  j['outcome_pwdva_2005_count_ongoing_client']
         @qpr_data[report_length-1]['outcome_498A_count_ongoing_client'] +=  j['outcome_498A_count_ongoing_client']
         @qpr_data[report_length-1]['outcome_maintenence_count_ongoing_client'] +=  j['outcome_maintenence_count_ongoing_client']
         @qpr_data[report_length-1]['outcome_non_violent_recon_count_ongoing_client'] +=  j['outcome_non_violent_recon_count_ongoing_client']
         @qpr_data[report_length-1]['outcome_court_order_count_ongoing_client'] +=  j['outcome_court_order_count_ongoing_client']
         @qpr_data[report_length-1]['outcome_any_other_count_ongoing_client'] += j['outcome_any_other_count_ongoing_client']
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

    @array_length = @qpr_data.length*2 + 2
    end_date = (Date.parse(end_date)-1).to_s
    @end_date_for_display = end_date
    @start_date_for_display = start_date

    @start_date_in_pdf=Date.parse(start_date).strftime("%d-%m-%Y")
    @end_date_in_pdf=Date.parse(end_date).strftime("%d-%m-%Y")

    @year_to_display = Date.parse(start_date).strftime("%Y")
    @start_date_for_display = Date.parse(start_date)
    @month_to_display = Date.parse(end_date).strftime("%m")
    @month = ""
    for i in MONTH_ARRAY
      if i[1] == @month_to_display
        @month = i[0]
        break
      end  
    end

    s_n = @state_name.downcase
    render "one_time_intervention"
    # showing districts and cells 
    # @data.push(@police_count,@exclients_count,@word_of_mouth_count,@self_count,@lawyers_legal_org_count,@ngo_count,@go_count,@icw_pw_count,@any_other_count,@one_time_intervention_count,@home_visit_count,@collateral_visits_count,@individual_meeting_count,@group_meeting_count,@participation_count,@programs_organised_count,@conducted_session_or_prog_count,@police_reffered_to_count,@medical_count,@shelter_count,@legal_services_count,@protection_officer_count,@lok_shiyakat_niwaran_count,@on_going_intevention_count,@engaing_police_help_count,@state_in_pdf,@district_in_pdf,@start_date_in_pdf,@end_date_in_pdf)
  end

  def check_key_present(state,district_list,start_date,end_date, main_district,selected)
    for i in district_list
      x = i.to_sym
      # if will be false if selected cells doesnt have multiple locations.
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
            calculate_qpr state, j[1], start_date, end_date, main_district, selected
          end
        end
      elsif @location_map_array.has_key? (state.to_sym)
        location = @location_map_array[state.to_sym]
        check_cell_present=0
        for j in location
          if j[1] == i
            check_cell_present += 1 
            calculate_qpr state, j[1], start_date, end_date, j[0], selected
            break
          end
        end

        if check_cell_present == 0
          calculate_qpr state, i , start_date, end_date, main_district, selected
        end
      end
    end
  end

  def calculate_qpr(state,district,start_date,end_date,main_district, selected)

    @outcomes_sent_back_to_eo_fr_legal_action = 0
    @sent_back_to_eo_for_dv_act = 0
    @outcomes_sent_back_to_eo_for_mediation = 0

    @other_special_cell_clients_reffered_by = 0
    @jamat_samaj_jan_panchayat_clients_referred_by = 0
    @religious_education_count = 0
    @diploma_education_count = 0
    @prev_interv_fcc_zpcc = 0
    @prev_interv_government_organisation_go = 0
    @spcell_negotiating_to_stop_non_violence = 0
    @spcell_negotiating_for_non_violence_reconciliation = 0
    @spcell_negotiating_for_seperation = 0
    @spcell_negotiating_for_divorce = 0
    @spcell_negotiating_for_child_custody = 0
    @spcell_retrieval_of_streedhan = 0
    @spcell_reestablishing_the_woman_s_relationship_to_her_property = 0
    @ngo_referral_count = 0
    @cbo_referral_count = 0
    @go_referral_count = 0
    @ngo_referral_count_ongoing_client = 0
    @cbo_referral_count_ongoing_client = 0
    @go_referral_count_ongoing_client = 0
    @othr_inter_representation_on_sexual_harrassment_committee = 0
    @outcomes_helped_in_filing_case_for_divorce_seperation = 0
    @outcomes_talaq_khula = 0
    @outcomes_fir_registered = 0
    @outcome_nc_registration = 0
    @outcome_child_custody = 0
    @outcome_without_court_seperation = 0
    @outcomes_helped_in_filing_case_in_court_for_mediation = 0
    @outcomes_other_than_498A = 0
    @outcome_other_than_498A_count_ongoing_client = 0
    @outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients = 0


      # / variable declaration/
    @total_client_with_whom_interaction=0
    @ongoing_clients=0
    @one_time_intervention_in_this_quarter=0
    @no_of_ppl_prvded_supp=0

    # ------------------
    @total_clients=0

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
    @any_other_clients_refferd_count=0 
    # / end------------------------------/

    # Gender of the complainants/ clients ----variable declaration
    @adult_male_count=0
    @adult_female_count=0
    @child_male_count=0
    @child_female_count=0
    @third_gender_count=0
    # -----------------------

    # Age of the clients----variable declaration
    @less_than_14_count=0
    @in_15_17_count=0
    @in_18_24_count=0
    @in_25_34_count=0
    @in_35_44_count=0
    @in_45_54_count=0
    @above_55_count=0
    @no_age_info_count=0
    # --------------------

    #Education of the clients ----variable declaration
    @non_literate_count=0
    @functional_literacy_count=0
    @primary_level_class_4_count=0
    @upto_ssc_count=0
    @upto_hsc_count=0
    @upto_grad_count=0
    @post_grad_count=0
    @any_other_edu_count=0
    @no_edu_info_count=0
    # ----------------------

    # Reasons for registering at the Special Cell ----variable declaration
    @phy_vio_by_hus_count=0
    @emo_men_vio_by_hus_count=0
    @sex_vio_by_hus_count=0
    @fin_vio_by_hus_count=0
    @sec_marr_by_hus_count=0
    @ref_to_strredhan_by_hus_count=0
    @alch_vio_by_hus_count=0
    @desertion_by_hus_count=0
    @child_custody_vio_count=0
    @phy_vio_by_mart_family_count=0
    @emo_vio_by_mart_family_count=0
    @sex_vio_by_mart_family_count=0
    @fin_vio_by_mart_family_count=0
    @harr_natal_family_by_hus_count=0
    @dep_matr_res_count=0
    @childbattering_count=0
    @dowry_count=0
    @harr_by_natal_family_count=0
    @harr_by_chil_spouse_count=0
    @wife_left_matr_home_count=0
    @harr_at_work_count=0
    @harr_by_live_in_partner_count=0
    @sex_assault_count=0
    @sex_har_in_other_sit_count=0
    @breach_of_trust_count=0
    @harr_by_neigh_count=0
    @any_other_harr_count=0
    # ---------------------------

    # Previous intervention before coming to the Cell ----variable declaration
    @prev_inter_natal_family_marital_family_count=0
    @prev_inter_police_count=0
    @prev_inter_court_count=0
    @prev_interv_ngo_count=0
    @prev_interv_panch_mem_count=0
    @prev_interv_any_other_count=0
    # ------------------------------------------------------------------------

    # Intervention by the Special Cell
    @spec_cell_prov_emo_support_count=0
    @spec_cell_neg_nonvio_with_stakeholder_count=0
    @spec_cell_build_support_system_count=0
    @spec_cell_enlist_police_help_count=0
    @spec_cell_pre­litigation_counsel_count=0
    @spec_cell_work_with_men_count=0
    @spec_cell_adv_fin_ent_count=0
    @spec_cell_refferal_for_shelter_count=0
    @spec_cell_dev_counsel_count=0
    # ------------------------------

    # Intervention by the Special Cell ongoing ----variable declaration
    @spec_cell_prov_emo_support_count_ongoing_client=0
    @spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client=0
    @spec_cell_build_support_system_count_ongoing_client=0
    @spec_cell_enlist_police_help_count_ongoing_client=0
    @spec_cell_pre­litigation_counsel_count_ongoing_client=0
    @spec_cell_work_with_men_count_ongoing_client=0
    @spec_cell_adv_fin_ent_count_ongoing_client=0
    @spec_cell_refferal_for_shelter_count_ongoing_client=0
    @spec_cell_dev_counsel_count_ongoing_client=0
    # ------------------------------

    # Refferals --variable declaration
    @police_refferal_count=0
    @medical_refferal_count=0
    @shelter_refferal_count=0
    @lawer_services_refferal_count=0
    @protection_officer_refferal_count=0
    @court_dlsa_refferal_count=0 
    @any_other_refferal_count=0
    # -----------------------------

    # Refferals ongoing --variable declaration
    @police_refferal_count_ongoing_client=0
    @medical_refferal_count_ongoing_client=0
    @shelter_refferal_count_ongoing_client=0
    @lawer_services_refferal_count_ongoing_client=0
    @protection_officer_refferal_count_ongoing_client=0
    @court_dlsa_refferal_count_ongoing_client=0 
    @any_other_refferal_count_ongoing_client=0
    # -----------------------------

    #Other interventions in the community  --variable declaration
    @othr_inter_home_visit_count=0
    @othr_inter_visit_inst_count=0
    @othr_inter_comm_edu_count=0
    @othr_inter_meet_local_count=0
    @othr_inter_inter_with_police_count=0
    @othr_inter_any_other_count=0

    # -------------------------------

    # Outcomes   --variable declaration
    @outcomes_helped_in_case_filed_for_divorce_count=0
    @outcome_streedhan_retrival_count=0
    @outcome_pwdva_2005_count=0
    @outcome_498A_count=0
    @outcome_maintenence_count=0
    @outcome_non_violent_recon_count=0
    @outcome_court_order_count=0
    @outcome_any_other_count=0
    # ----------------------------------

    # Outcomes ongoing --variable declaration
    @outcomes_helped_in_case_filed_for_divorce_count_ongoing_client=0
    @outcome_streedhan_retrival_count_ongoing_client=0
    @outcome_pwdva_2005_count_ongoing_client=0
    @outcome_498A_count_ongoing_client=0
    @outcome_maintenence_count_ongoing_client=0
    @outcome_non_violent_recon_count_ongoing_client=0
    @outcome_court_order_count_ongoing_client=0
    @outcome_any_other_count_ongoing_client = 0
    # ----------------------------------

  
    # /checking state and on that basis getting the first district and last district for view query/
    if district.empty?
      # total_clients_in_this_quarter = Child.by_state_date_clients_registered_in_this_quarter.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']
      # new_registered_application_that_was_previously_one_time_intervention = Child.by_state_date_new_registered_application_that_was_previously_one_time_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']
      # total_clients_with_whom_interaction = Child.by_state_date_clients_registered_in_this_quarter.startkey([state]).endkey([state,{}])['rows']
      # one_time_intervention_array= Child.by_state_date_onetime_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']
      clients_reffered_by = Child.by_state_date_clients_reffered_by_one_time_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      gender_of_complaint = Child.by_state_date_gender_of_complaint_one_time_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      age_of_client = Child.by_state_date_age_of_client_one_time_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      education_of_client = Child.by_state_date_client_education_one_time_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      # reasons_fr_reg_at_spec_cell = Child.by_state_date_reasons_for_registering_at_the_special_cell.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      # vio_by_husband = Child.by_state_date_vio_by_husband.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      # vio_by_marital_family = Child.by_state_date_vio_by_martial_family.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      previous_intervention_before_coming_to_the_cell = Child.by_state_date_previous_intervention_before_coming_to_the_cell_one_time_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      intervention_by_special_cell = Child.by_state_date_intervention_by_special_cell_one_time_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      # negotiating_nonviolence = Child.by_state_date_negotiating_nonviolence_one_time_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      referrals_new_clients_ongoing_clients = Child.by_state_date_referrals_new_clients_ongoing_clients_one_time_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      # other_interventions_taking_place_outside_the_cell = Child.by_state_date_other_interventions_taking_place_outside_the_cell.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      # outcomes_new_clients_ongoing_clients = Child.by_state_date_outcomes_new_clients_ongoing_clients.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      # other_negotiations = Child.by_state_date_other_negotiations.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      # helped_in_filing_for_divorceseparationtalaqkhula = Child.by_state_date_helped_in_filing_for_divorceseparationtalaqkhula.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      # helped_in_filing_case_in_court_for_divorceseparationmediation = Child.by_state_date_helped_in_filing_case_in_court_for_divorceseparationmediation.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      # cases_sent_back_to_eo = Child.by_state_date_cases_sent_back_to_eo.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      # helped_the_woman_in_accessing_her_financial_entitlements = Child.by_state_date_helped_the_woman_in_accessing_her_financial_entitlements.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']

    else
      # total_clients_in_this_quarter = Child.by_clients_registered_in_this_quarter.startkey([state,district,start_date]).endkey([state,district,end_date,{}])['rows']
      # new_registered_application_that_was_previously_one_time_intervention = Child.by_new_registered_application_that_was_previously_one_time_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # total_clients_with_whom_interaction = Child.by_clients_registered_in_this_quarter.startkey([state,district]).endkey([state,district,{}])['rows']
      # one_time_intervention_array= Child.by_onetime_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}])['rows']
      clients_reffered_by = Child.by_clients_reffered_by_one_time_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      gender_of_complaint = Child.by_gender_of_complaint_one_time_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      age_of_client = Child.by_age_of_client_one_time_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      education_of_client = Child.by_client_education_one_time_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # reasons_fr_reg_at_spec_cell = Child.by_reasons_for_registering_at_the_special_cell.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # vio_by_husband = Child.by_vio_by_husband.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # vio_by_marital_family = Child.by_vio_by_marital_family.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      previous_intervention_before_coming_to_the_cell = Child.by_previous_intervention_before_coming_to_the_cell_one_time_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      intervention_by_special_cell = Child.by_intervention_by_special_cell_one_time_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # negotiating_nonviolence = Child.by_negotiating_nonviolence_one_time_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      referrals_new_clients_ongoing_clients = Child.by_referrals_new_clients_ongoing_clients_one_time_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # other_interventions_taking_place_outside_the_cell = Child.by_other_interventions_taking_place_outside_the_cell.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # outcomes_new_clients_ongoing_clients = Child.by_outcomes_new_clients_ongoing_clients.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # other_negotiations = Child.by_other_negotiations.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # helped_in_filing_for_divorceseparationtalaqkhula = Child.by_helped_in_filing_for_divorceseparationtalaqkhula.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # helped_in_filing_case_in_court_for_divorceseparationmediation = Child.by_helped_in_filing_case_in_court_for_divorceseparationmediation.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # cases_sent_back_to_eo = Child.by_cases_sent_back_to_eo.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      # helped_the_woman_in_accessing_her_financial_entitlements = Child.helped_the_woman_in_accessing_her_financial_entitlements.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']

    end
    # /end----------------------------------------------/
    
    # for i in total_clients_in_this_quarter
    #   @total_clients += i['value']
    # end  

    # for i in total_clients_with_whom_interaction
    #   @total_client_with_whom_interaction += i['value']
    # end

    # for i in one_time_intervention_array  
    #   @one_time_intervention_in_this_quarter += i['value']
    # end

    # calculation of clients reffered by
    for i in clients_reffered_by
      if !i['key'][0].empty? && !i['key'][2].empty? 
        if i['key'][3]!=nil
          if i['key'][3].include? "ex_clients"
            @exclients_count += i['value']
          elsif i['key'][3].include? "independent_community_worker_political_worker"
            @icw_pw_count += i['value']
          elsif i['key'][3].include? "other_special_cell_90276"
            @other_special_cell_clients_reffered_by += i['value']
          elsif i['key'][3].include? "police"
            @police_count += i['value']
          elsif i['key'][3].include? "self"
            @self_count += i['value']
          elsif i['key'][3].include? "word_of_mouth"
            @word_of_mouth_count += i['value']
          elsif i['key'][3].include? "government_organisation_go"
            @go_count += i['value']
          elsif i['key'][3].include? "non_governmental_organisation_ngo"
            @ngo_count += i['value']
          elsif i['key'][3].include? "lawyers_legal_organisations"
            @lawyers_legal_org_count += i['value']
          elsif i['key'][3].include? "community_based_organisations"
            @community_based_org_count += i['value']
          elsif i['key'][3].include? "jamat_samaj_jat_panchayat"
            @jamat_samaj_jan_panchayat_clients_referred_by += i['value']
          elsif i['key'][3].include? "any_other" or i['key'][3].include? "others_specify"
            @any_other_clients_refferd_count += i['value']
          end
        end
      end
    end

    # Calculation of gender of complaints

    for i in gender_of_complaint
      if !i['key'][0].empty? && !i['key'][2].empty? 
        if i['key'][3]!=nil
          if i['key'][3].include? "child_female"
            @child_female_count += i['value']
          elsif i['key'][3].include? "child_male"
            @child_male_count += i['value']
          elsif i['key'][3].include? "adult_male"
            @adult_male_count += i['value']
          elsif i['key'][3].include? "adult_female"
            @adult_female_count += i['value']
          elsif i['key'][3].include? "third_gender"
            @third_gender_count += i['value']
          end
        end
      end
    end

    for i in age_of_client
      if !i['key'][0].empty? && !i['key'][2].empty? 
        if i['key'][3]!=nil
          if i['key'][3].include? "less_than_14"
            @less_than_14_count += i['value']
          elsif i['key'][3].include? "in_15_17"
            @in_15_17_count += i['value']
          elsif i['key'][3].include? "in_18_24"
            @in_18_24_count += i['value']
          elsif i['key'][3].include? "in_25_34"
            @in_25_34_count += i['value']
          elsif i['key'][3].include? "in_35_44"
            @in_35_44_count += i['value']
          elsif i['key'][3].include? "in_45_54"
            @in_45_54_count += i['value']
          elsif i['key'][3].include? "above_55"
            @above_55_count += i['value']
          elsif i['key'][3].include? "not_mentioned"
            @no_age_info_count += i['value']
          end
        end
      end
    end

    for i in education_of_client
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3]!=nil
          if i['key'][3].include? "non_literate"
            @non_literate_count += i['value']
          elsif i['key'][3].include? "functional_literacy"
            @functional_literacy_count += i['value']
          elsif i['key'][3].include? "primary_level_class_4" or i['key'][3].include? "primary_level_passed_class_4" 
            @primary_level_class_4_count += i['value']
          elsif i['key'][3].include? "upto_ssc_passed_class_10"
            @upto_ssc_count += i['value']
          elsif i['key'][3].include? "upto_hsc_passed_class_12"
            @upto_hsc_count += i['value']
          elsif i['key'][3].include? "graduation_bachelor_s_degree"
            @upto_grad_count += i['value']
          elsif i['key'][3].include? "post_graduation_master_s_degree"
            @post_grad_count += i['value']
          elsif i['key'][3].include? "religious_education"
            @religious_education_count += i['value']
          elsif i['key'][3].include? "diploma"
            @diploma_education_count += i['value']
          elsif i['key'][3].include? "any_other" or i['key'][3].include? "others_specify"
            @any_other_edu_count += i['value']  
          elsif i['key'][3].include? "information_not_available"
            @no_edu_info_count += i['value']
          end
        end
      end
    end 
    
    # for i in reasons_fr_reg_at_spec_cell
    #   if !i['key'][0].empty? && !i['key'][2].empty?
    #     if i['key'][3]!=nil and !i['key'][3].empty?
    #       for j in i['key'][3]
    #         if j.include? "harassment_of_natal_family_members_of_the_woman_by_the_husband_family"
    #           @harr_natal_family_by_hus_count += i['value']
    #         elsif j.include? "deprivation_of_matrimonial_residence"
    #           @dep_matr_res_count += i['value']
    #         elsif j.include? "child_battering_by_husband_family"
    #           @childbattering_count += i['value']
    #         elsif j.include? "dowry_demands_by_husband_family"
    #           @dowry_count += i['value']
    #         elsif j.include? "harassment_by_natal_family"
    #           @harr_by_natal_family_count += i['value']
    #         elsif j.include? "harassment_by_children_and_their_spouses"
    #           @harr_by_chil_spouse_count += i['value']
    #         elsif j.include? "wife_has_left_the_matrimonial_home_male_clients"
    #           @wife_left_matr_home_count += i['value']
    #         elsif j.include? "harassment_at_work_by_husband"
    #           @harr_at_work_count += i['value']
    #         elsif j.include? "harassment_by_live_in_partner"
    #           @harr_by_live_in_partner_count += i['value']
    #         elsif j.include? "sexual_assault"
    #           @sex_assault_count += i['value']
    #         elsif j.include? "sexual_harassment_in_other_situation"
    #           @sex_har_in_other_sit_count += i['value']
    #         elsif j.include? "breach_of_trust_in_intimate_relationship"
    #           @breach_of_trust_count += i['value']
    #         elsif j.include? "harassment_by_neighbours"
    #           @harr_by_neigh_count += i['value']
    #         elsif j.include? "any_other" or j.include? "others_specify"
    #           @any_other_harr_count += i['value']
    #         end
    #       end
    #     end
    #   end
    # end

    # for i in vio_by_husband
    #   if !i['key'][0].empty? && !i['key'][2].empty?
    #     if i['key'][3]!=nil and i['key'][3].length > 0
    #       for j in i['key'][3]
    #         if j.include? "physical_violence_by_husband"
    #           @phy_vio_by_hus_count += i['value']
    #         elsif j.include? "emotional_mental_violence_by_husband"
    #           @emo_men_vio_by_hus_count += i['value']
    #         elsif j.include? "sexual_violence_by_husband"
    #           @sex_vio_by_hus_count += i['value']
    #         elsif j.include? "financial_violence_by_husband"
    #           @fin_vio_by_hus_count += i['value']
    #         elsif j.include? "out_of_marriage_relationship_second_marriage_by_husband"
    #           @sec_marr_by_hus_count += i['value']
    #         elsif j.include? "refusal_to_give_streedhan"
    #           @ref_to_strredhan_by_hus_count += i['value']
    #         elsif j.include? "alcohol_abuse_substance_abuse_by_husband"
    #           @alch_vio_by_hus_count += i['value']
    #         elsif j.include? "desertion_by_husband"
    #           @desertion_by_hus_count += i['value']
    #         elsif j.include? "child_custody_disputes_disputes_over_visitation_rights"
    #           @child_custody_vio_count += i['value']
    #         end
    #       end
    #     end
    #   end
    # end 
    
    # for i in vio_by_marital_family
    #   if !i['key'][0].empty? && !i['key'][2].empty?
    #     if i['key'][3]!=nil and i['key'][3].length > 0
    #       for j in i['key'][3]
    #         if j.include? "physical_violence_by_marital_family"
    #           @phy_vio_by_mart_family_count += i['value']
    #         elsif j.include? "emotional_mental_violence_by_marital_family"
    #           @emo_vio_by_mart_family_count += i['value']
    #         elsif j.include? "sexual_violence_by_marital_family"
    #           @sex_vio_by_mart_family_count += i['value']
    #         elsif j.include? "financial_violence_by_marital_family"
    #           @fin_vio_by_mart_family_count += i['value']
    #         end
    #       end
    #     end
    #   end
    # end 

    for i in previous_intervention_before_coming_to_the_cell
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3]!=nil and !i['key'][3].empty?
          for j in i['key'][3]
            if j.include? "natal_family_marital_family"
              @prev_inter_natal_family_marital_family_count += i['value']
            elsif j.include? "police"
              @prev_inter_police_count += i['value']
            # elsif j.include? "court_lawyers" or j.include? "lawyers_legal_organisations"
            #   @prev_inter_court_count += i['value']
            elsif j.include? "lawyers_legal_organisations"
              @prev_inter_court_count += i['value']
            elsif j.include? "non_governmental_organisation_ngo"
              @prev_interv_ngo_count += i['value']
            elsif j.include? "panchayat_member_jati_panchayat" or j.include? "jamat_samaj_jat_panchayat"
              @prev_interv_panch_mem_count += i['value']
            elsif j.include? "fcc_zp_counselling_centre"
              @prev_interv_fcc_zpcc += i['value']
            elsif j.include? "government_organisation_go"
              @prev_interv_government_organisation_go += i['value']
            elsif j.include? "any_other" or j.include? "others_specify"
              @prev_interv_any_other_count += i['value']
            end
          end
        end
      end
    end

    # for current clients
    for i in intervention_by_special_cell
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3]!=nil and !i['key'][3].empty?
          for j in i['key'][3]
            if j.include? "providing_emotional_support_and_strengthening_psychological_self"
              @spec_cell_prov_emo_support_count += i['value']
            elsif j.include? "building_support_system"
              @spec_cell_build_support_system_count += i['value']
            elsif j.include? "enlisting_police_help_or_intervention"
              @spec_cell_enlist_police_help_count += i['value']
            elsif j.include? "legal_aid_legal_referral_pre_litigation_counselling"
              @spec_cell_pre­litigation_counsel_count += i['value']
            elsif j.include? "working_with_men_in_the_interest_of_violated_woman"
              @spec_cell_work_with_men_count += i['value']
            elsif j.include? "advocacy_for_financial_entitlements"
              @spec_cell_adv_fin_ent_count += i['value']
            elsif j.include? "referral_for_shelter_medical_other_services"
              @spec_cell_refferal_for_shelter_count += i['value']
            elsif j.include? "developmental_counselling"
              @spec_cell_dev_counsel_count += i['value']
            elsif j.include? "retrieval_of_streedhan"
              @spcell_retrieval_of_streedhan += i['value']
            elsif j.include? "reestablishing_the_woman_s_relationship_to_her_property"
              @spcell_reestablishing_the_woman_s_relationship_to_her_property += i['value']
            elsif j.include? "negotiating_non_violence_with_stakeholder"
              @spec_cell_neg_nonvio_with_stakeholder_count += i['value']
            end
          end
        end
      end
    end

    # for i in negotiating_nonviolence
    #   if !i['key'][0].empty? && !i['key'][2].empty?
    #     if i['key'][3]!=nil and i['key'][3].length > 0
    #       for j in i['key'][3]
    #         if j.include? "negotiating_non_violence_with_stakeholder"
    #           @spec_cell_neg_nonvio_with_stakeholder_count  += i['value'] 
    #         elsif j.include? "negotiation_for_non_violence_woman_outside_matrimonial_home"
    #           @spcell_negotiating_for_non_violence_reconciliation  += i['value']
    #         elsif j.include? "negotiation_to_stop_the_violence_woman_within_matrimonial_home"
    #           @spcell_negotiating_to_stop_non_violence  += i['value']
    #         end
    #       end
    #     end
    #   end
    # end

    # for i in other_negotiations
    #   if !i['key'][0].empty? && !i['key'][2].empty?
    #     if i['key'][3]!=nil and i['key'][3].length > 0
    #       for j in i['key'][3]
    #         if j.include? "negotiation_for_separation"
    #           @spcell_negotiating_for_seperation  += i['value'] 
    #         elsif j.include? "negotiation_for_divorce"
    #           @spcell_negotiating_for_divorce  += i['value']
    #         elsif j.include? "negotiation_for_child_custody"
    #           @spcell_negotiating_for_child_custody  += i['value']
    #         end
    #       end
    #     end
    #   end
    # end

    for i in referrals_new_clients_ongoing_clients
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3]!=nil and !i['key'][3].empty?
          for j in i['key'][3]
            if j.include? "police"
              @police_refferal_count += i['value']
            elsif j.include? "medical_service"
              @medical_refferal_count += i['value']
            elsif j.include? "court_dlsa"
              @court_dlsa_refferal_count += i['value']
            elsif j.include? "shelter_home"
              @shelter_refferal_count += i['value']
            elsif j.include? "protection_officer"
              @protection_officer_refferal_count += i['value']
            elsif j.include? "non_governmental_organisation_ngo"
              @ngo_referral_count += i['value']  
            elsif j.include? "community_based_organisations_cbo"
              @cbo_referral_count += i['value']
            elsif j.include? "government_organisation_go"
              @go_referral_count += i['value']
            elsif j.include? "lawyer_70395"
              @lawer_services_refferal_count += i['value']  
            elsif j.include? "any_other" or j.include? "others_specify"
              @any_other_refferal_count += i['value']
            # elsif j.include? "court_lawyers_legal_organisations" or j.include? "lawyers_legal_organisations"
            #   @court_dlsa_refferal_count += i['value']
            #   @lawer_services_refferal_count += i['value']
            # end
            elsif j.include? "lawyers_legal_organisations"
              @court_dlsa_refferal_count += i['value']
              @lawer_services_refferal_count += i['value']
          end
          end
        end
      end
    end

   
    # for i in other_interventions_taking_place_outside_the_cell
    #   if !i['key'][0].empty? && !i['key'][2].empty?
    #     if i['key'][3]!=nil and !i['key'][3].empty?
    #       for j in i['key'][3]
    #         if j.include? "home_visits"
    #           @othr_inter_home_visit_count += i['value']
    #         elsif j.include? "visits_to_institutions"
    #           @othr_inter_visit_inst_count += i['value']
    #         elsif j.include? "community_education_programmes"
    #           @othr_inter_comm_edu_count += i['value']
    #         elsif j.include? "interaction_with_police"
    #           @othr_inter_inter_with_police_count += i['value']
    #         elsif j.include? "representation_on_sexual_harrassment_committee"
    #           @othr_inter_representation_on_sexual_harrassment_committee += i['value']
    #         elsif j.include? "others_specify" or j.include? "any_other"
    #           @othr_inter_any_other_count += i['value']
    #         elsif j.include? "meetings_with_local_groups_social_organisations"
    #           @othr_inter_meet_local_count += i['value']
    #         end
    #       end
    #     end
    #   end
    # end
    

    # for i in outcomes_new_clients_ongoing_clients
    #   if !i['key'][0].empty? && !i['key'][2].empty?
    #     if i['key'][3]!=nil and i['key'][3].length > 0
    #       fir_registered_counter = 0
    #       for j in i['key'][3]
    #         if j.include? "helped_in_filing_for_divorce_separation_talaq_khula" or j.include? "helped_in_filing_case_in_court_for_divorce_separation_mediation" or j.include? "helped_in_filing_case_in_court_for_divorce_separation"
    #           @outcomes_helped_in_case_filed_for_divorce_count += i['value']
    #         elsif j.include? "helped_in_reteival_of_streedhan"
    #           @outcome_streedhan_retrival_count += i['value']
    #         elsif j.include? "helped_in_filing_application_under_pwdva"
    #           @outcome_pwdva_2005_count += i['value']
    #         elsif j.include? "helped_in_registering_fir_under_section_498a" or j.include? "helped_in_registering_fir_other_than_under_section_498a"
    #           if j.include? "helped_in_registering_fir_under_section_498a"
    #             @outcome_498A_count += i['value']
    #             @outcomes_fir_registered += i['value']
    #           else
    #             @outcomes_other_than_498A += i['value']
    #             @outcomes_fir_registered += i['value']
    #           end
    #         elsif j.include? "non_violent_reconciliation"
    #           @outcome_non_violent_recon_count += i['value']
    #         elsif j.include? "court_orders_in_the_best_interest_of_the_woman"
    #           @outcome_court_order_count += i['value']
    #         elsif j.include? "nc_registration"
    #           @outcome_nc_registration += i['value']
    #         elsif j.include? "non_violent_amicable_separation_on_woman_s_terms"
    #           @outcome_without_court_seperation += i['value']
    #         elsif j.include? "child_custody"
    #           @outcome_child_custody += i[  'value']
    #         elsif j.include? "any_other" or j.include? "others_specify"
    #           @outcome_any_other_count += i['value']
    #         end
    #       end
    #     end
    #   end
    # end

    # for i in helped_the_woman_in_accessing_her_financial_entitlements
    #   if !i['key'][0].empty? && !i['key'][2].empty?
    #     if i['key'][3]!=nil && i['key'][3].length >0
    #       for j in i['key'][3]
    #         if j.include? "helped_in_retreiving_economic_assets_financial_entitlements_personal_belongings_articles_of_the_woman" or j.include? "helped_in_accessing_one_time_amount_lumpsum"
    #           @outcome_maintenence_count  += i['value']
    #         end
    #       end
    #     end
    #   end
    # end

    # for i in helped_in_filing_for_divorceseparationtalaqkhula
    #   if !i['key'][0].empty? && !i['key'][2].empty?
    #     if i['key'][3]!=nil
    #       if i['key'][3].include? "helped_in_filing_case_in_court_for_divorce" or i['key'][3].include? "helped_in_filing_case_in_court_for_separation"
    #         @outcomes_helped_in_filing_case_for_divorce_seperation  += i['value'] 
    #       elsif i['key'][3].include? "talaq_khula"
    #         @outcomes_talaq_khula  += i['value']
    #       end
    #     end
    #   end
    # end

    # for i in helped_in_filing_case_in_court_for_divorceseparationmediation
    #   if !i['key'][0].empty? && !i['key'][2].empty?
    #     if i['key'][3]!=nil
    #       if i['key'][3].include? "helped_in_filing_case_in_court_for_divorce" or i['key'][3].include? "helped_in_filing_case_in_court_for_separation"
    #         @outcomes_helped_in_filing_case_for_divorce_seperation  += i['value'] 
    #       end
    #     end
    #   end
    # end

    # for i in cases_sent_back_to_eo
    #   if !i['key'][0].empty? && !i['key'][2].empty?
    #     if i['key'][3]!= nil and i['key'][3].length > 0
    #       for j in i['key'][3]
    #         if j.include? "sent_back_to_eo_for_mediation"
    #           @outcomes_sent_back_to_eo_for_mediation += i['value']
    #         end
    #         if j.include? "sent_back_to_eo_for_legal_action"
    #           @outcomes_sent_back_to_eo_fr_legal_action += i['value']
    #         end
    #       end
    #     end
    #   end
    # end
    # -------------------------------------

    # for ongoing clients 
    end_date_for_ongoing_clients = start_date
    start_date_for_ongoing_clients = "1000-01-01"


    # if district.empty?
    #   ongoing_clients_in_this_quarter = Child.by_state_date_ongoing_clients_not_registered_in_this_quarter.startkey([state,1,start_date_for_ongoing_clients]).endkey([state,1,end_date_for_ongoing_clients,{}])['rows']
    #   intervention_by_special_cell = Child.by_state_date_ongoing_clients.startkey([state,1,start_date_for_ongoing_clients]).endkey([state,1,end_date_for_ongoing_clients,{}]).reduce.group['rows']
    # else
    #   ongoing_clients_in_this_quarter = Child.by_ongoing_clients_not_registered_in_this_quarter.startkey([state,district,start_date_for_ongoing_clients]).endkey([state,district,end_date_for_ongoing_clients,{}])['rows']
    #   intervention_by_special_cell = Child.by_ongoing_clients.startkey([state,district,start_date_for_ongoing_clients]).endkey([state,district,end_date_for_ongoing_clients,{}]).reduce.group['rows']
    # end

    # follow_up_array=[]
    # for i in ongoing_clients_in_this_quarter
    #   is_ongoing_client = i['key'][4]
    #   if i['key'][3]!= nil && is_ongoing_client
    #     if i['key'][3].length > 0
    #       for j in i['key'][3]
    #         if j.has_key? "ongoing_followup" and !j["ongoing_followup"].empty?
    #           date = Date.parse(j["ongoing_followup"])
    #           if date >= Date.parse(start_date) and date < Date.parse(end_date)
    #             @ongoing_clients += 1
    #             break
    #           end
    #         end
    #       end
    #     end
    #   end
    # end  

    # for i in intervention_by_special_cell
    #   is_ongoing_client = i['key'][4]
    #   ongoing_present = 0
    #   if !i['key'][0].empty? && !i['key'][2].empty? && is_ongoing_client
    #     if i['key'][3].length >0
    #       for j in i['key'][3]
    #         if j.has_key? "ongoing_followup" and !j["ongoing_followup"].empty?
    #           date = Date.parse(j["ongoing_followup"])
    #           if date >= Date.parse(start_date) and date < Date.parse(end_date)
    #             ongoing_present += 1
    #             break
    #           end
    #         end
    #       end

    #       if ongoing_present!=0
    #         intervention_by_special_cell_array = []
    #         negotiating_non_violence = []
    #         referrals_new_clients_ongoing_clients = []
    #         outcomes_new_clients_ongoing_clients = []
    #         helped_in_filing_for_divorceseparationtalaqkhula = []
    #         helped_the_woman_in_accessing_her_financial_entitlements =[]
    #         for j in i['key'][3]
    #           if j.has_key? "ongoing_followup" and !j["ongoing_followup"].empty?
    #             followup_date = Date.parse(j["ongoing_followup"])
    #             if followup_date >= Date.parse(start_date) and followup_date < Date.parse(end_date)
    #               # intervention by special cell calculation for that case
    #               if j.has_key? "intervention_by_special_cell" and j["intervention_by_special_cell"].length > 0
    #                 for intervention in j["intervention_by_special_cell"]
    #                   intervention_by_special_cell_array.push(intervention)
    #                 end
    #               end
    #               #negotiating no-violence calculation for that case
    #               if j.has_key? "negotiating_nonviolence" and j["negotiating_nonviolence"]!=nil and j["negotiating_nonviolence"].length > 0
    #                 for neg_non_violence in j["negotiating_nonviolence"]
    #                   negotiating_non_violence.push(neg_non_violence)
    #                 end
    #               end
    #               # refferals new clients ongoing clients
    #               if j.has_key? "referrals_new_clients_ongoing_clients" and j["referrals_new_clients_ongoing_clients"]!=nil and j["referrals_new_clients_ongoing_clients"].length > 0
    #                 for refferals in j["referrals_new_clients_ongoing_clients"]
    #                   referrals_new_clients_ongoing_clients.push(refferals)
    #                 end
    #               end
    #               # outcomes_new_clients_ongoing_clients
    #               if j.has_key? "outcomes_new_clients_ongoing_clients" and j["outcomes_new_clients_ongoing_clients"]!=nil and j["outcomes_new_clients_ongoing_clients"].length > 0
    #                 for outcomes in j["outcomes_new_clients_ongoing_clients"]
    #                   outcomes_new_clients_ongoing_clients.push(outcomes)
    #                 end
    #               end

    #               if j.has_key? "helped_the_woman_in_accessing_her_financial_entitlements" and j["helped_the_woman_in_accessing_her_financial_entitlements"]!=nil and j["helped_the_woman_in_accessing_her_financial_entitlements"].length > 0
    #                 for fin_entitelmnts in j["helped_the_woman_in_accessing_her_financial_entitlements"]
    #                   helped_the_woman_in_accessing_her_financial_entitlements.push(fin_entitelmnts)
    #                 end
    #               end
    #               #helped_in_filing_case_in_court_for_divorceseparationmediation
    #               if j.has_key? "helped_in_filing_for_divorceseparationtalaqkhula" and j["helped_in_filing_for_divorceseparationtalaqkhula"]!=nil
    #                   helped_in_filing_for_divorceseparationtalaqkhula.push(j["helped_in_filing_for_divorceseparationtalaqkhula"])
    #               end
    #             end
    #           end
    #         end
    #         # intervention by special cell
    #         if intervention_by_special_cell_array.length > 0
    #           intervention_by_special_cell_array = intervention_by_special_cell_array.uniq #make array unique
    #           # Assign counter
    #           providing_emotional_support_and_strengthening_psychological_self_counter = 0
    #           enlisting_police_help_or_intervention_counter = 0
    #           legal_aid_legal_referral_pre_litigation_counselling_counter = 0
    #           working_with_men_in_the_interest_of_violated_woman_counter = 0
    #           advocacy_for_financial_entitlements_counter = 0
    #           building_support_system_counter = 0
    #           referral_for_shelter_medical_other_services_counter = 0
    #           developmental_counselling_counter = 0
    #           negotiating_non_violence_with_stakeholder_counter = 0
    #           for j in intervention_by_special_cell_array
    #             if providing_emotional_support_and_strengthening_psychological_self_counter == 0 and j.include? "providing_emotional_support_and_strengthening_psychological_self"
    #               providing_emotional_support_and_strengthening_psychological_self_counter += 1
    #               @spec_cell_prov_emo_support_count_ongoing_client += 1
    #             elsif building_support_system_counter == 0 and j.include? "building_support_system"
    #               building_support_system_counter += 1
    #               @spec_cell_build_support_system_count_ongoing_client += 1
    #             elsif enlisting_police_help_or_intervention_counter == 0 and j.include? "enlisting_police_help_or_intervention"
    #               enlisting_police_help_or_intervention_counter += 1
    #               @spec_cell_enlist_police_help_count_ongoing_client += 1
    #             elsif legal_aid_legal_referral_pre_litigation_counselling_counter == 0 and j.include? "legal_aid_legal_referral_pre_litigation_counselling"
    #               legal_aid_legal_referral_pre_litigation_counselling_counter += 1
    #               @spec_cell_pre­litigation_counsel_count_ongoing_client += 1
    #             elsif working_with_men_in_the_interest_of_violated_woman_counter == 0 and j.include? "working_with_men_in_the_interest_of_violated_woman"
    #               working_with_men_in_the_interest_of_violated_woman_counter += 1
    #               @spec_cell_work_with_men_count_ongoing_client += 1
    #             elsif advocacy_for_financial_entitlements_counter == 0 and j.include? "advocacy_for_financial_entitlements"
    #               advocacy_for_financial_entitlements_counter += 1
    #               @spec_cell_adv_fin_ent_count_ongoing_client += 1
    #             elsif referral_for_shelter_medical_other_services_counter == 0 and j.include? "referral_for_shelter_medical_other_services"
    #               referral_for_shelter_medical_other_services_counter += 1
    #               @spec_cell_refferal_for_shelter_count_ongoing_client += 1
    #             elsif developmental_counselling_counter == 0 and j.include? "developmental_counselling"
    #               developmental_counselling_counter += 1
    #               @spec_cell_dev_counsel_count_ongoing_client += 1
    #             elsif negotiating_non_violence_with_stakeholder_counter == 0 and j.include? "negotiating_non_violence_with_stakeholder"
    #               negotiating_non_violence_with_stakeholder_counter += 1
    #               @spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client += 1
    #             end
                
    #           end
    #         end
    #         # negotiating non-violence
    #         if negotiating_non_violence.length > 0
    #           negotiating_non_violence = negotiating_non_violence.uniq
    #           negotiating_non_violence_with_stakeholder_counter = 0
    #           for j in negotiating_non_violence
    #             if negotiating_non_violence_with_stakeholder_counter == 0 and j.include? "negotiating_non_violence_with_stakeholder"
    #               negotiating_non_violence_with_stakeholder_counter += 1
    #               @spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client  += 1
    #             end
    #           end
    #         end

    #         if helped_the_woman_in_accessing_her_financial_entitlements.length > 0
    #           helped_the_woman_in_accessing_her_financial_entitlements = helped_the_woman_in_accessing_her_financial_entitlements.uniq
    #           helped_in_retreiving_economic_assets_financial_entitlements_personal_belongings_articles_of_the_woman_counter = 0
    #           helped_in_accessing_one_time_amount_lumpsum_counter = 0
    #           for j in helped_the_woman_in_accessing_her_financial_entitlements
    #             if helped_in_retreiving_economic_assets_financial_entitlements_personal_belongings_articles_of_the_woman_counter == 0 and j.include? "helped_in_retreiving_economic_assets_financial_entitlements_personal_belongings_articles_of_the_woman"
    #               helped_in_retreiving_economic_assets_financial_entitlements_personal_belongings_articles_of_the_woman_counter += 1
    #               @outcome_maintenence_count_ongoing_client  += 1
    #             elsif helped_in_accessing_one_time_amount_lumpsum_counter == 0 and j.include? "helped_in_accessing_one_time_amount_lumpsum"
    #               helped_in_accessing_one_time_amount_lumpsum_counter += 1
    #               @outcome_maintenence_count_ongoing_client  += 1
    #             end
    #           end
    #         end


    #         # refferals new clients ongoing clients
    #         if referrals_new_clients_ongoing_clients.length > 0
    #           referrals_new_clients_ongoing_clients = referrals_new_clients_ongoing_clients.uniq
    #           police_counter = 0
    #           medical_service_counter = 0
    #           court_lawyers_legal_organisations_counter = 0
    #           shelter_home_counter = 0
    #           protection_officer_counter = 0
    #           any_other_counter = 0
    #           lawer_services_counter = 0
    #           court_dlsa_counter=0
    #           non_governmental_organisation_ngo_counter = 0
    #           community_based_organisations_cbo_counter = 0
    #           government_organisation_go_counter = 0

    #           for j in referrals_new_clients_ongoing_clients
    #             if police_counter == 0 and j.include? "police"
    #               police_counter += 1
    #               @police_refferal_count_ongoing_client += 1
    #             elsif medical_service_counter == 0 and j.include? "medical_service"
    #               medical_service_counter += 1
    #               @medical_refferal_count_ongoing_client += 1
    #             elsif court_dlsa_counter == 0 and j.include? "court_dlsa"
    #               court_dlsa_counter += 1
    #               @court_dlsa_refferal_count_ongoing_client += 1
    #             elsif shelter_home_counter == 0 and j.include? "shelter_home"
    #               shelter_home_counter += 1
    #               @shelter_refferal_count_ongoing_client += 1
    #             elsif protection_officer_counter == 0 and j.include? "protection_officer"
    #               protection_officer_counter += 1
    #               @protection_officer_refferal_count_ongoing_client += 1
    #             elsif lawer_services_counter == 0 and j.include? "lawyer_70395"
    #               lawer_services_counter += 1
    #               @lawer_services_refferal_count_ongoing_client += 1
    #             elsif non_governmental_organisation_ngo_counter == 0 and j.include? "non_governmental_organisation_ngo"
    #               non_governmental_organisation_ngo_counter += 1
    #               @ngo_referral_count_ongoing_client += 1
    #             elsif community_based_organisations_cbo_counter == 0 and j.include? "community_based_organisations_cbo"
    #               community_based_organisations_cbo_counter += 1
    #               @cbo_referral_count_ongoing_client += 1
    #             elsif government_organisation_go_counter == 0 and j.include? "government_organisation_go"
    #               government_organisation_go_counter += 1
    #               @go_referral_count_ongoing_client += 1
    #             elsif court_lawyers_legal_organisations_counter == 0 and (j.include? "court_lawyers_legal_organisations" or j.include? "lawyers_legal_organisations")
    #               court_lawyers_legal_organisations_counter += 1
    #               @lawer_services_refferal_count_ongoing_client += 1
    #               @court_dlsa_refferal_count_ongoing_client += 1
    #             elsif any_other_counter == 0 
    #               if j.include? "any_other" or j.include? "others_specify"
    #                 any_other_counter += 1
    #                 @any_other_refferal_count_ongoing_client += 1
    #               end
    #             end
    #           end
    #         end
    #         # outcomes_new_clients_ongoing_clients
    #         if outcomes_new_clients_ongoing_clients.length > 0
    #           outcomes_new_clients_ongoing_clients = outcomes_new_clients_ongoing_clients.uniq
    #           divorce_counter = 0
    #           helped_in_reteival_of_streedhan = 0
    #           helped_in_filing_application_under_pwdva_2005 = 0
    #           helped_in_registering_fir_under_section_498a = 0
    #           helped_in_registering_fir_other_than_under_section_498a = 0
    #           helped_the_woman_in_accessing_her_financial_entitlements = 0
    #           non_violent_reconciliation = 0
    #           court_orders_in_the_best_interest_of_the_woman = 0
    #           others_specify = 0
    #           for j in outcomes_new_clients_ongoing_clients
    #             if divorce_counter == 0 and (j.include? "helped_in_filing_for_divorce_separation_talaq_khula" or j.include? "helped_in_filing_case_in_court_for_divorce_separation_mediation" or j.include? "helped_in_filing_case_in_court_for_divorce_separation")
    #                 divorce_counter += 1
    #                 @outcomes_helped_in_case_filed_for_divorce_count_ongoing_client += i['value']
    #             elsif helped_in_reteival_of_streedhan == 0 and j.include? "helped_in_reteival_of_streedhan"
    #               helped_in_reteival_of_streedhan += 1
    #               @outcome_streedhan_retrival_count_ongoing_client += i['value']
    #             elsif helped_in_filing_application_under_pwdva_2005 == 0 and j.include? "helped_in_filing_application_under_pwdva_2005"
    #               helped_in_filing_application_under_pwdva_2005 += 1
    #               @outcome_pwdva_2005_count_ongoing_client += i['value']
    #             elsif helped_in_registering_fir_under_section_498a == 0 and j.include? "helped_in_registering_fir_under_section_498a"
    #               helped_in_registering_fir_under_section_498a += 1
    #               @outcome_498A_count_ongoing_client += i['value']
    #             elsif helped_in_registering_fir_other_than_under_section_498a == 0 and j.include? "helped_in_registering_fir_other_than_under_section_498a"
    #               helped_in_registering_fir_other_than_under_section_498a += 1
    #               @outcome_other_than_498A_count_ongoing_client += i['value']
    #             elsif non_violent_reconciliation == 0 and j.include? "non_violent_reconciliation"
    #               non_violent_reconciliation += 1
    #               @outcome_non_violent_recon_count_ongoing_client += i['value']
    #             elsif court_orders_in_the_best_interest_of_the_woman == 0 and j.include? "court_orders_in_the_best_interest_of_the_woman"
    #               court_orders_in_the_best_interest_of_the_woman += 1
    #               @outcome_court_order_count_ongoing_client += i['value']
    #             elsif others_specify == 0
    #               if j.include? "any_other" or j.include? "others_specify"
    #                 others_specify += 1
    #                 @outcome_any_other_count_ongoing_client += i['value']
    #               end
    #             end
    #           end
    #         end

    #         if helped_in_filing_for_divorceseparationtalaqkhula.length > 0
    #           helped_in_filing_for_divorceseparationtalaqkhula = helped_in_filing_for_divorceseparationtalaqkhula.uniq
    #           helped_in_filing_case_in_court_for_divorce = 0
    #           helped_in_filing_case_in_court_for_separation = 0
    #           for j in helped_in_filing_for_divorceseparationtalaqkhula
    #             if helped_in_filing_case_in_court_for_divorce == 0 and j.include? "helped_in_filing_case_in_court_for_divorce"
    #               helped_in_filing_case_in_court_for_divorce += 1
    #               @outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients += i['value']
    #             elsif helped_in_filing_case_in_court_for_separation == 0 and j.include? "helped_in_filing_case_in_court_for_separation"
    #               helped_in_filing_case_in_court_for_separation += 1
    #               @outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients += i['value']
    #             end
    #           end
    #         end
            
    #       end
    #     end
    #   end
    # end
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
    @qpr_data.push({
    'state' => state,
    'district' => main_district,
    'cell' => district,

    #new variables

    'outcomes_sent_back_to_eo_fr_legal_action' => @outcomes_sent_back_to_eo_fr_legal_action,
    'sent_back_to_eo_for_dv_act' => @sent_back_to_eo_for_dv_act,
    'outcomes_sent_back_to_eo_for_mediation' => @outcomes_sent_back_to_eo_for_mediation,

    'other_special_cell_clients_reffered_by' => @other_special_cell_clients_reffered_by,
    'jamat_samaj_jan_panchayat_clients_referred_by' => @jamat_samaj_jan_panchayat_clients_referred_by,
    'religious_education_count' => @religious_education_count,
    'diploma_education_count' => @diploma_education_count,
    'prev_interv_fcc_zpcc' => @prev_interv_fcc_zpcc,
    'prev_interv_government_organisation_go' => @prev_interv_government_organisation_go,
    'spcell_negotiating_to_stop_non_violence' => @spcell_negotiating_to_stop_non_violence,
    'spcell_negotiating_for_non_violence_reconciliation' => @spcell_negotiating_for_non_violence_reconciliation,
    'spcell_negotiating_for_seperation' => @spcell_negotiating_for_seperation,
    'spcell_negotiating_for_divorce' => @spcell_negotiating_for_divorce,
    'spcell_negotiating_for_child_custody' => @spcell_negotiating_for_child_custody,
    'spcell_retrieval_of_streedhan' => @spcell_retrieval_of_streedhan,
    'spcell_reestablishing_the_woman_s_relationship_to_her_property' => @spcell_reestablishing_the_woman_s_relationship_to_her_property,
    'ngo_referral_count' => @ngo_referral_count,
    'cbo_referral_count' => @cbo_referral_count,
    'go_referral_count' => @go_referral_count,
    'ngo_referral_count_ongoing_client' => @ngo_referral_count_ongoing_client,
    'cbo_referral_count_ongoing_client' => @cbo_referral_count_ongoing_client,
    'go_referral_count_ongoing_client' => @go_referral_count_ongoing_client,
    'othr_inter_representation_on_sexual_harrassment_committee' => @othr_inter_representation_on_sexual_harrassment_committee,
    'outcomes_helped_in_filing_case_for_divorce_seperation' => @outcomes_helped_in_filing_case_for_divorce_seperation,
    'outcomes_talaq_khula' => @outcomes_talaq_khula,
    'outcomes_fir_registered' => @outcomes_fir_registered,
    'outcome_nc_registration' => @outcome_nc_registration,
    'outcome_child_custody' => @outcome_child_custody,
    'outcome_without_court_seperation' => @outcome_without_court_seperation,
    'outcomes_helped_in_filing_case_in_court_for_mediation' => @outcomes_helped_in_filing_case_in_court_for_mediation,
    'outcomes_other_than_498A' => @outcomes_other_than_498A,
    'outcome_other_than_498A_count_ongoing_client' => @outcome_other_than_498A_count_ongoing_client,
    'outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients' => @outcomes_helped_in_filing_case_for_divorce_seperation_ongoing_clients,

      # / variable declaration/
    'total_client_with_whom_interaction' => @total_clients + @ongoing_clients + @one_time_intervention_in_this_quarter,
    'ongoing_clients' => @ongoing_clients,
    'one_time_intervention_in_this_quarter' => @one_time_intervention_in_this_quarter,
    'no_of_ppl_prvded_supp' => @no_of_ppl_prvded_supp,

    # ------------------
    'total_clients' => @total_clients,

    "clients" => @exclients_count + @self_count + @police_count + @ngo_count + @icw_pw_count + @word_of_mouth_count + @go_count + @lawyers_legal_org_count + @any_other_clients_refferd_count + @community_based_org_count,
    # / clients reffered by declaration of variables/
    'exclients_count' => @exclients_count,
    'self_count' => @self_count,
    'police_count' => @police_count,
    'ngo_count' => @ngo_count,
    'community_based_org_count' => @community_based_org_count,
    'icw_pw_count' => @icw_pw_count,
    'word_of_mouth_count' => @word_of_mouth_count,
    'go_count' => @go_count,
    'lawyers_legal_org_count' => @lawyers_legal_org_count,
    'any_other_clients_refferd_count' => @any_other_clients_refferd_count, 
    # / end------------------------------/

    "gender" => @adult_male_count + @adult_female_count + @child_male_count + @child_female_count + @third_gender_count,
    # Gender of the complainants/ clients ----variable declaration
    'adult_male_count' => @adult_male_count,
    'adult_female_count' => @adult_female_count,
    'child_male_count' => @child_male_count,
    'child_female_count' => @child_female_count,
    'third_gender_count' => @third_gender_count,
    # -----------------------

    "age" => @less_than_14_count + @in_15_17_count + @in_18_24_count + @in_25_34_count + @in_35_44_count + @in_45_54_count + @above_55_count + @no_age_info_count,
    # Age of the clients----variable declaration
    'less_than_14_count' => @less_than_14_count,
    'in_15_17_count' => @in_15_17_count,
    'in_18_24_count' => @in_18_24_count,
    'in_25_34_count' => @in_25_34_count,
    'in_35_44_count' => @in_35_44_count,
    'in_45_54_count' => @in_45_54_count,
    'above_55_count' => @above_55_count,
    'no_age_info_count' => @no_age_info_count,
    # --------------------

    "education" => @non_literate_count + @functional_literacy_count + @primary_level_class_4_count + @upto_ssc_count + @upto_hsc_count + @upto_grad_count + @post_grad_count + @any_other_edu_count + @no_edu_info_count,
    #Education of the clients ----variable declaration
    'non_literate_count' => @non_literate_count,
    'functional_literacy_count' => @functional_literacy_count,
    'primary_level_class_4_count' => @primary_level_class_4_count,
    'upto_ssc_count' => @upto_ssc_count,
    'upto_hsc_count' => @upto_hsc_count,
    'upto_grad_count' => @upto_grad_count,
    'post_grad_count' => @post_grad_count,
    'any_other_edu_count' => @any_other_edu_count,
    'no_edu_info_count' => @no_edu_info_count,
    # ----------------------

    "reasons_special_cell" => @phy_vio_by_hus_count + @emo_men_vio_by_hus_count + @sex_vio_by_hus_count + @fin_vio_by_hus_count + @sec_marr_by_hus_count + @ref_to_strredhan_by_hus_count + @alch_vio_by_hus_count + @desertion_by_hus_count + @child_custody_vio_count + @phy_vio_by_mart_family_count + @emo_vio_by_mart_family_count + @sex_vio_by_mart_family_count + @fin_vio_by_mart_family_count + @harr_natal_family_by_hus_count + @dep_matr_res_count + @childbattering_count + @dowry_count + @harr_by_natal_family_count + @harr_by_chil_spouse_count + @wife_left_matr_home_count + @harr_at_work_count + @harr_by_live_in_partner_count + @sex_assault_count + @sex_har_in_other_sit_count + @breach_of_trust_count + @harr_by_neigh_count + @any_other_harr_count,
    # Reasons for registering at the Special Cell ----variable declaration
    'phy_vio_by_hus_count' => @phy_vio_by_hus_count,
    'emo_men_vio_by_hus_count' => @emo_men_vio_by_hus_count,
    'sex_vio_by_hus_count' => @sex_vio_by_hus_count,
    'fin_vio_by_hus_count' => @fin_vio_by_hus_count,
    'sec_marr_by_hus_count' => @sec_marr_by_hus_count,
    'ref_to_strredhan_by_hus_count' => @ref_to_strredhan_by_hus_count,
    'alch_vio_by_hus_count' => @alch_vio_by_hus_count,
    'desertion_by_hus_count' => @desertion_by_hus_count,
    'child_custody_vio_count' => @child_custody_vio_count,
    'phy_vio_by_mart_family_count' => @phy_vio_by_mart_family_count,
    'emo_vio_by_mart_family_count' => @emo_vio_by_mart_family_count,
    'sex_vio_by_mart_family_count' => @sex_vio_by_mart_family_count,
    'fin_vio_by_mart_family_count' => @fin_vio_by_mart_family_count,
    'harr_natal_family_by_hus_count' => @harr_natal_family_by_hus_count,
    'dep_matr_res_count' => @dep_matr_res_count,
    'childbattering_count' => @childbattering_count,
    'dowry_count' => @dowry_count,
    'harr_by_natal_family_count' => @harr_by_natal_family_count,
    'harr_by_chil_spouse_count' => @harr_by_chil_spouse_count,
    'wife_left_matr_home_count' => @wife_left_matr_home_count,
    'harr_at_work_count' => @harr_at_work_count,
    'harr_by_live_in_partner_count' => @harr_by_live_in_partner_count,
    'sex_assault_count' => @sex_assault_count,
    'sex_har_in_other_sit_count' => @sex_har_in_other_sit_count,
    'breach_of_trust_count' => @breach_of_trust_count,
    'harr_by_neigh_count' => @harr_by_neigh_count,
    'any_other_harr_count' => @any_other_harr_count,
    # ---------------------------

    "prev_inter_bef_comming_to_cell" => @prev_inter_natal_family_marital_family_count + @prev_inter_police_count + @prev_inter_court_count + @prev_interv_ngo_count + @prev_interv_panch_mem_count + @prev_interv_any_other_count,
    # Previous intervention before coming to the Cell ----variable declaration
    'prev_inter_natal_family_marital_family_count' => @prev_inter_natal_family_marital_family_count,
    'prev_inter_police_count' => @prev_inter_police_count,
    'prev_inter_court_count' => @prev_inter_court_count,
    'prev_interv_ngo_count' => @prev_interv_ngo_count,
    'prev_interv_panch_mem_count' => @prev_interv_panch_mem_count,
    'prev_interv_any_other_count' => @prev_interv_any_other_count,
    # ------------------------------------------------------------------------

    "intervension_by_spec_cell" => @spec_cell_prov_emo_support_count + @spec_cell_neg_nonvio_with_stakeholder_count + @spec_cell_build_support_system_count + @spec_cell_enlist_police_help_count + @spec_cell_pre­litigation_counsel_count + @spec_cell_work_with_men_count + @spec_cell_adv_fin_ent_count + @spec_cell_refferal_for_shelter_count + @spec_cell_dev_counsel_count,
    # Intervention by the Special Cell
    'spec_cell_prov_emo_support_count' => @spec_cell_prov_emo_support_count,
    'spec_cell_neg_nonvio_with_stakeholder_count' => @spec_cell_neg_nonvio_with_stakeholder_count,
    'spec_cell_build_support_system_count' => @spec_cell_build_support_system_count,
    'spec_cell_enlist_police_help_count' => @spec_cell_enlist_police_help_count,
    'spec_cell_pre­litigation_counsel_count' => @spec_cell_pre­litigation_counsel_count,
    'spec_cell_work_with_men_count' => @spec_cell_work_with_men_count,
    'spec_cell_adv_fin_ent_count' => @spec_cell_adv_fin_ent_count,
    'spec_cell_refferal_for_shelter_count' => @spec_cell_refferal_for_shelter_count,
    'spec_cell_dev_counsel_count' => @spec_cell_dev_counsel_count,
    # ------------------------------

    "intervension_by_spec_cell_ongoing" => @spec_cell_prov_emo_support_count_ongoing_client + @spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client + @spec_cell_build_support_system_count_ongoing_client + @spec_cell_enlist_police_help_count_ongoing_client + @spec_cell_pre­litigation_counsel_count_ongoing_client + @spec_cell_work_with_men_count_ongoing_client + @spec_cell_adv_fin_ent_count_ongoing_client + @spec_cell_refferal_for_shelter_count_ongoing_client + @spec_cell_dev_counsel_count_ongoing_client,
    # Intervention by the Special Cell ongoing ----variable declaration
    'spec_cell_prov_emo_support_count_ongoing_client' => @spec_cell_prov_emo_support_count_ongoing_client,
    'spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client' => @spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client,
    'spec_cell_build_support_system_count_ongoing_client' => @spec_cell_build_support_system_count_ongoing_client,
    'spec_cell_enlist_police_help_count_ongoing_client' => @spec_cell_enlist_police_help_count_ongoing_client,
    'spec_cell_pre­litigation_counsel_count_ongoing_client' => @spec_cell_pre­litigation_counsel_count_ongoing_client,
    'spec_cell_work_with_men_count_ongoing_client' => @spec_cell_work_with_men_count_ongoing_client,
    'spec_cell_adv_fin_ent_count_ongoing_client' => @spec_cell_adv_fin_ent_count_ongoing_client,
    'spec_cell_refferal_for_shelter_count_ongoing_client' => @spec_cell_refferal_for_shelter_count_ongoing_client,
    'spec_cell_dev_counsel_count_ongoing_client' => @spec_cell_dev_counsel_count_ongoing_client,
    # ------------------------------

    "refferals" => @police_refferal_count + @medical_refferal_count + @shelter_refferal_count + @lawer_services_refferal_count + @protection_officer_refferal_count + @court_dlsa_refferal_count + @any_other_refferal_count,
    # Refferals --variable declaration
    'police_refferal_count' => @police_refferal_count,
    'medical_refferal_count' => @medical_refferal_count,
    'shelter_refferal_count' => @shelter_refferal_count,
    'lawer_services_refferal_count' => @lawer_services_refferal_count,
    'protection_officer_refferal_count' => @protection_officer_refferal_count,
    'court_dlsa_refferal_count' => @court_dlsa_refferal_count, 
    'any_other_refferal_count' => @any_other_refferal_count,
    # -----------------------------

    "refferals_ongoing" => @police_refferal_count_ongoing_client + @medical_refferal_count_ongoing_client + @shelter_refferal_count_ongoing_client + @lawer_services_refferal_count_ongoing_client + @protection_officer_refferal_count_ongoing_client + @court_dlsa_refferal_count_ongoing_client + @any_other_refferal_count_ongoing_client,
    # Refferals ongoing --variable declaration
    'police_refferal_count_ongoing_client' => @police_refferal_count_ongoing_client,
    'medical_refferal_count_ongoing_client' => @medical_refferal_count_ongoing_client,
    'shelter_refferal_count_ongoing_client' => @shelter_refferal_count_ongoing_client,
    'lawer_services_refferal_count_ongoing_client' => @lawer_services_refferal_count_ongoing_client,
    'protection_officer_refferal_count_ongoing_client' => @protection_officer_refferal_count_ongoing_client,
    'court_dlsa_refferal_count_ongoing_client' => @court_dlsa_refferal_count_ongoing_client, 
    'any_other_refferal_count_ongoing_client' => @any_other_refferal_count_ongoing_client,
    # -----------------------------

    "other_intervention" => @othr_inter_home_visit_count + @othr_inter_visit_inst_count + @othr_inter_comm_edu_count + @othr_inter_meet_local_count + @othr_inter_inter_with_police_count + @othr_inter_any_other_count,
    #Other interventions in the community  --variable declaration
    'othr_inter_home_visit_count' => @othr_inter_home_visit_count,
    'othr_inter_visit_inst_count' => @othr_inter_visit_inst_count,
    'othr_inter_comm_edu_count' => @othr_inter_comm_edu_count,
    'othr_inter_meet_local_count' => @othr_inter_meet_local_count,
    'othr_inter_inter_with_police_count' => @othr_inter_inter_with_police_count,
    'othr_inter_any_other_count' => @othr_inter_any_other_count,

    # -------------------------------

    "outcomes" => @outcomes_helped_in_case_filed_for_divorce_count + @outcome_streedhan_retrival_count + @outcome_pwdva_2005_count + @outcome_498A_count + @outcome_maintenence_count + @outcome_non_violent_recon_count + @outcome_court_order_count + @outcome_any_other_count,
    # Outcomes   --variable declaration
    'outcomes_helped_in_case_filed_for_divorce_count' => @outcomes_helped_in_case_filed_for_divorce_count,
    'outcome_streedhan_retrival_count' => @outcome_streedhan_retrival_count,
    'outcome_pwdva_2005_count' => @outcome_pwdva_2005_count,
    'outcome_498A_count' => @outcome_498A_count,
    'outcome_maintenence_count' => @outcome_maintenence_count,
    'outcome_non_violent_recon_count' => @outcome_non_violent_recon_count,
    'outcome_court_order_count' => @outcome_court_order_count,
    'outcome_any_other_count' => @outcome_any_other_count,
    # ----------------------------------

    "outcomes_ongoing" => @outcomes_helped_in_case_filed_for_divorce_count_ongoing_client + @outcome_streedhan_retrival_count_ongoing_client + @outcome_pwdva_2005_count_ongoing_client + @outcome_498A_count_ongoing_client + @outcome_maintenence_count_ongoing_client + @outcome_non_violent_recon_count_ongoing_client + @outcome_court_order_count_ongoing_client + @outcome_any_other_count_ongoing_client,
    # Outcomes ongoing --variable declaration
    'outcomes_helped_in_case_filed_for_divorce_count_ongoing_client' => @outcomes_helped_in_case_filed_for_divorce_count_ongoing_client,
    'outcome_streedhan_retrival_count_ongoing_client' => @outcome_streedhan_retrival_count_ongoing_client,
    'outcome_pwdva_2005_count_ongoing_client' => @outcome_pwdva_2005_count_ongoing_client,
    'outcome_498A_count_ongoing_client' => @outcome_498A_count_ongoing_client,
    'outcome_maintenence_count_ongoing_client' => @outcome_maintenence_count_ongoing_client,
    'outcome_non_violent_recon_count_ongoing_client' => @outcome_non_violent_recon_count_ongoing_client,
    'outcome_court_order_count_ongoing_client' => @outcome_court_order_count_ongoing_client,
    'outcome_any_other_count_ongoing_client' => @outcome_any_other_count_ongoing_client
})
  end
end

  

