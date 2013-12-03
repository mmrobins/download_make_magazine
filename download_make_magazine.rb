require 'capybara/poltergeist'

starting_issue = ENV["MAKE_STARTING_ISSUE"].to_i || 1
email = ENV["MAKE_EMAIL"]
raise "set MAKE_EMAIL env variable" unless email

module MakeMagazine
  DOMAIN = "www.make-digital.com"
  Capybara.run_server = false
  Capybara.app_host = "http://#{DOMAIN}"
  Capybara.current_driver = :poltergeist

  class API
    include Capybara::DSL

    def initialize(email)
      @email = email
      set_subscriber_cookie
    end

    def download_all_issues(starting_issue = 1)
      issue_no = starting_issue
      while(true) do
        download_issue("%02d" % issue_no)
        issue_no += 1
      end
    end

    def download_issue(issue_no)
      file_name = "Make Magazine Volume #{issue_no}.pdf"
      if File.exists?(file_name)
        puts "skipping #{file_name} it already exists"
        return
      end
      path = download_path(issue_no)
      Net::HTTP.start(DOMAIN) do |http|
        resp = http.get(path)
        open(file_name, "wb") do |file|
          file.write(resp.body)
        end
        puts "Saved Issue #{issue_no}"
      end
    end

    private

    def download_path(issue_no)
      visit("/make/vol#{issue_no}")
      find('#button_link_download').click
      find("#download_pdf").click
      download_popup = page.driver.window_handles.last
      page.within_window download_popup do
        return find_link('click here')[:href]
      end
    rescue Capybara::ElementNotFound
      puts "Could not download issue #{issue_no}, it probably hasn't been released yet"
      exit 0
    end

    def set_subscriber_cookie
      @subscriber_id ||= get_subscriber_id

      # need to visit a page before setting cookie else it just gets lost
      page.visit("/make/vol10")

      page.driver.set_cookie('subscriber_id', @subscriber_id)
    end

    # if the stupid form to post this would show up with poltergeist
    # I could just login with that, but it doesn't...
    # and I can't figure out how to get poltergeist to post
    def get_subscriber_id
      # not sure why you post to a specific vol (32 just picked randomly), but
      # you do, it sets cookies and redirects to the same volume
      uri = URI('http://www.make-digital.com/make/vol32') 
      res = res = Net::HTTP.post_form(uri, 'email' => @email) 
      res['Set-Cookie'] =~ /subscriber_id=([^\;\s]+)/
      $1
    end
  end
end

MakeMagazine::API.new(email).download_all_issues(starting_issue)
