include Chef::Mixin::PowershellOut

module Tools
  require 'net/smtp'
  require 'json'
  require 'net/http'
  require 'mechanize'

  # Method to make web scraping and return body content
  def self.web_scraping(url, username, password)
    require 'mechanize'

    agent = Mechanize.new
    agent.user_agent_alias = 'Windows Chrome'

    unless username.nil?
      agent.add_auth(url, username, password)
    end

    res = agent.get(url)
    return (res.body).to_s
  end

  # Method to fetch data in JSON format from an URL
  def self.fetch(url)
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body
    return JSON.parse(data)
  end

  # Function to know if one url is reachable
  def self.is_reachable?(url)
    require 'mechanize'

    sw = true
    agent = Mechanize.new
    agent.user_agent_alias = 'Windows Chrome'
    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    tries = 3
    cont = 0

    begin
    	agent.read_timeout = 5 #set the agent time out
    	page = agent.get(url)
  	rescue
      cont += 1
      unless (tries -= 1).zero?
        Chef::Log.warn("Verifying if url #{url} is reachable (#{cont}/3) failed, try again in 2 minutes...")
        agent.shutdown
        agent = Mechanize.new { |agent| agent.user_agent_alias = 'Windows Chrome'}
        agent.request_headers
        sleep(60)
        retry
      else
        Chef::Log.error("The url #{url} isn't available.")
        Chef::Log.fatal('There is a problem with the request.')
        sw = false
      end
    else
      sw = true
    ensure
      agent.history.pop()   #delete this request in the history
    end

    return sw
  end

  # Method to unindent multiline strings
  def self.unindent string
    first = string[/\A\s*/]
    string.gsub /^#{first}/, ''
  end

  # Method to send emails via smtp
  def self.send_email(to, filename, opts={})
    opts[:server]      ||= 'smtp.office365.com'
    opts[:port]        ||= 587
    opts[:from]        ||= 'barcoder@redsis.com'
    opts[:password]    ||= 'Orion2015'
    opts[:from_alias]  ||= 'Chef Reporter'
    opts[:subject]     ||= "Chef Download on Node #{Chef.run_context.node.name}"
    opts[:message]     ||= '...'

    # Read a file and encode it into base64 format
    encodedcontent = [File.read(filename)].pack("m")   # base64

    marker = "AUNIQUEMARKER"

    # Define the main headers.
    header = <<-HEADER
      From: #{opts[:from_alias]} <#{opts[:from]}>
      To: <#{to}>
      Subject: #{opts[:subject]}
      MIME-Version: 1.0
      Content-Type: multipart/mixed; boundary=#{marker}
      --#{marker}
    HEADER

    # Define the message action
    body = <<-BODY
      Content-Type: text/plain
      Content-Transfer-Encoding:8bit

      #{opts[:message]}
      --#{marker}
    BODY

    # Define the attachment section
    attached = <<-ATTACHED
      Content-Type: multipart/mixed; name=\"#{filename}\"
      Content-Transfer-Encoding:base64
      Content-Disposition: attachment; filename="#{filename}"

      #{encodedcontent}
      --#{marker}--
    ATTACHED

    mailtext = unindent header + body + attached

    smtp = Net::SMTP.new(opts[:server], opts[:port])
    smtp.enable_starttls_auto
    smtp.start(opts[:server], opts[:from], opts[:password], :login)
    smtp.send_message(mailtext, opts[:from], to)
    smtp.finish
  end

  def self.simple_email(to, opts={})
    opts[:server]      ||= 'smtp.office365.com'
    opts[:port]        ||= 587
    opts[:from]        ||= 'barcoder@redsis.com'
    opts[:password]    ||= 'Orion2015'
    opts[:from_alias]  ||= 'Chef Reporter'
    opts[:subject]     ||= "Chef Start on Node #{Chef.run_context.node.name}"
    opts[:message]     ||= '...'

    message = <<-MESSAGE
      From: #{opts[:from_alias]} <#{opts[:from]}>
      To: <#{to}>
      Subject: #{opts[:subject]}

      #{opts[:message]}
    MESSAGE

    mailtext = unindent message

    smtp = Net::SMTP.new(opts[:server], opts[:port])
    smtp.enable_starttls_auto
    smtp.start(opts[:server], opts[:from], opts[:password], :login)
    smtp.send_message(mailtext, opts[:from], to)
    smtp.finish
  end

