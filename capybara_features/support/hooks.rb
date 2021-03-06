# Generating large audio/photo. Rspec only created the files. The rspec and cucumber test run on
# different envs on the jenkins server, so the files were not being generated for cucumber.

include UploadableFiles
uploadable_large_photo
uploadable_large_audio

# Before do
#   Child.stub :index_record => true, :reindex! => true, :build_solar_schema => true
#   Sunspot.stub :index => true, :index! => true
# end

# Before('@search') do
#   RSpec::Mocks.proxy_for(Child).reset
#   RSpec::Mocks.proxy_for(Sunspot).reset
#   Sunspot.remove_all!(Child)
#   Sunspot.remove_all!(Enquiry)
# end

Before do
  I18n.locale = I18n.default_locale = :en

  models_2_clean = ['Child', 'Incident', 'TracingRequest']
  CouchRest::Model::Base.descendants.each do |model|
    if models_2_clean.include? model.name
      docs = model.database.documents["rows"].map { |doc|
        { "_id" => doc["id"], "_rev" => doc["value"]["rev"], "_deleted" => true } unless doc["id"].include? "_design"
      }.compact
      RestClient.post "#{model.database.root}/_bulk_docs", { :docs => docs }.to_json, { "Content-type" => "application/json" } unless docs.empty?
    end
  end

  #Only load the seed files ONCE.
  #Don't load the seed data on every scenario
  $db_seeded ||= false
  unless $db_seeded
    #TODO: Commented out as per Ron's request. Some tests currently reseed these.
    #Long term should refactor to use the initial lookup seed.
    #load File.dirname(__FILE__) + '/../../db/lookups/lookups.rb'
    Dir[File.dirname(__FILE__) + '/../../db/forms/*/*.rb'].each {|file| load file }

    #Reload the form properties
    [Child, Incident, TracingRequest].each {|record_cls| record_cls.refresh_form_properties}

    load File.dirname(__FILE__) + '/../../db/users/roles.rb'
    load File.dirname(__FILE__) + '/../../db/users/default_programs.rb'
    load File.dirname(__FILE__) + '/../../db/users/default_modules.rb'
    load File.dirname(__FILE__) + '/../../db/users/default_user_groups.rb'
    load File.dirname(__FILE__) + "/../../db/users/default_users.rb"

    #Fake the passwords
    User.all.each do |user|
      user.password = 'primero'
      user.password_confirmation = 'primero'
      user.save!
    end

    $db_seeded = true
  end

end

Before('@roles') do |scenario|
  #TODO: Instead of the roles below, consider loading db/users/roles.rb
  Role.create(:name => 'Field Worker', :permissions => [Permission::CASE, Permission::READ, Permission::WRITE])
  Role.create(:name => 'Field Admin', :permissions => [Permission::CASE, Permission::READ, Permission::WRITE, Permission::USER])
  Role.create(:name => 'Admin', :permissions => Permission.all_permissions)
end

at_exit do
  cleanup_databases
end
