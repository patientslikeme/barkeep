require 'helper'

class FakeModule
  include Barkeep
end

describe "Barkeep" do
  attr_accessor :output_buffer

  let(:barkeep) do
    FakeModule.new.barkeep.tap do |bk|
      bk.stubs({
        :config => {'github_url' => 'http://github.com/project_name', 'panes' => ['branch_info', 'commit_sha_info'], 'environments' => ['development']},
        :load? => true
      })
    end
  end

  it "renders a style tag filled with css" do
    css = File.read(File.expand_path(File.dirname(__FILE__) + "/../lib/default.css"))
    barkeep.styles.must_equal "<style>#{css}</style>"
  end

  it "renders the barkeep bar" do
    GitWrapper.instance.stubs(:repository? => true, :to_hash => {:branch => 'new_branch', :commit => 'abcdef', :last_author => 'Johnny', :date => '2/11/2012'})
    expected = %(
      <dl id="barkeep">
        <dt>Branch:</dt>
        <dd><a href="http://github.com/project_name/tree/new_branch">new_branch</a></dd>
        <dt>Commit:</dt>
        <dd><a href="http://github.com/project_name/commit/abcdef" title="committed 2/11/2012 by Johnny">abcdef</a></dd>
        <dd class="close"><a href="#" onclick="c = document.getElementById('barkeep'); c.parentNode.removeChild(c); return false" title="Close me!">&times;</a></dd>
      </dl>
    )
    expected.gsub(/\s+/, '').must_equal barkeep.render_toolbar.gsub(/\s+/, '')
  end
end

# Stub out html_safe, we don't need to test that here.
class String
  def html_safe
    self
  end
end
