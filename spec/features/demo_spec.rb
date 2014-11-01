require 'rails_helper'
require 'pry'

class Question
  attr_accessor :text
end

def question text
  q = Question.new
  q.text = text
  q
end

RSpec::Matchers.define :be_asked do 
  match do |question|
    page.has_css?( '.question-open h2', :text => question.text )
  end

  failure_message do |question|
    actual = page.all( '.question-open h2', ).last.text
    "Expected question to be asked: #{question.text}, but was asked #{actual}"
  end

end



feature "Self assessment questionaire" do
  scenario "ask a question", :js => true do
    visit '/'

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


def change_question q_title, &block
  begin
    @q_title = q_title
    page.find( '.question-closed div.title', :text => q_title ).find(:xpath, "..").find( 'div.answer a' ).click
    expect( question q_title ).to be_asked
    yield block
  rescue Exception
    page.save_screenshot( 'tmp/screenshot.png')
    raise
  end
end

def answer_question q_title, &block
  begin
    @q_title = q_title
    expect( question q_title ).to be_asked
    yield block
  rescue Exception
    save_page Rails.root.join( 'public', 'capybara.html' )
    page.save_screenshot( 'tmp/screenshot.png')
    raise
  end
end

def rollup_text
  page.find( '.question-closed div.title', :text => @q_title ).find(:xpath, '..').find( 'div.answer').text
end

def tooltip_text
  page.find( '.tooltip' ).text
end

def change_answer_tooltip_text
  page.find( '.change_answer_tooltip' ).text
end
