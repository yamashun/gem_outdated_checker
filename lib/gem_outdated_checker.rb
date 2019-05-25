require "gem_outdated_checker/version"
require "gem_outdated_checker/config"
require "open3"

module GemOutdatedChecker
  class Error < StandardError; end

  class GemList
    extend Config

    def initialize
      @update_exclude_gems = configs[:update_exclude_gems] || []
      @bundle_path = configs[:bundle_path] || 'bundle'.freeze
    end

    def outdated_gems
      bundle_outdated unless @execed
      @outdated_gems ||= @out.split("\n").grep(/\*/)
    end

    def update_required_gems
      return outdated_gems if @update_exclude_gems.empty?

      @update_required_gems ||= outdated_gems.reject do |gem_name|
        @update_exclude_gems.any?{ |pg| gem_name =~ /#{pg}/ }
      end
    end

    def update_pending_gems
      @update_pending_gems ||= outdated_gems - update_required_gems
    end

    private

    def configs
      @configs ||= self.class.configs
    end

    def bundle_outdated
      @out, @err, @status = Open3.capture3("#{@bundle_path} outdated")
      @execed = true
    end
  end
end
