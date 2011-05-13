require "flickraw"

class Url     #classe com os campos necessários para se formar uma url no cliente
  include Mongoid::Document
  field :NSID
  field :text
  field :min_date
  field :api_method
  field :extras, type: Array
end


class FlickrController < ApplicationController
  def getFlickr
        # retorna as configurações padrão
    if(params[:area_id] == nil)
     flickr = Flickr.getAll
    else
     flickr = Flickr.getFlickr(params[:area_id].to_i)
    end
    
    if(flickr != nil)
      if(flickr.entries.count == 1)
        render :text => flickr.entries.first.to_json
      else
        render :text => flickr.entries.to_json
      end
    else
      render :text => {:success => false}.to_json
    end
  end
    
    def setPriority

        # define as prioridades para cada conjunto de métodos
       posicao = 0 
       cursor = Flickr.getAll[posicao]

        while cursor != nil # enquanto houver registros

          if !cursor.people.eql?("-")  # se foi colocado email or username, serão validados metodos cujo NSID é pedido
            cursor.priority = 1
            cursor.save
          elsif cursor.photos.eql?("flickr.photos.search") #metodo de busca generica, prioridade 3
            cursor.priority = 3
            cursor.save
          else 
            cursor.priority = 2   #metodos em que nao são necessários outros parametros obrigatórios
            cursor.save
          end

          posicao += 1 # posicao++
          cursor = Flickr.getAll[posicao]
    end
  end
  
  def setNSID
                 # procura em todos os registros se há a necessidade de se obter um NSID, atraves da gem flickraw
                 # em caso de usuario invalido retorna uma exception que é resgatada e implica a um NSID invalido
    posicao = 0 
    cursor = Flickr.getAll[posicao]
     while cursor != nil # enquanto houver registros
       FlickRaw.api_key = cursor.API_key
       FlickRaw.shared_secret = cursor.shared_secret
       if cursor.priority == 1
          if cursor.people.eql?("email")
              begin
              cursor.NSID = flickr.people.findByEmail(:find_email => cursor.email_or_username).nsid    #metodo flickraw
            rescue 
              cursor.NSID = "erro"
            end
              cursor.save
          else 
            begin
              cursor.NSID = flickr.people.findByUsername(:username => cursor.email_or_username).nsid
            rescue
               cursor.NSID = "erro"
              end
            cursor.save
          end
      else 
        cursor.NSID = "-"
        cursor.save
      end
        posicao += 1 # posicao++
        cursor = Flickr.getAll[posicao]
      end
  end
                
  def getPhotos
    
    setPriority()
    setNSID()
    
    if(params[:area_id] == nil)
     render :text => "Precisa ser passada uma area!"
     return
    else
       posicao = 0 
       cursor = Flickr.getAll[posicao]
     end
     url = Url.new
                         #varre os registros e encontra a posicáo correta para definir uma colletion Url
   while cursor != nil
    
   if cursor.area_id == params[:area_id].to_i

   case cursor.priority    # a url é definida a partir da prioridade e do método selecionado
     
     when 1
           
         if cursor.photos.eql?("flickr.photos.getPhotos")
          
           url.api_method = cursor.photos
           url.NSID = cursor.NSID
           url.extras = [["min_upload_date",(cursor.minimum_date).to_time.to_i],["max_upload_date",(cursor.maximum_date).to_time.to_i],["per_page",cursor.per_page]]
           url.save
         else 
           url.api_method = cursor.photos
           url.NSID = cursor.NSID 
           url.extras = [["per_page",cursor.per_page]]
           url.save
         end
       
      when 2
        
        if cursor.photos.eql?("flickr.photos.getRecent")
          url.api_method = cursor.photos
          url.extras = [["per_page",cursor.per_page]]
          url.save
          
        elsif cursor.photos.eql?("flickr.photos.recentlyUpdated")
             url.api_method = cursor.photos
             url.extras = [["per_page",cursor.per_page]]
             url.min_date = (cursor.minimun_date).to_time.to_i
             url.save
             
        elsif   cursor.photos.eql?("contactsPublicPhotos")
           url.api_method = cursor.photos
           url.NSID = cursor.NSID
           url.save
        
        else
            cursor.photos.eql?("getUntagged")
            url.api_method = cursor.photos
             url.extras = [["min_upload_date",(cursor.minimum_date).to_time.to_i],["max_upload_date",(cursor.maximum_date).to_time.to_i],["per_page",cursor.per_page]]
             url.save
              
        end
        
      when 3
          url.api_method = cursor.photos
          url.text = cursor.content.gsub('+',"%2B").gsub(/ /,"+") #remove espaços em branco e caractere '+'
          url.extras = [["min_upload_date",(cursor.minimum_date).to_time.to_i],["max_upload_date",(cursor.maximum_date).to_time.to_i],["per_page",cursor.per_page]]
          url.save
    end
  end
  posicao += 1 # posicao++
  cursor = Flickr.getAll[posicao]
end
      render :text => url.to_json
  end

  
  def create
    flickr_config = FlickrModel.new
    flickr_config.content = params[:content]
    flickr_config.people = params[:people]
    flickr_config.photos = params[:photos]
    flickr_config.per_page = params[:per_page]
    flickr_config.maximum_date = params[:maximum_date]
    flickr_config.minimum_date = params[:minimum_date]
    flickr_config.email_or_username = params[:email_or_username]
    flickr_config.area_id = params[:area_id].to_i
    if flickr_config.save

      render :text => {:success => true}.to_json
    else
      render :text => {:success => false}.to_json
    end
  end
end
