class ServiceResult
  attr_reader :record, :error

  def initialize(record:, error: nil)
    @record = record
    @error = error
  end

  def success?
    error.nil?
  end
end
