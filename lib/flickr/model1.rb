module Flickr
  module Model
    
    class FlickrModel
      include Mongoid::Document
      field :API_key, :default => "d23c1652652ddc79e37539b481f41415"
      field :shared_secret, :default => "30d085be1b0321e0"
      field :people
      field :email_or_username
      field :NSID
      field :photos
      field :content
      field :minimum_date, type: Date
      field :maximum_date, type: Date
      field :priority,  type: Integer
      field :area_id, type: Integer
      field :per_page, type: Integer, :default => 10
      validates_presence_of :area_id, :message => "nao pode ser nulo"
      validates_uniqueness_of :area_id, :message => "ja existente"
      validates_numericality_of :per_page, :greather_than => 0, :less_than => 51, :message => "must be between 1 and 50"
 
  end
  
  end
end