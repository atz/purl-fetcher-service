class DocsController < ApplicationController
  include Indexer

  # Stub function that renders 'ok' when index is called.  Under the current spec, this should never be called.
  def index
    render_result('ok')
  end

  # API call to get a full list of all solr documents modified between two times
  # @param [querystring] Parameters can be specified in the querystring
  #   * first_modified = datetime in UTC (default: earliest possible date)
  #   * last_modified = datetime in UTC (default: current time)
  #
  # Example:
  #   http://localhost:3000/changes  # gives all items modified from the Unix Epoch until now
  #   http://localhost:3000/changes?first_modified=2014-01-01T00:00:00Z # returns only the modified documents SINCE January of 2014 up until today in json format
  def changes
    result = get_modified_from_solr(first_modified: params['first_modified'], last_modified: params['last_modified'])
    render_result(result)
  end

  # API call to get a full list of all solr documents deletes between two times
  # @param [querystring] Parameters can be specified in the querystring
  #   * first_modified = datetime in UTC (default: earliest possible date)
  #   * last_modified = datetime in UTC (default: current time)
  #
  # Example:
  #   http://localhost:3000/deletes  # gives all items deleted from the Unix Epoch until now
  #   http://localhost:3000/deletes?first_modified=2014-01-01T00:00:00Z # returns only the modified deleted SINCE January of 2014 up until today in json format
  def deletes
    result = get_deletes_list_from_solr(first_modified: params['first_modified'], last_modified: params['last_modified'])
    render_result(result)
  end

  # This is reachable via calling just /docs, currently we have no behavior associated, hence the message.
  def show
    render_result('Current API has no definition for just calling /docs.  Call /docs/changes or /docs/deletes')
  end
end
