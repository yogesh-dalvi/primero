class GeneralReport < CouchRest::Model::Base
    use_database :child
    property :module_ids, [String]
    design do
        
        view :repomaha,
            :map
                function(doc) {
                    if(doc.location=="maharashtra_94827"){
                        emit([doc.location,doc.district],1);
                    }
                }
            :reduce
                _sum
          
    end
