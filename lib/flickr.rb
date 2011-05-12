require "rubygems"
require "flickr/model1"


module Flickr
  class << self
  

    def getFlickr (area)
      if(area.is_a? Numeric)
        return Flickr::Model::FlickrModel.where(area_id: area)
      else
        return nil
      end
    end
    

    def getAll
      return Flickr::Model::FlickrModel.all.entries
    end
    
  end
end
