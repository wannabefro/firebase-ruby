require 'spec_helper'

describe "Firebase Request" do
  response = Typhoeus::Response.new(code: 200, body: "{'users' : 'eugene'}")
  Typhoeus.stub('www.test.firebaseio.com').and_return(response)
  Typhoeus.stub('www.instance.firebaseio.com').and_return(response)

  after do
    Firebase.base_uri = nil
    Firebase.auth = nil
  end

  describe "url_builder" do
    it "should build the correct url when passed no path" do
      Firebase.base_uri = 'https://test.firebaseio.com'
      Firebase::Request.build_url(nil).should == 'https://test.firebaseio.com/.json'
    end
  end

  describe "url_builder" do
    it "should build the correct url when passed a path" do
      Firebase.base_uri = 'https://test.firebaseio.com'

      Firebase::Request.build_url('users/eugene').should == 'https://test.firebaseio.com/users/eugene.json'
    end
  end

  describe "url_builder for FirebaseInstance" do
    it "should build the correct url when an instance calls it" do
      Firebase.base_uri = 'https://test.firebaseio.com'
      firebase_instance = Firebase.new("https://instance.firebaseio.com")

      Firebase::Request.should_receive(:build_url).with('users/eugene', 'https://instance.firebaseio.com/', nil)
      firebase_instance.set('users/eugene', 'hello')
    end

    it "should default to Firebase.base_uri if none is given to the instance" do
      Firebase.base_uri = 'https://test.firebaseio.com'
      firebase_instance = Firebase.new

      Firebase::Request.should_receive(:build_url).with('users/eugene', 'https://test.firebaseio.com/', nil)
      firebase_instance.set('users/eugene', 'hello')
    end
  end
  
  describe "auth for FirebaseInstance" do
    it "should use the auth passed from the instance" do
      Firebase.base_uri = 'https://test.firebaseio.com'
      firebase_instance = Firebase.new(nil, 'secretkey')
      
      Firebase::Request.should_receive(:build_url).with('users/eugene', 'https://test.firebaseio.com/', 'secretkey')
      firebase_instance.set('users/eugene', 'hello')
    end
  end 

  describe "url_builder" do
    it "should include a auth in the query string, if configured" do
      Firebase.base_uri = 'https://test.firebaseio.com'
      Firebase.auth = 'secretkey'

      Firebase::Request.build_url('users/eugene').should == 'https://test.firebaseio.com/users/eugene.json?auth=secretkey'
    end
  end
end
