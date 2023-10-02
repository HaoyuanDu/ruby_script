require 'json'
begin

  # Load data
  users = JSON.parse(File.read('users.json'))
  companies = JSON.parse(File.read('companies.json'))

  # Sort companies by ID and users by last name
  sorted_companies = companies.sort_by { |c| c['id'] }
  sorted_users = users.sort_by { |u| u['last_name'] }

  output_data = []

  sorted_companies.each do |company|
    company_total_top_up = 0
    emailed_users = []
    non_emailed_users = []

    sorted_users.each do |user|
      if user['company_id'] == company['id'] && user['active_status'] == true
        prev_tokens = user['tokens']
        user['tokens'] += company['top_up']
        company_total_top_up += company['top_up']

        user_data = [
        "     #{user['last_name']}, #{user['first_name']}, #{user['email']}",
          "       Previous Token Balance, #{prev_tokens}",
          "       New Token Balance #{user['tokens']}"
        ]

        # Determine email status
        if user['email_status'] && company['email_status']
          emailed_users << user_data
        else
          non_emailed_users << user_data
        end
      end
    end

    # Check if there are users associated with the company
    if emailed_users.any? || non_emailed_users.any?
    # Build output for this company
      output_data << "\n"
      output_data << "\tCompany Id: #{company['id']}"
      output_data << "\tCompany Name: #{company['name']}"
      output_data << "\tUsers Emailed:"
      emailed_users.each {|user_data| output_data.concat(user_data) }

      output_data << "\tUsers Not Emailed:"
      non_emailed_users.each { |user_data| output_data.concat(user_data) }
      
      output_data << "\tTotal amount of top ups for #{company['name']}: #{company_total_top_up}\n"
    end
  end
  # Print results to console for debugging purposes
  # output_data.each { |line| puts line }

  # Write the results to the output file
  File.open('output.txt', 'w') do |f|
    output_data.each { |line| f.puts(line) }
  end

  puts 'Completed. Please check output.txt for the results.'
  
  rescue Errno::ENOENT
    puts "Error: One of the JSON files doesn't exist."
  rescue JSON::ParserError
    puts "Error: Malformed JSON data."
  rescue Errno::EACCES
    puts "Error: Unable to write to output.txt. Check if you have write permissions."
  rescue => e
    puts "Error: #{e.message}"
end