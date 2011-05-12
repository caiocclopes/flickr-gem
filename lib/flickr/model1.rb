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
      field :priority, type: Integer
      field :area_id, type: Integer
      field :per_page, type: Integer
      validates_presence_of :area_id, :message => "nao pode ser nulo"
      validates_uniqueness_of :area_id, :message => "ja existente"
      if !:people.eql?("-")   and (:photos.eql?("flickr.photos.getPhotos") or :photos.eql?("flickr.photos.getPhotosOf") or :photos.eql?("flickr.photos.getPublicPhotos") )
        validates_presence_of :email_or_username, :message => "nao pode ser nulo"
      end
      if :photos.eql?("search")
      validates_presence_of :content, :message => "nao pode ser nulo"
      end
  end
  
  end
end