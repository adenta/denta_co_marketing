module SqliteUuidSupport
  module Type
    class Uuid < ActiveRecord::Type::String
      def type
        :uuid
      end
    end
  end

  module AdapterExtension
    def native_database_types
      super.merge(uuid: { name: "varchar", limit: 36 })
    end

    def valid_type?(type)
      type == :uuid || super
    end

    def initialize_type_map(map = type_map)
      super
      map.register_type(/uuid/i) { SqliteUuidSupport::Type::Uuid.new }
      map.register_type(/varchar\(36\)/i) { SqliteUuidSupport::Type::Uuid.new }
    end

    def type_to_dump(column)
      return [ :uuid, {} ] if column.type == :uuid

      super
    end
  end

  module UuidPrimaryKeyGeneration
    extend ActiveSupport::Concern

    included do
      before_create :assign_uuid_primary_key_if_needed
    end

    private

    def assign_uuid_primary_key_if_needed
      return unless id.blank?
      return unless self.class.primary_key == "id"

      id_column = self.class.columns_hash["id"]
      return unless id_column
      return unless uuid_column?(id_column)

      self.id = if SecureRandom.respond_to?(:uuid_v7)
                  SecureRandom.uuid_v7
      else
                  SecureRandom.uuid
      end
    end

    def uuid_column?(column)
      return true if column.type == :uuid

      sql_type = column.sql_type.to_s.downcase
      sql_type == "uuid" || sql_type == "varchar(36)"
    end
  end
end

ActiveSupport.on_load(:active_record_sqlite3adapter) do
  prepend SqliteUuidSupport::AdapterExtension
  ActiveRecord::Type.register(:uuid, SqliteUuidSupport::Type::Uuid, adapter: :sqlite)
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.include(SqliteUuidSupport::UuidPrimaryKeyGeneration)
end
