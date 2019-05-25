RSpec.describe GemOutdatedChecker do
  it "has a version number" do
    expect(GemOutdatedChecker::VERSION).not_to be nil
  end

  describe 'configure' do
    context 'set configure' do
      before :each do
        GemOutdatedChecker::GemList.configure do |config|
          config.update_exclude_gems = %w(aws-sdk)
          config.bundle_path = "./bin/bundle"
        end
      end
      after :each do
        GemOutdatedChecker::GemList.configure do |config|
          config.update_exclude_gems = nil
          config.bundle_path = nil
        end
      end

      it 'return setting values' do
        instance = GemOutdatedChecker::GemList.new
        expect(instance.instance_variable_get(:@update_exclude_gems)).to eq ["aws-sdk"]
        expect(instance.instance_variable_get(:@bundle_path)).to eq "./bin/bundle"
      end
    end

    context 'no configure' do
      it 'return default values' do
        instance = GemOutdatedChecker::GemList.new
        expect(instance.instance_variable_get(:@update_exclude_gems)).to eq []
        expect(instance.instance_variable_get(:@bundle_path)).to eq "bundle"
      end
    end
  end

  describe 'out dated gem list' do
    let(:outdated_result) {
<<-"EOS"
Fetching gem metadata from https://rubygems.org/.......
Fetching gem metadata from https://rubygems.org/.
Resolving dependencies......................................................................

Outdated gems included in the bundle:
  * actioncable (newest 5.2.3, installed 5.1.5)
  * actionmailer (newest 5.2.3, installed 5.1.5)
  * actionpack (newest 5.2.3, installed 5.1.5)
  * aws-sdk-acm (newest 1.22.0, installed 1.2.0)
  * aws-sdk-alexaforbusiness (newest 1.25.0, installed 1.1.0)
EOS
    }

    let(:capture3_result) {[
      outdated_result,
      '',
      '', # Actually, 'Process::Status' object return.
    ]}

    describe '#outdated_gems' do
      let(:instance){ GemOutdatedChecker::GemList.new }

      before(:each) { allow(instance).to receive(:exec_command).and_return(capture3_result) }

      it 'return outdated gem list' do
        expect(instance.outdated_gems.size).to be 5
      end

      context '@execed = true' do
        before :each do
          instance.instance_variable_set(:@execed, true)
          instance.instance_variable_set(:@out, outdated_result)
        end

        it 'skip exec bundle outdated if @execed' do
          expect(instance).not_to receive(:bundle_outdated)
          expect(instance.outdated_gems.size).to be 5
        end
      end
    end

    describe '#update_required_gems' do
      let(:instance){ GemOutdatedChecker::GemList.new }

      before :each do
        GemOutdatedChecker::GemList.configure do |config|
          config.update_exclude_gems = update_exclude_gems
        end

        allow(instance).to receive(:exec_command).and_return(capture3_result)
      end

      after :each do
        GemOutdatedChecker::GemList.configure do |config|
          config.update_exclude_gems = nil
        end
      end

      context 'update_exclude_gems exists' do
        let(:update_exclude_gems) { %w(aws-sdk actionpack) }

        it 'return outdated gem list excluding the gems set configure' do
          expect(instance.update_required_gems.size).to be 2
        end
      end

      context 'update_exclude_gems empty' do
        let(:update_exclude_gems) { nil }
        it 'return all outdated gem list' do
          expect(instance.update_required_gems.size).to be 5
        end
      end

      context 'update_exclude_gems exists but it is not on the oudated gem list' do
        let(:update_exclude_gems) { %w(not-extist) }
        it 'return all outdated gem list' do
          expect(instance.update_required_gems.size).to be 5
        end
      end
    end

    describe '#update_pending_gems' do
      let(:instance){ GemOutdatedChecker::GemList.new }

      before :each do
        GemOutdatedChecker::GemList.configure do |config|
          config.update_exclude_gems = update_exclude_gems
        end

        allow(instance).to receive(:exec_command).and_return(capture3_result)
      end

      after :each do
        GemOutdatedChecker::GemList.configure do |config|
          config.update_exclude_gems = nil
        end
      end

      context 'update_exclude_gems exists' do
        let(:update_exclude_gems) { %w(actioncable unknown-gem) }
        it 'return outdated gem list only the gems set configure' do
          expect(instance.update_pending_gems.size).to be 1
        end
      end

      context 'update_exclude_gems empty' do
        let(:update_exclude_gems) { nil }
        it 'return empty list' do
          expect(instance.update_pending_gems.size).to be 0
        end
      end
    end
  end
end
