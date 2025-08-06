class Manage::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :account_setup?
  layout 'manage'


  def index

  end

end
