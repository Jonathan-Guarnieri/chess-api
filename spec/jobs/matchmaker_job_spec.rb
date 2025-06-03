require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe MatchmakerJob, type: :job do
  let(:service_instance) { instance_double(MatchmakerService) }

  before do
    Sidekiq::Testing.fake!
    MatchmakerJob.clear

    allow(MatchmakerService).to receive(:new).and_return(service_instance)
    allow(service_instance).to receive(:call)
  end

  context 'when try_again_later? returns false' do
    before do
      allow(service_instance).to receive(:try_again_later?).and_return(false)
    end

    it 'calls the service and does not enqueue again' do
      described_class.new.perform

      expect(service_instance).to have_received(:call)
      expect(service_instance).to have_received(:try_again_later?)
      expect(MatchmakerJob.jobs.size).to eq(0)
    end
  end

  context 'when try_again_later? returns true' do
    before do
      allow(service_instance).to receive(:try_again_later?).and_return(true)
      ENV['MATCHMAKER_RETRY_INTERVAL_MS'] = '1000'
    end

    after { ENV.delete('MATCHMAKER_RETRY_INTERVAL_MS') }

    it 'calls the service and enqueues itself to retry' do
      expect {
        described_class.new.perform
      }.to change { MatchmakerJob.jobs.size }.by(1)

      job = MatchmakerJob.jobs.last
      expect(job['class']).to eq('MatchmakerJob')
      expect(job['at']).to be_within(1).of((Time.now + 1).to_f)
    end
  end

  context 'when MATCHMAKER_RETRY_INTERVAL_MS is not set' do
    before do
      allow(service_instance).to receive(:try_again_later?).and_return(true)
      ENV.delete('MATCHMAKER_RETRY_INTERVAL_MS')
    end

    it 'raises an error' do
      expect {
        described_class.new.perform
      }.to raise_error('You need to set MATCHMAKER_RETRY_INTERVAL_MS env')
    end
  end
end