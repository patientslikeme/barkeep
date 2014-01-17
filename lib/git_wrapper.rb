# A singleton refreshes on every request in development but
# caches in environments where class caching is enabled.
require 'singleton'
require 'ostruct'

class GitWrapper
  include Singleton

  def repository
    @repository = (Dir.new('./.git') rescue :invalid)
  end

  def repository?
    !repository.nil? && repository != :invalid
  end

  def last_commit_hash
    @last_commit_hash ||= `git rev-parse HEAD`.strip
  end

  def last_commit
    @last_commit ||= begin
      if repository?
        OpenStruct.new(
          author: `git show -s --format='format:%an <%ae>'`.strip,
          message: `git show -s --format='%s'`.strip,
          authored_date: Time.at(`git show -s --format='format:%at'`.to_i)
        )
      else
        OpenStruct.new()
      end
    end
  end

  def to_hash
    return {
      :branch => 'Not currently on a branch.',
      :commit => (File.read("REVISION").strip rescue nil)
    } unless repository?
    
    @hash ||= {
      :branch => `git rev-parse --abbrev-ref HEAD`.strip,
      :commit => last_commit_hash,
      :last_author => last_commit.author,
      :message => last_commit.message,
      :date => last_commit.authored_date
    }
  end

  def [](key)
    to_hash[key]
  end
end