end

module Tomcat
  require 'mechanize'

  # Function to get the war folder
  def self.getWarFolder
    if File.directory?("C:\\Program Files (x86)\\Apache Software Foundation\\Tomcat 7.0\\webapps")
      return "C:\\Program Files (x86)\\Apache Software Foundation\\Tomcat 7.0\\webapps"
    else
      return "C:\\Program Files\\Apache Software Foundation\\Tomcat 7.0\\webapps"
    end
  end

  # Function to know if tomcat is Running
  def self.isRunning?
    tomcat = powershell_out!("(Get-Service Tomcat7).Status -eq \'Running\'")

    if tomcat.stdout[/True/]
      return true
    else
      return false
    end
  end

  # Function to know if tomcat is Stop
  def self.isStop?
    tomcat = powershell_out!("(Get-Service Tomcat7).Status -eq \'Stopped\'")

    if tomcat.stdout[/True/]
      return true
    else
      return false
    end
  end

  # Method to pause execution while tomcat start
  def self.waitStart
    if isRunning?
      agent = Mechanize.new
      agent.user_agent_alias = 'Windows Chrome'

    	begin
      	agent.read_timeout = 5 #set the agent time out
      	page = agent.get('http://localhost:8080')
      	agent.history.pop()   #delete this request in the history
        Chef::Log.info("Tomcat7 Started")
    	rescue
    		Chef::Log.info("Waiting 2.5 minutes for Tomcat7 to continue...")
    		agent.shutdown
    		agent = Mechanize.new { |agent| agent.user_agent_alias = 'Windows Chrome'}
    		agent.request_headers
    		sleep(150)
    		retry
    	end
    end
  end

  # Method to pause execution while tomcat stop
  def self.waitStop
    while !isStop? do
      Chef::Log.info("Waiting 2 minutes for Tomcat7 to continue...")
      sleep(120)
    end
    Chef::Log.info("Tomcat7 stopped !")
  end

  # Method to get the list of applications deployed and its number of sessions
  def self.sessionList(username, password)
    session_mesage = Tools.webScraping('http://localhost:8080/manager/text/list', username, password)
    sessions = Array.new

    session_mesage.each_line do |line|
      session = line.split(':')
      sessions.push(session)
    end
    return sessions
  end

  # Function to validate if there are active sessions in tomcat manager
  def self.activeSessions?(username, password)
    if isRunning?
      sessions = sessionList(username, password)
      i = 0
      sw = false
      while (i < sessions.length && !sw)
        session = sessions[i]
        if (session[0].start_with?("/") && !session[0].eql?("/manager") && session[2].to_i > 0)
          sw = true
        end
        i += 1
      end
      return sw
    else
      return false
    end
  end
end

# Define functions, methods, tools and utilities to work with Eva
module Eva
  # Function to validate if the version of new war is the same than the current
  def self.is_current_version?(war_url)
    sw = false

    if Tools.is_reachable?('http://localhost:8080/Eva/apilocalidad/version')
      version = Tools.web_scraping('http://localhost:8080/Eva/apilocalidad/version', nil, nil)
      unless version[/\d+(.)\d+(.)\d+/].nil?
        current_version = version[/\d+(.)\d+(.)\d+/]
        new_version = war_url[/\d+(.)\d+(.)\d+/]
        sw = current_version.eql?(new_version)
        Chef::Log.info("The current version is #{current_version}.")
      end
    else
      Chef::Log.warn('Could not determine the version of Eva.')
    end

    return sw
  end

  # Function to determine if node needs to add mercadoni key
  def self.update_keyboard?(file, delimiter, node_name)
  	array = []
  	File.open(file, "r") do |f|
  	  f.each_line do |line|
    		values = line.split(delimiter)
    		values.last = values.last.delete("\n")
    		array.push(values)
  	  end
  	end

  	sw = [false, false]
  	array.each do |node|
  		if node.first.eql? node_name
        sw.first = true
  			sw.last = true if node.last.eql? "1"
  			break
  		end
  	end

  	return sw
  end

end

Chef::Recipe.send(:include, Tools)
Chef::Recipe.send(:include, Eva)
