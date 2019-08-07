class QuarterlyReportsController < ApplicationController

  def initialize
    super()
    @state_array = ::STATE
    @maha_location_array = ::MAHLOCATION
    @delh_location_array = DELHILOCATION
    @ncw_location_array = NCWLOCATION
  end

  def index
    authorize! :index, Child
    set_end_date_empty=false
    set_start_date_empty=false
    set_state_empty=false
    @state_not_selected = false
    @start_date_not_selected = false
    @end_date_not_selected = false
    @date_validation = false
    @state_not_selected = params[:state_not_selected].to_s
    @start_date_not_selected = params[:start_date_not_selected].to_s
    @end_date_not_selected = params[:end_date_not_selected].to_s
    @date_validation = params[:x].to_s
    @start_date_for_display = params[:s_d].to_s
    @end_date_for_display = params[:e_d].to_s
  end

  def quarterly_pdf
    respond_to do |format|
      format.html
      format.pdf do
        pdf = QuarterlyReportPdf.new(@users,params[:data])
        send_data pdf.render, filename: 'report.pdf', type: 'application/pdf',disposition: "inline"
      end
    end
  end

  def submit_form
    authorize! :submit_form, Child
    state = params[:state]
    select_mh = params[:district1]
    select_dl = params[:district2]
    select_ncw = params[:district3]
    start_date = params[:start_date]
    end_date = params[:end_date] 
    set_district_empty=false
    set_state_empty=false
    set_start_date_empty=false
    set_end_date_empty=false
    set_start_date_greater_than_end_date=false

    if !state.empty? && !start_date.empty? && !end_date.empty?
      end_date_in_date=Date.parse(end_date)
      start_date_in_date=Date.parse(start_date)
      end_date = (end_date_in_date+1).to_s
      if start_date_in_date <= end_date_in_date
        if state == "maharashtra_94827"
          redirect_to action: "show_qpr",state: state, district: select_mh, start_date: start_date, end_date: end_date
        end
        if state == "delhi_64730"
          redirect_to action: "show_qpr",state: state, district: select_dl, start_date: start_date, end_date: end_date
        end
        if state == "ncw_37432"
          redirect_to action: "show_qpr",state: state, district: select_ncw, start_date: start_date, end_date: end_date
        end
      end
    end

    if state.empty? 
      set_state_empty=true
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
    if set_state_empty == true || set_start_date_empty==true || set_end_date_empty==true || set_start_date_greater_than_end_date==true
      redirect_to action: "index", state_not_selected: set_state_empty, start_date_not_selected: set_start_date_empty, end_date_not_selected:set_end_date_empty, x:set_start_date_greater_than_end_date,s_d: start_date, e_d: end_date
    end
    
  end
    

  def show_qpr
    authorize! :show_qpr, Child
    @data=[]
    state = params[:state]
    district =params[:district]
    start_date = params[:start_date]
    end_date = params[:end_date] 
    @selected_state= state
    @selected_district= district

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
    @outcome_any_other_count_ongoing_client=0
    # ----------------------------------
    
    # /checking state and on that basis getting the first district and last district for view query/
    if district.empty?
      clients_reffered_by = Child.by_state_date_clients_reffered_by.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      gender_of_complaint = Child.by_state_date_gender_of_complaint.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      age_of_client = Child.by_state_date_age_of_client.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      education_of_client = Child.by_state_date_client_education.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      reasons_fr_reg_at_spec_cell = Child.by_state_date_reasons_for_registering_at_the_special_cell.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      vio_by_husband = Child.by_state_date_vio_by_husband.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      vio_by_marital_family = Child.by_state_date_vio_by_martial_family.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      previous_intervention_before_coming_to_the_cell = Child.by_state_date_previous_intervention_before_coming_to_the_cell.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      intervention_by_special_cell = Child.by_state_date_intervention_by_special_cell.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      negotiating_nonviolence = Child.by_state_date_negotiating_nonviolence.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      referrals_new_clients_ongoing_clients = Child.by_state_date_referrals_new_clients_ongoing_clients.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      other_interventions_taking_place_outside_the_cell = Child.by_state_date_other_interventions_taking_place_outside_the_cell.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      outcomes_new_clients_ongoing_clients = Child.by_state_date_outcomes_new_clients_ongoing_clients.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']

    else
      clients_reffered_by = Child.by_clients_reffered_by.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      gender_of_complaint = Child.by_gender_of_complaint.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      age_of_client = Child.by_age_of_client.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      education_of_client = Child.by_client_education.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      reasons_fr_reg_at_spec_cell = Child.by_reasons_for_registering_at_the_special_cell.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      vio_by_husband = Child.by_vio_by_husband.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      vio_by_marital_family = Child.by_vio_by_marital_family.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      previous_intervention_before_coming_to_the_cell = Child.by_previous_intervention_before_coming_to_the_cell.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      intervention_by_special_cell = Child.by_intervention_by_special_cell.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      negotiating_nonviolence = Child.by_negotiating_nonviolence.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      referrals_new_clients_ongoing_clients = Child.by_referrals_new_clients_ongoing_clients.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      other_interventions_taking_place_outside_the_cell = Child.by_other_interventions_taking_place_outside_the_cell.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      outcomes_new_clients_ongoing_clients = Child.by_outcomes_new_clients_ongoing_clients.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']

    end
    # /end----------------------------------------------/
    
    total_clients_in_this_quarter = Child.by_clients_registered_in_this_quarter.startkey([start_date]).endkey([end_date,{}]).reduce.group['rows']
    for i in total_clients_in_this_quarter
      @total_clients += i['value']
    end  
    puts total_clients_in_this_quarter
    # calculation of clients reffered by
    for i in clients_reffered_by
      if !i['key'][0].empty? && !i['key'][2].empty? 
        if i['key'][3]!=nil
          if i['key'][3].include? "ex_clients"
            @exclients_count += i['value']
          elsif i['key'][3].include? "independent_community_worker_political_worker"
            @icw_pw_count += i['value']
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
          else
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
          elsif i['key'][3].include? "primary_level_class_4"
            @primary_level_class_4_count += i['value']
          elsif i['key'][3].include? "upto_ssc_passed_class_10"
            @upto_ssc_count += i['value']
          elsif i['key'][3].include? "upto_hsc_passed_class_12"
            @upto_hsc_count += i['value']
          elsif i['key'][3].include? "graduation_bachelor_s_degree"
            @upto_grad_count += i['value']
          elsif i['key'][3].include? "post_graduation_master_s_degree"
            @post_grad_count += i['value']
          elsif i['key'][3].include? "religious_education" or i['key'][3].include? "any_other" or i['key'][3].include? "diploma"
            @any_other_edu_count += i['value']  
          elsif i['key'][3].include? "information_not_available"
            @no_edu_info_count += i['value']
          end
        end
      end
    end 
    
    for i in reasons_fr_reg_at_spec_cell
      if !i['key'][0].empty? && !i['key'][2].empty?
        if !i['key'][3].empty?
          for j in i['key'][3]
            if j.include? "harassment_of_natal_family_members_of_the_woman_by_the_husband_family"
              @harr_natal_family_by_hus_count += i['value']
            elsif j.include? "deprivation_of_matrimonial_residence"
              @dep_matr_res_count += i['value']
            elsif j.include? "child_battering_by_husband_family"
              @childbattering_count += i['value']
            elsif j.include? "dowry_demands_by_husband_family"
              @dowry_count += i['value']
            elsif j.include? "harassment_by_natal_family"
              @harr_by_natal_family_count += i['value']
            elsif j.include? "harassment_by_children_and_their_spouses"
              @harr_by_chil_spouse_count += i['value']
            elsif j.include? "wife_has_left_the_matrimonial_home_male_clients"
              @wife_left_matr_home_count += i['value']
            elsif j.include? "harassment_at_work_by_husband"
              @harr_at_work_count += i['value']
            elsif j.include? "harassment_by_live_in_partner"
              @harr_by_live_in_partner_count += i['value']
            elsif j.include? "sexual_assault"
              @sex_assault_count += i['value']
            elsif j.include? "sexual_harassment_in_other_situation"
              @sex_har_in_other_sit_count += i['value']
            elsif j.include? "breach_of_trust_in_intimate_relationship"
              @breach_of_trust_count += i['value']
            elsif j.include? "harassment_by_neighbours"
              @harr_by_neigh_count += i['value']
            elsif j.include? "others_specify"
              @any_other_harr_count += i['value']
            end
          end
        end
      end
    end

    for i in vio_by_husband
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3]!=nil
          if i['key'][3].include? "physical_violence_by_husband"
            @phy_vio_by_hus_count += i['value']
          elsif i['key'][3].include? "emotional_mental_violence_by_husband"
            @emo_men_vio_by_hus_count += i['value']
          elsif i['key'][3].include? "sexual_violence_by_husband"
            @sex_vio_by_hus_count += i['value']
          elsif i['key'][3].include? "financial_violence_by_husband"
            @fin_vio_by_hus_count += i['value']
          elsif i['key'][3].include? "out_of_marriage_relationship_second_marriage_by_husband"
            @sec_marr_by_hus_count += i['value']
          elsif i['key'][3].include? "refusal_to_give_streedhan"
            @ref_to_strredhan_by_hus_count += i['value']
          elsif i['key'][3].include? "alcohol_abuse_substance_abuse_by_husband"
            @alch_vio_by_hus_count += i['value']
          elsif i['key'][3].include? "desertion_by_husband"
            @desertion_by_hus_count += i['value']
          elsif i['key'][3].include? "child_custody_disputes_disputes_over_visitation_rights"
            @child_custody_vio_count += i['value']
          end
        end
      end
    end 
    
    for i in vio_by_marital_family
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3]!=nil
          if i['key'][3].include? "physical_violence_by_marital_family"
            @phy_vio_by_mart_family_count += i['value']
          elsif i['key'][3].include? "emotional_mental_violence_by_marital_family"
            @emo_vio_by_mart_family_count += i['value']
          elsif i['key'][3].include? "sexual_violence_by_marital_family"
            @sex_vio_by_mart_family_count += i['value']
          elsif i['key'][3].include? "financial_violence_by_marital_family"
            @fin_vio_by_mart_family_count += i['value']
          end
        end
      end
    end 

    for i in previous_intervention_before_coming_to_the_cell
      if !i['key'][0].empty? && !i['key'][2].empty?
        if !i['key'][3].empty?
          for j in i['key'][3]
            if j.include? "natal_family_marital_family"
              @prev_inter_natal_family_marital_family_count += i['value']
            elsif j.include? "police"
              @prev_inter_police_count += i['value']
            elsif j.include? "court_lawyers"
              @prev_inter_court_count += i['value']
            elsif j.include? "non_governmental_organisation_ngo"
              @prev_interv_ngo_count += i['value']
            elsif j.include? "panchayat_member_jati_panchayat" or j.include? "jamat_samaj_jat_panchayat"
              @prev_interv_panch_mem_count += i['value']
            elsif j.include? "any_other"
              @prev_interv_any_other_count += i['value']
            end
          end
        end
      end
    end

    # for current clients
    for i in intervention_by_special_cell
      if !i['key'][0].empty? && !i['key'][2].empty?
        if !i['key'][3].empty?
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
            end
          end
        end
      end
    end

    for i in negotiating_nonviolence
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3]!=nil
          if i['key'][3].include? "negotiating_non_violence_with_stakeholder"
            @spec_cell_neg_nonvio_with_stakeholder_count  += i['value'] 
          end
        end
      end
    end

    for i in referrals_new_clients_ongoing_clients
      if !i['key'][0].empty? && !i['key'][2].empty?
        if !i['key'][3].empty?
          for j in i['key'][3]
            if j.include? "police"
              @police_refferal_count += i['value']
            elsif j.include? "medical_service"
              @medical_refferal_count += i['value']
            elsif j.include? "court_lawyers_legal_organisations"
              @court_dlsa_refferal_count += i['value']
            elsif j.include? "shelter_home"
              @shelter_refferal_count += i['value']
            elsif j.include? "protection_officer"
              @protection_officer_refferal_count += i['value']
            elsif j.include? "any_other"
              @any_other_refferal_count += i['value']
            end
          end
        end
      end
    end

    for i in other_interventions_taking_place_outside_the_cell
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3]!=nil
          if i['key'][3].include? "home_visits"
            @othr_inter_home_visit_count += i['value']
          elsif i['key'][3].include? "visits_to_institutions"
            @othr_inter_visit_inst_count += i['value']
          elsif i['key'][3].include? "community_education_programmes"
            @othr_inter_comm_edu_count += i['value']
          elsif i['key'][3].include? "interaction_with_police"
            @othr_inter_inter_with_police_count += i['value']
          elsif i['key'][3].include? "others_specify"
            @othr_inter_any_other_count += i['value']
          elsif i['key'][3].include? "meetings_with_local_groups_social_organisations"
            @othr_inter_meet_local_count += i['value']
          end
        end
      end
    end
    

    for i in outcomes_new_clients_ongoing_clients
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3]!=nil
          if i['key'][3].include? "helped_in_filing_case_in_court_for_divorce_separation"
            @outcomes_helped_in_case_filed_for_divorce_count += i['value']
          elsif i['key'][3].include? "helped_in_reteival_of_streedhan"
            @outcome_streedhan_retrival_count += i['value']
          elsif i['key'][3].include? "helped_in_filing_application_under_pwdva"
            @outcome_pwdva_2005_count += i['value']
          elsif i['key'][3].include? "helped_in_registering_fir_under_section_498a"
            @outcome_498A_count += i['value']
          elsif i['key'][3].include? "helped_the_woman_in_accessing_her_financial_entitlements"
            @outcome_maintenence_count += i['value']
          elsif i['key'][3].include? "non_violent_reconciliation"
            @outcome_non_violent_recon_count += i['value']
          elsif i['key'][3].include? "court_orders_in_the_best_interest_of_the_woman"
            @outcome_court_order_count += i['value']
          elsif i['key'][3].include? "others_specify"
            @outcome_any_other_count += i['value']
          end
        end
      end
    end
    # -------------------------------------

    # for ongoing clients 
    end_date_for_ongoing_clients = start_date
    start_date_for_ongoing_clients = "1000-01-01"


    if district.empty?
      intervention_by_special_cell = Child.by_state_date_intervention_by_special_cell.startkey([state,1,start_date_for_ongoing_clients]).endkey([state,1,end_date_for_ongoing_clients,{}]).reduce.group['rows']
      negotiating_nonviolence = Child.by_state_date_negotiating_nonviolence.startkey([state,1,start_date_for_ongoing_clients]).endkey([state,1,end_date_for_ongoing_clients,{}]).reduce.group['rows']
      referrals_new_clients_ongoing_clients = Child.by_state_date_referrals_new_clients_ongoing_clients.startkey([state,1,start_date_for_ongoing_clients]).endkey([state,1,end_date_for_ongoing_clients,{}]).reduce.group['rows']
      outcomes_new_clients_ongoing_clients = Child.by_state_date_outcomes_new_clients_ongoing_clients.startkey([state,1,start_date_for_ongoing_clients]).endkey([state,1,end_date_for_ongoing_clients,{}]).reduce.group['rows']
    else
      intervention_by_special_cell = Child.by_intervention_by_special_cell.startkey([state,district,start_date_for_ongoing_clients]).endkey([state,district,end_date_for_ongoing_clients,{}]).reduce.group['rows']
      negotiating_nonviolence = Child.by_negotiating_nonviolence.startkey([state,district,start_date_for_ongoing_clients]).endkey([state,district,end_date_for_ongoing_clients,{}]).reduce.group['rows']
      referrals_new_clients_ongoing_clients = Child.by_referrals_new_clients_ongoing_clients.startkey([state,district,start_date_for_ongoing_clients]).endkey([state,district,end_date_for_ongoing_clients,{}]).reduce.group['rows']
      outcomes_new_clients_ongoing_clients = Child.by_outcomes_new_clients_ongoing_clients.startkey([state,district,start_date_for_ongoing_clients]).endkey([state,district,end_date_for_ongoing_clients,{}]).reduce.group['rows']    
    end

    for i in intervention_by_special_cell
      if !i['key'][0].empty? && !i['key'][2].empty?
        if !i['key'][3].empty?
          for j in i['key'][3]
            if j.include? "providing_emotional_support_and_strengthening_psychological_self"
              @spec_cell_prov_emo_support_count_ongoing_client += i['value']
            elsif j.include? "building_support_system"
              @spec_cell_build_support_system_count_ongoing_client += i['value']
            elsif j.include? "enlisting_police_help_or_intervention"
              @spec_cell_enlist_police_help_count_ongoing_client += i['value']
            elsif j.include? "legal_aid_legal_referral_pre_litigation_counselling"
              @spec_cell_pre­litigation_counsel_count_ongoing_client += i['value']
            elsif j.include? "working_with_men_in_the_interest_of_violated_woman"
              @spec_cell_work_with_men_count_ongoing_client += i['value']
            elsif j.include? "advocacy_for_financial_entitlements"
              @spec_cell_adv_fin_ent_count_ongoing_client += i['value']
            elsif j.include? "referral_for_shelter_medical_other_services"
              @spec_cell_refferal_for_shelter_count_ongoing_client += i['value']
            elsif j.include? "developmental_counselling"
              @spec_cell_dev_counsel_count_ongoing_client += i['value']
            end
          end
        end
      end
    end

    for i in negotiating_nonviolence
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3]!=nil
          if i['key'][3].include? "negotiating_non_violence_with_stakeholder"
            @spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client  += i['value'] 
          end
        end
      end
    end

    for i in referrals_new_clients_ongoing_clients
      if !i['key'][0].empty? && !i['key'][2].empty?
        if !i['key'][3].empty?
          for j in i['key'][3]
            if j.include? "police"
              @police_refferal_count_ongoing_client += i['value']
            elsif j.include? "medical_service"
              @medical_refferal_count_ongoing_client += i['value']
            elsif j.include? "court_lawyers_legal_organisations"
              @court_dlsa_refferal_count_ongoing_client += i['value']
            elsif j.include? "shelter_home"
              @shelter_refferal_count_ongoing_client += i['value']
            elsif j.include? "protection_officer"
              @protection_officer_refferal_count_ongoing_client += i['value']
            elsif j.include? "any_other"
              @any_other_refferal_count_ongoing_client += i['value']
            end
          end
        end
      end
    end

    for i in outcomes_new_clients_ongoing_clients
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3]!=nil
          if i['key'][3].include? "helped_in_filing_case_in_court_for_divorce_separation"
            @outcomes_helped_in_case_filed_for_divorce_count_ongoing_client += i['value']
          elsif i['key'][3].include? "helped_in_reteival_of_streedhan"
            @outcome_streedhan_retrival_count_ongoing_client += i['value']
          elsif i['key'][3].include? "helped_in_filing_application_under_pwdva_2005"
            @outcome_pwdva_2005_count_ongoing_client += i['value']
          elsif i['key'][3].include? "helped_in_registering_fir_under_section_498a"
            @outcome_498A_count_ongoing_client += i['value']
          elsif i['key'][3].include? "helped_the_woman_in_accessing_her_financial_entitlements"
            @outcome_maintenence_count_ongoing_client += i['value']
          elsif i['key'][3].include? "non_violent_reconciliation"
            @outcome_non_violent_recon_count_ongoing_client += i['value']
          elsif i['key'][3].include? "court_orders_in_the_best_interest_of_the_woman"
            @outcome_court_order_count_ongoing_client += i['value']
          elsif i['key'][3].include? "others_specify"
            @outcome_any_other_count_ongoing_client += i['value']
          end
        end
      end
    end
    
  end_date = (Date.parse(end_date)-1).to_s
  @end_date_for_display = end_date
  @start_date_for_display = start_date
  @data.push(@total_clients,@ongoing_clients,@no_of_ppl_prvded_supp,@exclients_count,@self_count,@police_count,@ngo_count,@community_based_org_count,@icw_pw_count,@word_of_mouth_count,@go_count,@lawyers_legal_org_count,@any_other_clients_refferd_count,@adult_female_count,@adult_male_count,@child_female_count,@child_male_count,@third_gender_count,@less_than_14_count,@in_15_17_count,@in_18_24_count,@in_25_34_count,@in_35_44_count,@in_45_54_count,@above_55_count,@no_age_info_count,@non_literate_count,@functional_literacy_count,@primary_level_class_4_count,@upto_ssc_count,@upto_hsc_count,@upto_grad_count,@post_grad_count,@any_other_edu_count,@no_edu_info_count,@phy_vio_by_hus_count,@emo_men_vio_by_hus_count,@sex_vio_by_hus_count,@fin_vio_by_hus_count,@sec_marr_by_hus_count,@ref_to_strredhan_by_hus_count,@alch_vio_by_hus_count,@desertion_by_hus_count,@child_custody_vio_count,@phy_vio_by_mart_family_count,@emo_vio_by_mart_family_count,@sex_vio_by_mart_family_count,@fin_vio_by_mart_family_count,@harr_natal_family_by_hus_count,@dep_matr_res_count,@childbattering_count,@dowry_count,@harr_by_natal_family_count,@harr_by_chil_spouse_count,@wife_left_matr_home_count,@harr_at_work_count,@harr_by_live_in_partner_count,@sex_assault_count,@sex_har_in_other_sit_count,@breach_of_trust_count,@harr_by_neigh_count,@any_other_harr_count,@prev_inter_natal_family_marital_family_count,@prev_inter_police_count,@prev_inter_court_count,@prev_interv_ngo_count,@prev_interv_panch_mem_count,@prev_interv_any_other_count,@spec_cell_prov_emo_support_count,@spec_cell_prov_emo_support_count_ongoing_client,@spec_cell_neg_nonvio_with_stakeholder_count,@spec_cell_neg_nonvio_with_stakeholder_count_ongoing_client,@spec_cell_build_support_system_count,@spec_cell_build_support_system_count_ongoing_client,@spec_cell_enlist_police_help_count,@spec_cell_enlist_police_help_count_ongoing_client,@spec_cell_pre­litigation_counsel_count,@spec_cell_pre­litigation_counsel_count_ongoing_client,@spec_cell_work_with_men_count,@spec_cell_work_with_men_count_ongoing_client,@spec_cell_adv_fin_ent_count,@spec_cell_adv_fin_ent_count_ongoing_client,@spec_cell_refferal_for_shelter_count,@spec_cell_refferal_for_shelter_count_ongoing_client,@spec_cell_dev_counsel_count,@spec_cell_dev_counsel_count_ongoing_client,@police_refferal_count,@police_refferal_count_ongoing_client,@court_dlsa_refferal_count,@court_dlsa_refferal_count_ongoing_client,@shelter_refferal_count,@shelter_refferal_count_ongoing_client,@medical_refferal_count,@medical_refferal_count_ongoing_client,@lawer_services_refferal_count,@lawer_services_refferal_count_ongoing_client,@protection_officer_refferal_count,@protection_officer_refferal_count_ongoing_client,@any_other_refferal_count,@any_other_refferal_count_ongoing_client,@othr_inter_home_visit_count,@othr_inter_visit_inst_count,@othr_inter_comm_edu_count,@othr_inter_meet_local_count,@othr_inter_inter_with_police_count,@othr_inter_any_other_count,@outcomes_helped_in_case_filed_for_divorce_count,@outcomes_helped_in_case_filed_for_divorce_count_ongoing_client,@outcome_streedhan_retrival_count,@outcome_streedhan_retrival_count_ongoing_client,@outcome_pwdva_2005_count,@outcome_pwdva_2005_count_ongoing_client,@outcome_498A_count,@outcome_498A_count_ongoing_client,@outcome_maintenence_count,@outcome_maintenence_count_ongoing_client,@outcome_non_violent_recon_count,@outcome_non_violent_recon_count_ongoing_client,@outcome_court_order_count,@outcome_court_order_count_ongoing_client,@outcome_any_other_count,@outcome_any_other_count_ongoing_client)  
end


end

  

