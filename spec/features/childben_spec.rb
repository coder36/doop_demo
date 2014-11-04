require 'rails_helper'
require 'pry'


feature "Child Benefit online form" do

  scenario "Quick run through", :js => true do
    load_completed_form
  end

  scenario "Changing an answer, causes change_answer_tool_tip_text to appear", :js => true do
    load_completed_form
    change_question( "Does you or your partner have an individual income" ) do
      expect(change_answer_tooltip_text).to match /If you change this answer, additional questions may be asked/
    end
#    change_question( "Have you ever been kown by another surname") do 
#      expect(change_answer_tooltip_text).to match /If you change your answer, additional questions may be asked/
#    end
  end

  scenario "Answering a question results in a tooltip appearing", :js => true, :broken => true do
  end

  scenario "Answering a question results in a new question being asked", :js => true do
    load_completed_form
    change_question( "Does you or your partner have an individual income") { click_button "Yes" }
    expect( question "Do you still want to apply for child benefit" ).to be_enabled
    change_question( "Does you or your partner have an individual income") { click_button "No" }
    expect( question "Do you still want to apply for child benefit" ).to be_disabled

#    change_question( "Have you ever been known by another surname")  { click_button "Yes" }
#    expect( question "What name were you previously known by" ).to be_enabled
#    change_question( "Have you ever been known by another surname")  { click_button "No" }
#    expect( question "What name were you previously known by" ).to be_disabled
  end





  def load_completed_form
    
    if $completed_form_yaml != nil
      visit '/childben/harness'
      fill_in( "doop_data", :with => $completed_form_yaml )
      click_button "Render"
      return
    end

    visit '/childben/index'
    wait_for_page( "Before you begin" )
    answer_question( "Does you or your partner have an individual income of more than")  { click_button "Yes" }
    answer_question( "Do you still want to apply for child benefit")  { click_button "Yes" }
    click_button "Continue" 

    wait_for_page( "About You" )
    answer_question( "What is your name") do
      b_fill_in( "title" => "Mr", "surname" => "Middleton", "firstname" => "Mark", "middlenames" => "Alan")
      click_button "Continue" 
      expect( rollup_text ).to eq( "Mr Mark Alan Middleton" )
    end
    answer_question( "Have you ever been known by another surname" ) { click_button "Yes" }
    answer_question( "What name were you previously known by" ) { b_fill_in( "answer" => "Bob Smith"); click_button "Continue" }

    answer_question( "Your date of birth" ) do
      b_fill_in( "answer" => "25/02/1977")
      click_button "Continue"
      expect( rollup_text ).to eq( "25 February 1977" )
    end


    $completed_form_yaml = page.find_by_id( "doop_data", :visible => false).value
  end
end
