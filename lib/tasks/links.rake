namespace :links do
  desc 'Delete old links'
  task delete_old: :environment do
    Link.where('created_at < ?', 7.days.ago)
        .order(created_at: :asc)
        .limit(100)
        .destroy_all
  end
end
