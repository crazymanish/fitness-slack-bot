##############################################################
########################### Greeting #########################
##############################################################
private_lane :get_random_greeting_message do
  messages = all_greeting_messages
  greeting_message = messages["prefix"].sample
  suffix = messages["suffix"].sample
  emoji_list = ["🤗", "😈", "😇", "😊", "😍", "🙂", "☺️", "😺", "😸", "😻", "🐱", "🙌🏻", "🤟🏻", "🦋", "🦄", "🍸", "🍹"]

  greeting_message.concat(" #{suffix}")
  greeting_message.concat(" #{emoji_list.sample}")
  greeting_message
end

private_lane :get_random_footer_message do
  messages = all_greeting_messages
  footer_message = messages["footer"].sample
  emoji_list = [":dinosaurs:", ":happy_yes:", ":fistbump:", ":dinosaurs:", ":happy_yes:", ":bi_pride:", ":aroace_pride:", ":dinosaurs:", ":happy_yes:", ":aromantic_pride:"]

  footer_message.concat(" #{emoji_list.sample}")
  footer_message
end

private_lane :all_greeting_messages do
  require 'yaml'

  file_name = "greeting-messages.yml"
  file_path = File.expand_path("#{file_name}", File.dirname(__FILE__))
  YAML.load_file(file_path)
end

##############################################################
########################### Exercise #########################
##############################################################
private_lane :get_exercise_list_message do |options|
  exercise_list = get_exercise_list(options)
  exercise_messages = []

  exercise_list.each do |exercise_info|
    UI.success(exercise_info)
    exercise_name = exercise_info["EXERCISE_NAME"]
    exercise_url = exercise_info["URL"]

    exercise_message = "• <#{exercise_url}|#{exercise_name}>"
    exercise_messages.append(exercise_message)
  end

  exercise_messages.join("\n")
end

private_lane :get_exercise_list do |options|
  require 'csv'

  random_words_count = options[:random_words_count].to_i
  csv_file_path = get_exercise_csv_file_path(options)
  CSV.foreach(csv_file_path, headers: true).map { |row| row.to_h }
end

private_lane :get_exercise_csv_file_path do |options|
  file_name = "#{options[:workout_file_name]}.csv"
  repo_path = sh("git rev-parse --show-toplevel").strip
  file_paths = Dir[File.expand_path(File.join(repo_path, "**/#{file_name}"))]
  file_paths.first
end

##############################################################
########################### Workout log ######################
##############################################################
private_lane :get_last_workout_thread do |options|
  result = get_unreleased_changelog(file_name: options[:workout_file_name])
  last_ts = result["Added"].first
  last_ts = last_ts.gsub('.', '')

  "#{ENV["SLACK_THREAD_URL"]}#{last_ts}"
end

private_lane :finish_next_workout_setup do |options|
  stamp_unreleased_changelog(
    file_name: options[:workout_file_name],
    tag: "workout-#{DateTime.now}")

  add_unreleased_changelog(
    file_name: options[:workout_file_name],
    entry: options[:thread_ts],
    type: "Added")
end
