# frozen_string_literal: true

##
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
if ENV['DEFAULT_USER_EMAIL'] && ENV['DEFAULT_USER_PASSWORD']
  u = User.find_or_create_by(email: ENV['DEFAULT_USER_EMAIL']) do |u|
    u.password = ENV['DEFAULT_USER_PASSWORD']
  end
end
