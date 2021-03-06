# Deoptimized version of homework task

require "json"
require "set"
require "pry"
require "date"
require "minitest/autorun"
# require 'ruby-progressbar'

DATA_FILE = "data128.txt"

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user.split(",")
  {
      "id" => fields[1],
      "first_name" => fields[2],
      "last_name" => fields[3],
      "age" => fields[4],
  }
end

def parse_session(session)
  fields = session.split(",")
  {
      "user_id" => fields[1],
      "session_id" => fields[2],
      "browser" => fields[3],
      "time" => fields[4],
      "date" => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes["first_name"]} #{user.attributes["last_name"]}"
    report["usersStats"][user_key] ||= {}
    report["usersStats"][user_key] = report["usersStats"][user_key].merge(block.call(user))
  end
end

# def parse_data_from_file(file_name = DATA_FILE)
#   users = []
#   sessions = []
#   users_session = {}
#   unique_browser = Set.new
#   file_lines = File.read(file_name).split("\n")
#   file_lines.each do |line|
#     cols = line.split(",")
#     users += [parse_user(line)] if cols[0] == "user"
#
#     if cols[0] == "session"
#       parsed_session = parse_session(line)
#       sessions.append parsed_session
#       if users_session[parsed_session["user_id"]].nil?
#         users_session[parsed_session["user_id"]] = [parsed_session]
#       else
#         users_session[parsed_session["user_id"]].append parsed_session
#       end
#       unique_browser.add parsed_session["browser"]
#     end
#   end
#   [users, sessions, users_session, unique_browser]
# end

def work(file_name = DATA_FILE)

  users = []
  sessions = []
  users_session = {}
  report = {}
  unique_browsers = SortedSet.new

  file_lines = File.read(file_name).split("\n")
  file_lines.each do |line|
    cols = line.split(",")
    if cols[0] == "user"
      users.append(parse_user(line))
    end

    if cols[0] == "session"
      parsed_session = parse_session(line)
      sessions.append parsed_session
      if users_session[parsed_session["user_id"]].nil?
        users_session[parsed_session["user_id"]] = [parsed_session]
      else
        users_session[parsed_session["user_id"]].append parsed_session
      end
      unique_browsers.add parsed_session["browser"].upcase
    end
  end

  # parts_of_work = 14 #number of hard code increments

  # progress_bar = ProgressBar.create(
  #     total: parts_of_work,
  #     format: '%a, %J, %E, %B' #elapsed time, percent complete, est time, bar
  # )

  # users, sessions, users_session, unique_browsers = parse_data_from_file file_name


  # progress_bar.increment

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +

  report[:totalUsers] = users.count

  report["uniqueBrowsersCount"] = unique_browsers.count

  # progress_bar.increment

  report["totalSessions"] = sessions.count

  # progress_bar.increment

  report["allBrowsers"] = unique_browsers.to_a.join(",")

  # progress_bar.increment

  # Статистика по пользователям
  users_objects = []

  users.each do |user|
    attributes = user
    user_sessions = users_session[user["id"]]
    # binding.pry
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects.append(user_object)
  end

  # progress_bar.increment

  report["usersStats"] = {}

  collect_stats_from_users(report, users_objects) do |user|
    if user.sessions.nil?
      return {"sessionsCount" => 0,
              "totalTime" => 0,
              "longestSession" => 0,
              "browsers" => "",
              "usedIE" => false,
              "alwaysUsedChrome" => false,
              "dates" => []}
    end
    sessions_times = user.sessions.map { |s| s["time"].to_i }
    user_browsers_upcased = user.sessions.map { |s| s["browser"].upcase }
    {"sessionsCount" => user.sessions.count, # Собираем количество сессий по пользователям
     # Собираем количество времени по пользователям
     "totalTime" => sessions_times.sum.to_s + " min.",
     # Выбираем самую длинную сессию пользователя
     "longestSession" => sessions_times.max.to_s + " min.",
     # Браузеры пользователя через запятую
     "browsers" => user_browsers_upcased.sort.join(", "),
     # Хоть раз использовал IE?
     "usedIE" => user_browsers_upcased.any? { |b| b.start_with? "INTERNET EXPLORER" },
     # Всегда использовал только Chrome?
     "alwaysUsedChrome" => user_browsers_upcased.all? { |b| b.start_with? "CHROME" },
     # Даты сессий через запятую в обратном порядке в формате iso8601
     "dates" => user.sessions.map { |s| s["date"] }.sort.reverse}
  end

  File.write("result.json", "#{report.to_json}\n")

  # progress_bar.increment
end

class TestMe < Minitest::Test
  def setup
    File.write("result.json", "")
    File.write("data.txt",
               'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
  end

  def test_result
    # prevent from error test
    correctness_test

    start_time = Time.now
    work
    end_time = Time.now

    # current results on short presets
    execution_not_regressed start_time, end_time
  end

  def correctness_test
    work "data.txt"
    expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read("result.json")
  end

  def execution_not_regressed(start_time, end_time, file_name = DATA_FILE)
    case file_name
    when "data.txt"
      current_test_results = 1
    when "data1.txt"
      current_test_results = 1
    when "data2.txt"
      current_test_results = 1
    when "data4.txt"
      current_test_results = 1
    when "data8.txt"
      current_test_results = 2
    when "data16.txt"
      current_test_results = 2
    when "data32.txt"
      current_test_results = 6
    when "data64.txt"
      current_test_results = 11
    when "data128.txt"
      current_test_results = 25
    when "data_large.txt"
      current_test_results = 30
    end

    metric_exec_time = end_time - start_time
    metric_exec_result = metric_exec_time < current_test_results
    assert_equal metric_exec_result, true
  end
end
# work