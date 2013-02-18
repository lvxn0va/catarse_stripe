# application_helper.rb
module ApplicationHelper
  def connect_path(provider)
    "/auth/#{provider.to_s}"
  end
end