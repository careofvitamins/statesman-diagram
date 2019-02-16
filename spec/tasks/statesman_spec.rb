require 'spec_helper'
require 'rake'

load 'tasks/statesman.rake'

task :environment do
  module Spaghetti
    class Machine
      include Statesman::Machine

      state :a
      state :b

      transition from: :a, to: :b
    end
  end
end

describe 'statesman:diagram' do
  before { Rake::Task['statesman:diagram'].reenable }

  it 'produces an svg image with a diagram of the given state machine class' do
    Rake::Task['statesman:diagram'].invoke('Spaghetti::Machine')
    expect(File.exists?('Spaghetti_Machine.svg')).to be true
    expect(File.size('Spaghetti_Machine.svg')).to be > 100
    FileUtils.rm('Spaghetti_Machine.svg')
  end

  it 'produces an svg image with the transferred name' do
    Rake::Task['statesman:diagram'].invoke('Spaghetti::Machine', './machine')
    expect(File.exists?('./machine.svg')).to be true
    expect(File.size('./machine.svg')).to be > 100
    FileUtils.rm('./machine.svg')
  end
end
