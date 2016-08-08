namespace :feeds do
  desc "This task fetches all feeds"
  task :fetch_all => :environment do
    Feed.fetch_all
  end
end
