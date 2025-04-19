if Rails.env.production? && ActiveRecord::Base.connection.adapter_name == 'SQLite'
  Rails.logger.info '[SQLite] Applying production PRAGMAs...'

  # Enable WAL mode for better concurrency
  ActiveRecord::Base.connection.execute('PRAGMA journal_mode = WAL;')

  # Enforce foreign key constraints
  ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = ON;')

  # Increase busy timeout to avoid "database is locked" errors
  ActiveRecord::Base.connection.execute('PRAGMA busy_timeout = 10000;')
end
