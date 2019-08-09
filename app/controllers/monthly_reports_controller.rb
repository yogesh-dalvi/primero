class MonthlyReportsController < ApplicationController

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

  def generate_pdf
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = MonthlyReportPdf.new(@users,params[:data])
        send_data pdf.render, filename: 'report.pdf', type: 'application/pdf',disposition: "inline"
      end
    end
  end

  def submit_form
    state = params[:state]
    select_mh = params[:district1]
    select_dl = params[:district2]
    select_ncw = params[:district3]
    start_date = params[:start_date]
    end_date = params[:end_date] 
    puts start_date
    puts end_date
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
          redirect_to action: "show_mpr",state: state, district: select_mh, start_date: start_date, end_date: end_date
        end
        if state == "delhi_64730"
          redirect_to action: "show_mpr",state: state, district: select_dl, start_date: start_date, end_date: end_date
        end
        if state == "ncw_37432"
          redirect_to action: "show_mpr",state: state, district: select_ncw, start_date: start_date, end_date: end_date
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
    

  def show_mpr
    @data=[]
    state = params[:state]
    district =params[:district]
    start_date = params[:start_date]
    end_date = params[:end_date]
    @selected_state= state
    @selected_district= district

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

    if district.empty?
      clients_reffered_by = Child.by_state_date_clients_reffered_by.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      nature_of_interaction = Child.by_state_date_nature_of_interaction.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      conducted_session_or_prog_count_array = Child.by_state_date_programme_participation.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']
      new_refferals_array = Child.by_state_date_new_refferals.startkey([state,1,start_date]).endkey([state,1,end_date,{}]).reduce.group['rows']
      one_time_intervention_array= Child.by_state_date_onetime_intervention.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']
      home_visits_array= Child.by_state_date_other_interevention_home_visits.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']  
      collateral_visits_array= Child.by_collateral_visits.startkey([start_date]).endkey([end_date,{}])['rows']
      participation_array= Child.by_programme_participation.startkey([state,1,start_date]).endkey([state,1,end_date,{}])['rows']  
    else
      clients_reffered_by = Child.by_clients_reffered_by.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      nature_of_interaction = Child.by_nature_of_interaction.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      conducted_session_or_prog_count_array = Child.by_programme_participation.startkey([state,district,start_date]).endkey([state,district,end_date,{}])['rows']
      new_refferals_array = Child.by_new_refferals.startkey([state,district,start_date]).endkey([state,district,end_date,{}]).reduce.group['rows']
      one_time_intervention_array= Child.by_onetime_intervention.startkey([state,district,start_date]).endkey([state,district,end_date,{}])['rows']
      home_visits_array= Child.by_other_interevention_home_visits.startkey([state,district,start_date]).endkey([state,district,end_date,{}])['rows']
      collateral_visits_array= Child.by_collateral_visits.startkey([start_date]).endkey([end_date,{}])['rows']
      participation_array= Child.by_programme_participation.startkey([state,district,start_date]).endkey([state,district,end_date,{}])['rows']  
    end
    for i in clients_reffered_by
      if !i['key'][0].empty? && !i['key'][2].empty?
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
        else
          @any_other_count += i['value']
        end
      end
    end
    
    for i in nature_of_interaction
      if !i['key'][0].empty? && !i['key'][2].empty?
        if i['key'][3].include? "group_meetings" or i['key'][3].include? "joint_meetings"
          @group_meeting_count += i['value']
        elsif i['key'][3].include? "individual_meetings_sessions"
          @individual_meeting_count += i['value']
        end
      end
    end
  
    for i in conducted_session_or_prog_count_array
        @conducted_session_or_prog_count+= i['value']
    end
    

    
    for i in new_refferals_array
      if !i['key'][0].empty? && !i['key'][2].empty?
        for j in i['key'][3]
          if j.include? "court_dlsa" or j.include? "lawyer" or j.include? "court_lawyers_legal_organisations"
            @legal_services_count += i['value']
          end
          if j.include? "medical_service"
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
          if j.include? "government_organisation_go" or j.include? "non_governmental_organisation_ngo" or j.include? "community_based_organisations_cbo" or j.include? "any_other"
            @lok_shiyakat_niwaran_count+= i['value']
          end
        end
      end
    end
  
    for i in one_time_intervention_array  
      @one_time_intervention_count += i['value']
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
  # @start_date_for_display = Date.parse(start_date)
  end_date = (Date.parse(end_date)-1).to_s
  @end_date_for_display = end_date
  @start_date_for_display = start_date

  for i in @state_array
    if i[1]!= nil
      if i.include? state
        @state_in_pdf=i[0]
        break
      end
    end
  end

  if state.include? "maharashtra_94827"
    for i in @maha_location_array
      if i[1]!= nil
        if i.include? district
          @district_in_pdf=i[0]
          break
        end
      end
    end
  
  elsif state.include? "delhi_64730" 
    for i in @delh_location_array
      if i[1]!= nil
        if i.include? district
          @district_in_pdf=i[0]
          break
        end
      end
    end
  elsif state.include? "ncw_37432"
    for i in @ncw_location_array
      if i[1]!= nil
        if i.include? district
          @district_in_pdf=i[0]
          break
        end
      end
    end
  end
  @start_date_in_pdf=Date.parse(start_date).strftime("%d-%m-%Y")
  @end_date_in_pdf=Date.parse(end_date).strftime("%d-%m-%Y")
  @data.push(@police_count,@exclients_count,@word_of_mouth_count,@self_count,@lawyers_legal_org_count,@ngo_count,@go_count,@icw_pw_count,@any_other_count,@one_time_intervention_count,@home_visit_count,@collateral_visits_count,@individual_meeting_count,@group_meeting_count,@participation_count,@programs_organised_count,@conducted_session_or_prog_count,@police_reffered_to_count,@medical_count,@shelter_count,@legal_services_count,@protection_officer_count,@lok_shiyakat_niwaran_count,@on_going_intevention_count,@engaing_police_help_count,@state_in_pdf,@district_in_pdf,@start_date_in_pdf,@end_date_in_pdf)
end

end

  

