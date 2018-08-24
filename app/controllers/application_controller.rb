class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    if can? :read, exception.subject
      redirect_to exception.subject, :alert => exception.message
    else
      redirect_to root_url, :alert => exception.message
    end
  end
end
