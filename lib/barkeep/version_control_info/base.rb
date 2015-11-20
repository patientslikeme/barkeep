class Barkeep::VersionControlInfo::Base
  attr_accessor :repository_dir

  def repository?
    :invalid
  end

  def repository?
    !repository.nil? && repository != :invalid
  end

  def repository_dir
    @repository_dir || Dir.getwd
  end

  def to_hash
    return {
      :branch => 'Not currently on a branch.',
      :commit => (File.read("REVISION").strip rescue nil)
    } unless repository?

    @hash ||= {
      :branch => branch,
      :commit => commit,
      :author => author,
      :message => message,
      :date => date
    }
  end

  def [](key)
    to_hash[key]
  end
end