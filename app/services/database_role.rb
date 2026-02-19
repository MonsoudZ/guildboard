class DatabaseRole
  class << self
    def read(&block)
      with_role(:reading, prevent_writes: true, &block)
    end

    def write(&block)
      with_role(:writing, prevent_writes: false, &block)
    end

    private

    def with_role(role, prevent_writes:, &block)
      ApplicationRecord.connected_to(role:, prevent_writes:, &block)
    rescue ActiveRecord::ConnectionNotDefined, ActiveRecord::ConnectionNotEstablished
      block.call
    end
  end
end
