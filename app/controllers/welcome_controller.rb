# -*- coding: utf-8 -*-
class WelcomeController < ApplicationController
  def index
  end

  def about
  end

  def failure
  end

  def create # temporary post method
    redirect_to root_path
  end

end
