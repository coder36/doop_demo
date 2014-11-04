require 'rails_helper'
require 'pry'


feature "Child Benefit online form" do

  scenario "Complete Child Benefit form", :js => true do
    before_you_begin
    about_you
  end

  def before_you_begin
    visit '/childben/index'
    wait_for_page( "preamble" )

    # check income_more_than_50000 alternate flows
    answer_question( "income_more_than_50000")  { click_button "No" }
    expect( question "do_you_still_want_to_apply" ).to be_disabled

    change_question( "income_more_than_50000") do
      expect( change_answer_tooltip ).to be_visible
      click_button "Yes" 
    end

    expect( question "do_you_still_want_to_apply" ).to be_enabled

    answer_question( "do_you_still_want_to_apply")  { click_button "Yes" }
    click_button "Continue" 
  end


  def about_you
    before_you_begin
    wait_for_page( "about_you" )
    answer_question( "your_name") do
      b_fill_in( "title" => "Mr", "surname" => "Middleton", "firstname" => "Mark", "middlenames" => "Alan")
      click_button "Continue" 
      expect( rollup_text ).to eq( "Mr Mark Alan Middleton" )
    end
    answer_question( "known_by_other_name" ) { click_button "No" }
    expect( question "previous_name" ).to be_disabled
    change_question( "known_by_other_name" ) { click_button "Yes" }
    expect( question "previous_name" ).to be_enabled

    answer_question( "previous_name" ) { b_fill_in( "answer" => "Bob Smith"); click_button "Continue" }

    answer_question( "dob" ) do
      b_fill_in( "answer" => "25/02/1977")
      click_button "Continue"
      expect( rollup_text ).to eq( "25 February 1977" )
    end
  end
end
