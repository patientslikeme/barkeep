require 'json'
require 'git_wrapper'

module Barkeep

  def barkeep
    @@barkeep ||= Barkeeper.new
    @@barkeep.dup.tap { |barkeep| barkeep.renderer = self }
  end

end

class Barkeeper

  attr_accessor :renderer

  def config
    @config ||= JSON.parse(File.read("config/barkeep.json"))
  end

  def load?
    if defined?(Rails)
      this_env = Rails.env
    elsif defined?(Sinatra)
      this_env = Sinatra::Application.settings.environment
    end
    config['environments'].include?(this_env.to_s)
  end

  def styles
    return unless load?
    %(<style>#{File.read(File.expand_path(File.dirname(__FILE__) + "/default.css"))}</style>).html_safe
  end

  def render_toolbar
    return unless load?

    %(
      <dl id="barkeep">
      #{
        config['panes'].map do |name|
          if name =~ /^(p|partial) (.*)/
            if renderer.respond_to?(:render_to_string)
              renderer.send(:render_to_string, {:partial => $2})
            else
              renderer.send(:render, {:partial => $2})
            end
          else
            send(name)
          end
        end.join('')
      }
      <dd class="close">
        <a href="#" onclick="c = document.getElementById('barkeep'); c.parentNode.removeChild(c); return false" title="Close me!">&times;</a>
      </dd>
      </dl>
    ).html_safe
  end

  def renderer
    if !@renderer || @renderer.is_a?(Barkeep.class)
      @renderer = ApplicationController.new
    end
    @renderer
  end

  def branch_info
    return unless grit_info.repository?
    %(<dt>Branch:</dt><dd>#{branch_link}</dd>)
  end

  def branch_link
    return unless grit_info.repository?
    %(<a href="#{branch_link_attributes[:href]}">#{grit_info[:branch]}</a>).html_safe
  end

  def commit_sha_info
    %(<dt>Commit:</dt><dd>#{commit_sha_link}</dd>)
  end

  def commit_sha_link
    if grit_info.repository?
      return compose_commit_sha_link(
        href: commit_link_attributes[:href],
        title: commit_link_attributes[:title],
        hash: grit_info[:commit])
    end
    commit = Rails.root.join('REVISION').read.strip
    compose_commit_sha_link(href: commit_link(commit), hash: commit).html_safe
  end

  def commit_author_info
    if grit_info.repository?
      %(<dt>Who:</dt><dd>#{grit_info[:last_author]}</dd>)
    end
  end

  def commit_date_info
    if grit_info.repository?
      short_date = (grit_info[:date].respond_to?(:strftime) ? grit_info[:date].strftime("%d %B, %H:%M") : short_date.to_s)
      %(<dt>When:</dt><dd title="#{grit_info[:date].to_s}">#{short_date}</dd>)
    end
  end

  def rpm_request_info
    if rpm_enabled?
      %(<dt><a href="/newrelic">RPM:</a></dt><dd><a href="#{rpm_url}">request</a></dd>)
    end
  end

  def github_url
    config['github_url']
  end

  def grit_info
    GitWrapper.instance
  end

  def branch_link_attributes
    {
      :href => "#{github_url}/tree/#{grit_info[:branch]}",
      :title => grit_info[:message]
    }
  end

  def commit_link(commit_hash)
    "#{github_url}/commit/#{commit_hash}"
  end

  def commit_link_attributes
    {
      :href => commit_link(grit_info[:commit]),
      :title => "committed #{grit_info[:date]} by #{grit_info[:last_author]}"
    }
  end

  def rpm_enabled?
    if defined?(NewRelic)
      if defined?(NewRelic::Control)
        !NewRelic::Control.instance['skip_developer_route']
      else
        !NewRelic::Config.instance['skip_developer_route']
      end
    end
  end

  def rpm_sample_id
    NewRelic::Agent.instance.transaction_sampler.current_sample_id
  end

  def rpm_url
    "/newrelic/show_sample_detail/#{rpm_sample_id}"
  end

  private

  def compose_commit_sha_link(href:, hash:, title:)
    %(<a href="#{href}" title="#{title || 'link to this commit'}">#{hash.slice(0, 8)}</a>)
  end
end
