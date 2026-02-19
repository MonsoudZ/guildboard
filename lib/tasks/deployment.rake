namespace :deployment do
  desc "Fail if there are pending or explicitly irreversible migrations"
  task migration_safety: :environment do
    pending = ActiveRecord::Base.connection_pool.migration_context.open.pending_migrations
    if pending.any?
      abort "Pending migrations: #{pending.map(&:name).join(', ')}"
    end

    irreversible = Dir.glob(Rails.root.join("db/migrate/*.rb")).select do |path|
      File.read(path).include?("ActiveRecord::IrreversibleMigration")
    end
    if irreversible.any?
      abort "Irreversible migrations detected: #{irreversible.map { |path| File.basename(path) }.join(', ')}"
    end

    puts "Migration safety checks passed"
  end
end
