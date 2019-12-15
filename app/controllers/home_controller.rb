class HomeController < ApplicationController
  skip_verify_authorized only: :index
  
  def index
  end
end
