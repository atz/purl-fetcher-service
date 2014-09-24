require 'rails_helper'

describe("Fetcher lib")  do
  
  before :each do
    @fetcher=FetcherTester.new
  end
  
  it "should raise an exception for either starting of ending date in an invalid format" do
    expect{@fetcher.get_times({first_modified:'01/01/2010 10:00:00am',last_modified:'ness'})}.to raise_error("invalid time paramaters")
    expect{@fetcher.get_times({first_modified:'bogus',last_modified:'01/01/2010 10:00:00am'})}.to raise_error("invalid time paramaters")
    expect{@fetcher.get_times({first_modified:'bogus',last_modified:'ness'})}.to raise_error("invalid time paramaters")
  end

  it "should return the properly formatted hash for various valid types of input date or time" do
    expected={first:'2010-01-01T18:00:00Z',last:'2011-01-01T18:00:00Z'}
    inputs=[
      {first_modified:'01/01/2010 10:00:00am',last_modified:'01/01/2011 10:00:00am'},
      {first_modified:'2010-01-01T18:00:00Z',last_modified:'01/01/2011 10:00:00am'},
      {first_modified:'01/01/2010 10:00:00am',last_modified:'2011-01-01T18:00:00Z'}
    ]
    inputs.each do |input|
      expect(@fetcher.get_times(input)).to eq(expected)
    end
    expect(@fetcher.get_times({first_modified:'01/01/2010',last_modified:'2011-01-01T18:00:00Z'})).to eq({first:'2010-01-01T08:00:00Z',last:'2011-01-01T18:00:00Z'})
    expect(@fetcher.get_times({first_modified:'2011-01-01T18:00:00Z',last_modified:'2014-12-01'})).to eq({first:'2011-01-01T18:00:00Z',last:'2014-12-01T08:00:00Z'})
    expect(@fetcher.get_times({first_modified:'January 1, 2009',last_modified:'2012-01-01T18:00:00Z'})).to eq({first:'2009-01-01T08:00:00Z',last:'2012-01-01T18:00:00Z'})
  end

  it "should parse druids correctly" do
    expect(@fetcher.parse_druid('druid:oo000oo0001')).to eq('oo000oo0001')
    expect(@fetcher.parse_druid('oo000oo0001')).to eq('oo000oo0001')
    expect(@fetcher.parse_druid('bogousoo000oo0001')).to eq('oo000oo0001')
    expect{@fetcher.parse_druid('bogus')}.to raise_error('invalid druid')
  end
  
end
  