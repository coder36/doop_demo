require 'rails_helper'
require 'pry'

feature "Doop questionnaire" do

  scenario "Quick run through", :js => true do
    visit '/'
    wait_for_page( "Apply Online" )
    answer_question( "Turn debug on") { click_button "Yes" }
    answer_question( "Have you enrolled for this service before")  { click_button "Yes" }
    answer_question( "What year did you last apply")  { select( '2012', :from => 'b_answer' ); click_button "Continue"  }
    answer_question( "Why are you applying")  { fill_in( 'b_answer', :with => "My circumstances have changed" ); click_button "Continue"}
    click_button "Continue and Save"

    wait_for_page( "Your Details" )
    answer_question( "What is your name") { b_fill_in( "firstname" => "Mark", "surname" => "Middleton" ); click_button "Continue" }
    address = { "address1" => "1 Runswick Avenue", "address2" => "Telford", "address3" => "Shropshire", "postcode" => "T56 HDJ" }
    answer_question( "Address 1") { b_fill_in( address); click_button "Continue" }
    click_button "Continue"
    click_button "Continue and Save"

    wait_for_page( "Summary" )
    answer_question( "Terms and conditions") { click_button "I have read" }

  end


  scenario "ask a question", :js => true do
    visit '/'
    wait_for_page( "Apply Online" )

    answer_question( "Turn debug on") do 
      click_button "Yes" 
      expect(rollup_text).to be == "Yes" 
    end

    expect(question "Have you enrolled for this service before").to be_asked

    change_question "Turn debug on" do
      click_button "No" 
      expect(rollup_text).to be == "No" 
      expect(tooltip_text).to match /Are you sure/
    end

    answer_question( "Have you enrolled for this service before") do 
      click_button "No" 
      expect(rollup_text).to be == "No" 
    end

    expect(question "Why are you applying").to be_asked

    change_question( "Have you enrolled for this service before") do 
      expect(change_answer_tooltip_text).to match /additional questions may be asked/
      click_button "Yes" 
      expect(rollup_text).to be == "Yes" 
    end

    expect(question "What year did you last apply").to be_asked

    answer_question( "What year did you last apply") do 
      select( '2012', :from => 'b_answer' )
      click_button "Continue" 
      expect(rollup_text).to be == "2012" 
    end

    answer_question( "Why are you applying") do 
      fill_in( 'b_answer', :with => "My circumstances have changed" )
      click_button "Continue" 
      expect(rollup_text).to be == "Provided" 
    end

    click_button "Continue and Save"
  end
end
