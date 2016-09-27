namespace :links do
  desc 'Delete old links'
  task delete_old: :environment do
    Link.where('created_at < ?', 7.days.ago)
        .where(impressions_count: 0)
        .where(clicks_count:      0)
        .where(shares_count:      0)
        .destroy_all
  end
end
