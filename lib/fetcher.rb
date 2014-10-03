# A mixin module that is part of application controller, this provides base functionality to all classes
module Fetcher

  # Given the user's querystring parameters, and a fedora type, return a solr response containing all of the objects associated with that type (potentially limited by rows or date if specified by the user)
  #
  # @return [hash] solr response
  #
  # @param params [hash] querystring parameters from user, which could be an empty hash
  # @param ftype [string] fedora object type, could be :apo or :collection
  #
  # Example:
  #   find_all_fedora_type(params,:apo)
  def find_all_fedora_type(params,ftype)
    
    #ftype should be :collection or :apo (or other symbol if we added more since this was updated)

    times = get_times(params)

    solrparams={:q => "#{Type_Field}:\"#{Fedora_Types[ftype]}\" AND #{Last_Changed_Field}:[\"#{times[:first]}\" TO \"#{times[:last]}\"]", :wt => :json, :fl =>"#{ID_Field}"}
    get_rows(solrparams,params)
    
    response = Solr.get 'select', :params => solrparams
    
    return response
    
  end

  # Given the user's querystring parameters (including the ID paramater, which represents the druid), and a fedora object type, return a solr response containing all of the objects controlled by that druid of that type (potentially limited by rows or date if specified by the user)
  #
  # @return [hash] solr response
  #
  # @param params [hash] querystring parameters from user, which must include :id of the druid
  # @param controlled_by [string] fedora object type, could be :apo or :collection
  #
  # Example:
  #   find_all_fedora_type(params,:apo)  
  def find_all_under(params, controlled_by)
    #controlled_by should be :collection or :apo (or other symbol if we added more since this was updated)
    
    times = get_times(params)
    
    solrparams= {
      :q => "(#{Controller_Types[controlled_by]}:\"#{druid_of_controller(params[:id])}\" OR #{ID_Field}:\"#{druid_for_solr(params[:id])}\") AND #{Last_Changed_Field}:[\"#{times[:first]}\" TO \"#{times[:last]}\"]", 
      :wt => :json,
      :fl => "#{ID_Field} AND #{Last_Changed_Field} AND #{Type_Field}"
      }
      get_rows(solrparams,params)

    response = Solr.get 'select', :params => solrparams
  
    #TODO: If APO in response and said APO's druid != user provided druid, recursion!  
    
    return response  
  end

  # Given the user's querystring parameters (including the ID paramater, which represents the tag), return a solr response containing all of the objects associated with the supplied tag(potentially limited by rows or date if specified by the user)
  #
  # @return [hash] solr response
  #
  # @param params [hash] querystring parameters from user, which must include :id of the tag
  #
  # Example:
  #   find_by_tag(params)    
  def find_by_tag(params)
    times = get_times(params)

    solrparams={
      :q => "(#{Controller_Types[:tag]}:\"#{params[:tag]}\") AND #{Last_Changed_Field}:[\"#{times[:first]}\" TO \"#{times[:last]}\"]", 
      :wt => :json,
      :fl => "#{ID_Field} AND #{Last_Changed_Field} AND #{Type_Field}"
      }

      get_rows(solrparams,params)
    
    response = Solr.get 'select', :params => solrparams

    return response

  end

  # Given a druid without the druid prefix (e.g. oo000oo0001), add the prefixes needed for querying solr for controllers
  #
  # @return [string] druid
  #
  # @param druid [string] druid
  #
  # Example:
  #   druid_for_controller('oo000oo0001') # returns info:fedora/druid:oo000oo0001
  def druid_of_controller(druid)
    return Fedora_Prefix + Druid_Prefix + parse_druid(druid)
  end

  # Given a druid without the druid prefix (e.g. oo000oo0001), add the prefix needed for querying solr
  #
  # @return [string] druid
  #
  # @param druid [string] druid
  #
  # Example:
  #   druid_for_solr('oo000oo0001') # returns druid:oo000oo0001
  def druid_for_solr(druid)
    return Druid_Prefix + parse_druid(druid)
  end
  
  # Given a druid in any format (e.g. oo000oo0001 or druid:oo00oo0001), returns only the numberical part, stripping the "druid:" prefix
  # If invalid druid passed, will raise an exception.
  #
  # @return [string] druid
  #
  # @param druid [string] druid
  #
  # Example:
  #   parse_druid('oo000oo0001') # returns oo000oo0001
  #   parse_druid('druid:oo000oo0001') # returns oo000oo0001
  #   parse_druid('junk') # throws an exception
  def parse_druid(druid)
    matches = druid.match(/[a-zA-Z]{2}\d{3}[a-zA-Z]{2}\d{4}/)
    matches.nil? ? raise("invalid druid") : matches[0]
  end
 
  # Given a hash containing "first_modified" and "last_modified", ensures the date formats are valid, converts to proper ISO8601 if they are.
  # If first_modified is missing, sets to the earliest possible date.
  # If last_modified is missing, sets to current date/time.
  # If invalid dates are passed in, throws an exception.
  #
  # @return [hash] containing :first and :last keys with proper vaues
  #
  # @param p [hash] which includes :first_modified and :last_modified keys as coming in from the querystring from the user
  #
  # Example:
  #   get_times(:first_modified=>'01/01/2014') # returns {:first=>'2014-01-01T00:00:00Z',last:'CURRENT_DATETIME_IN_UTC_ISO8601'}
  #   get_times(:first_modified=>'junk') # throws exception
  #   get_times(:first_modified=>'01/01/2014',:last_modified=>'01/01/2015') # returns {:first=>'2014-01-01T00:00:00Z',last:'2015-01-01T00:00:00Z'}
  def get_times(p = {})
    params = p || {}
    first_modified = params[:first_modified] || Time.at(0).utc.iso8601
    last_modified = params[:last_modified] || Date.tomorrow.to_time.utc.iso8601
    begin 
      first_modified_time=Time.parse(first_modified)
      last_modified_time=Time.parse(last_modified)
    rescue
      raise "invalid time paramaters"
    end
    start_time = first_modified_time.utc.iso8601 
    end_time = last_modified_time.utc.iso8601 
    raise "start time is before end time" if start_time >= end_time
    return {:first => start_time, :last => end_time}
  end

  # Given a params hash that will be passed to solr, adds in the proper :rows value depending on if we are requesting a certain number of rows or not
  #
  # @return [hash] solr params hash
  #
  # @param solrparams [hash] solr params has to be altered
  # @param params [hash] query string params from user
  #
  def get_rows(solrparams,params)
    params.has_key?(:rows) ? solrparams.merge!(:rows => params[:rows]) : solrparams.merge!(:rows => 100000000)  # if user passes in the rows they want, use that, else just return everything
  end
  
end