class EnsureDeleteJob
  @queue = :default

  def self.perform(filename)
    FileUtils.rm([File.join('temp', filename)], force: true)
  end
end
