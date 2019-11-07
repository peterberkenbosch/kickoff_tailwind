require 'rails_helper'

RSpec.describe 'signup for a new account' do

  context 'happy path' do
    before do
      clear_emails
    end

    it "is successfully creating new accounts" do
      visit '/'
      click_link 'Sign Up'
    end
  end
end
