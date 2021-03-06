RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

end

  class RailsAdmin::Config::Fields::Types::Macaddr < RailsAdmin::Config::Fields::Base
    RailsAdmin::Config::Fields::Types::register(self)
  end

# from https://github.com/sferik/rails_admin/issues/1218
class RailsAdminPgArray < RailsAdmin::Config::Fields::Base
  register_instance_option :formatted_value do
    value.join(',')
  end
end

class RailsAdminPgStringArray < RailsAdminPgArray
  def parse_input(params)
    if params[name].is_a?(::String)
      params[name] = params[name].split(',')
    end
  end
end

class RailsAdminPgIntArray < RailsAdminPgArray
  def parse_input(params)
    if params[name].is_a?(::String)
      params[name] = params[name].split(',').collect{|x| x.to_i}
    end
  end
end

RailsAdmin::Config::Fields::Types::register(:pg_string_array, RailsAdminPgStringArray)
RailsAdmin::Config::Fields::Types::register(:pg_int_array, RailsAdminPgIntArray)
