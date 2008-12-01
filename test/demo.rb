require File.dirname(__FILE__) + '/test_helper'

require 'rubygems'
require 'actionpack'
require 'action_controller'
require 'action_controller/test_process'
require 'active_support'

# setup some fakes so the demo can run

class Article
  attr_reader :errors

  def initialize(attributes)
    @attributes = attributes
  end

  def save
    @errors = ['title', 'body'] - @attributes.keys
    @errors.empty?
  end
end

class User
  def initialize(admin = false)
    @admin = admin
  end

  def admin?
    @admin
  end
end

class ArticlesController < ActionController::Base
  attr_accessor :current_user
  before_filter :require_admin

  def create
    @article = Article.new params
    if @article.save
      redirect_to '/articles/1'
    else
      flash[:error] = "missing: #{@article.errors.join(', ')}"
      render :text => "can't fake a real template easily?"
    end
  end

  protected

    def require_admin
      redirect_to '/login' unless current_user && current_user.admin?
    end
end

ActionController::Routing.module_eval do
  set = ActionController::Routing::RouteSet.new
  set.draw {|map| map.articles 'articles', :controller => 'articles', :action => 'create'}
  remove_const :Routes
  const_set :Routes, set
end

# share some contexts and set up some macros

class ActionController::TestCase
  include With

  share :login_as_admin do
    before { @controller.current_user = User.new(true) }
  end

  share :valid_article_params do
    before { @params = valid_article_params }
  end

  share :invalid_article_params do
    before { @params = valid_article_params.except(:title) }
  end
  
  share :invalid_article_params do
    before { @params = valid_article_params.except(:body) }
  end

  def it_redirects_to(path)
    assert_redirected_to path
  end

  def it_assigns_flash(key, pattern)
    assert flash[:error] =~ pattern
  end

  def valid_article_params
    { :title => 'an article title', :body => 'an article body' }
  end
end

# TODO figure out how to reduce this
module With::Dsl
  def it_redirects_to(path)
    assertion { assert_redirected_to path }
  end
end

# and now the fun starts ...

class ArticlesControllerTest < ActionController::TestCase
  describe 'POST to :create' do
    action { post :create, @params }

    with :login_as_admin do
      it "succeeds", :with => :valid_article_params do
        it_redirects_to 'articles/1'
      end

      it "fails", :with => :invalid_article_params do
        it_assigns_flash :error, /missing: (body|title)/
      end
    end

    with :login_as_user, :no_login do
      it_redirects_to '/login'
    end
  end

  puts "tests defined: \n  " + instance_methods.grep(/^test_/).join(", \n  ")
end