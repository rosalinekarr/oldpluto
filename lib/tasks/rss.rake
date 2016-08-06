namespace :rss do
  desc "This task does nothing"
  task :fetch => :environment do
    Feed.find_each { |feed| feed.fetch }
  end
end
