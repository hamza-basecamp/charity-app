# Load the Rails application.
require_relative "application"
require 'fileutils'


env_variables = File.join(Rails.root, 'config', 'env_var.rb')
load(env_variables) if File.exist?(env_variables)
# Initialize the Rails application.
Rails.application.initialize!
