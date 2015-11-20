require 'barkeep/version_control_info/base'

class Barkeep::VersionControlInfo::Git < Barkeep::VersionControlInfo::Base
  def repository
    @repository ||= Dir.chdir(repository_dir) do
      (Dir.new('./.git') rescue :invalid)
    end
  end

  def commit
    return unless repository?

    @last_commit_hash ||= Dir.chdir(repository_dir) do
      `git rev-parse HEAD`.strip
    end
  end

  def author
    return unless repository?

    @author ||= Dir.chdir(repository_dir) do
      `git show -s --format='format:%an <%ae>'`.strip
    end
  end

  def message
    return unless repository?

    @message ||= Dir.chdir(repository_dir) do
      `git show -s --format='%s'`.strip
    end
  end

  def date
    return unless repository?

    @date ||= Dir.chdir(repository_dir) do
      Time.at(`git show -s --format='format:%at'`.to_i)
    end
  end

  def branch
    return unless repository?

    @branch ||= Dir.chdir(repository_dir) do
      `git rev-parse --abbrev-ref HEAD`.strip
    end
  end
end
