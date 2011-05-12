# Use this generator like this:
# rails g flickr_config

class FlickrConfigGenerator < Rails::Generators::Base

  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), 'templates')
  end

  def generate_scaffold
    generate("scaffold", "flickr_config people:string email_or_username:string photos:string content:string area_id:integer minimum_date:date maximum_date:date per_page:integer ")
    remove_file "./app/models/flickr_config.rb"
    remove_file "./app/views/flickr_configs/_form.html.erb"
    template "flickr_config_model.rb", "./app/models/flickr_config.rb"
    template "flickr_config_iPhone.rb", "./app/controllers/flickr_controller.rb"
    copy_file "flickr_config_form.html.erb", "./app/views/flickr_configs/_form.html.erb"
  end

end