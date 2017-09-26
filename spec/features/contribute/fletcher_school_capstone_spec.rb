require 'rails_helper'
require 'ffaker'
include Warden::Test::Helpers

RSpec.feature 'submit a Fletcher School Capstone Project contribution' do
  let(:user) { FactoryGirl.create(:user) }
  let(:csv_path) { Rails.root.join('config', 'deposit_type_seed.csv').to_s }
  let(:importer) { DepositTypeImporter.new(csv_path) }
  let(:pdf_path) { Rails.root.join('spec', 'fixtures', 'hello.pdf') }
  before do
    login_as user
    importer.import_from_csv
  end
  scenario do
    visit '/contribute'
    find('#deposit_type').find(:xpath, 'option[3]').select_option
    click_button 'Begin'
    attach_file('PDF to upload', pdf_path)
    fill_in 'Capstone Project Title', with: FFaker::Book.title
    fill_in 'Contributor', with: FFaker::Book.author
    select 'Master of Arts', from: 'Degree'
    fill_in 'Short Description', with: FFaker::Book.description
    click_button 'Agree & Deposit'
    expect(page).to have_content 'Your deposit has been submitted for approval.'
  end
end