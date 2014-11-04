
require 'doop'
require 'yaml'
require 'date'

class ChildbenController < ApplicationController

  delegate :index, :answer, to: :@doop_controller
  before_filter :setup_doop

  def setup_doop
    @doop_controller = Doop::DoopController.new self do |doop|

      load_yaml do
        data = params["doop_data"] 
        if data != nil
          if Rails.env.development? || Rails.env.test?
            next data
          else
            next ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base).decrypt_and_verify data if !Rails.env.development?
          end
        end

        <<-EOS
          page: {
            preamble: {
              _page: "preamble",
              _nav_name: "Before you begin",

              income_more_than_50000: {
                _question: "Does you or your partner have an individual income of more than 50,000 a year ?"
              },
              do_you_still_want_to_apply: {
                _question: "Do you still want to apply for child benefit?"
              }
            },
            about_you: {
              _page: "about_you",
              _nav_name: "About You",

              your_name: {
                _question: "What is your name?",
                _answer: {}
              },
              known_by_other_name: {
                _question: "Have you ever been known by another surname ?"
              },
              previous_name: {
                _question: "What name were you previously known by ?"
              },
              dob: {
                _question: "Your date of birth"
              },
              your_address: {
                _question: "Your address",
                _answer: {}
              },
              lived_at_address_for_more_than_12_months: {
                _question: "Have you lived at this address for more than 12 months ?"
              },
              last_address: {
                _question: "What was your last address ?",
                _answer: {}
              },
              your_phone_numbers: {
                _question: "What numbers can we contact you on ?",
                _answer: {}
              },
              have_nino: {
                _question: "Do you have a national insurance number ?"
              },
              nino: {
                _question: "Tell us your national insurance number"
              }

            }

          }
        EOS

      end

      save_yaml do |yaml|
        if Rails.env.development? || Rails.env.test?
          request["doop_data"] = yaml
        else
          crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
          data = crypt.encrypt_and_sign(yaml)
          request["doop_data"] = data
        end
      end

      # On answer call backs

      on_answer "/page/preamble/income_more_than_50000"  do |question,path, params, answer|
        answer_with( question, { "_summary" => answer } )
        enable( "/page/preamble/do_you_still_want_to_apply", answer == 'Yes' )
      end

      on_answer "/page/preamble/do_you_still_want_to_apply"  do |question,path, params, answer|
        answer_with( question, { "_summary" => "Yes" } )
      end

      on_answer "/page/about_you/your_name"  do |question,path, params, answer|
        name = "#{answer['title']} #{answer['firstname']} #{answer['middlenames']} #{answer['surname']}".squish
        answer_with( question, { "_summary" => name } )
      end

      on_answer "/page/about_you/known_by_other_name"  do |question,path, params, answer|
        answer_with( question, { "_summary" => answer } )
        enable( "/page/about_you/previous_name", answer == 'Yes' )
      end

      on_answer "/page/about_you/previous_name"  do |question,path, params, answer|
        answer_with( question, { "_summary" => answer } )
      end

      on_answer "/page/about_you/dob"  do |question,path, params, answer|
        d = format_date answer
        next { :dob_error => "Date of birth must be formated as DD/MM/YYYY" } if d.nil?
        answer_with( question, { "_summary" => d } )
      end

      on_answer "/page/about_you/your_address"  do |question,path, params, answer|
        a = "#{answer['address1']}, #{answer['postcode']}"
        answer_with( question, { "_summary" => a } )
      end

      on_answer "/page/about_you/lived_at_address_for_more_than_12_months" do |question, path, params, answer|
        answer_with( question, { "_summary" => answer } )
        enable( "/page/about_you/last_address", answer == 'No' )
      end

      on_answer "/page/about_you/last_address"  do |question,path, params, answer|
        a = "#{answer['address1']}, #{answer['postcode']}"
        answer_with( question, { "_summary" => a } )
      end

      on_answer "/page/about_you/your_phone_numbers"  do |question,path, params, answer|
        answer_with( question, { "_summary" => "Provided" } )
      end

      on_answer "/page/about_you/have_nino" do |question, path, params, answer|
        answer_with( question, { "_summary" => answer } )
        enable( "/page/about_you/nino", answer == 'Yes' )
      end

      on_answer "/page/about_you/nino" do |question, path, params, answer|
        answer_with( question, { "_summary" => answer } )
      end

    end
  end

end


def format_date d
  begin
    return nil if d.length != 10
    Date.strptime( d, "%d/%m/%Y" ).strftime( "%-d %B %Y" )
  rescue
    nil
  end
end
