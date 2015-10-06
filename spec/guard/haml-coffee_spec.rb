require 'guard/compat/test/helper'
require 'guard/haml-coffee'

RSpec.describe Guard::HamlCoffee do
  subject { described_class.new(options) }

  let(:options) { {} }

  before do
    allow(Guard::Compat::UI).to receive(:info)
    allow(File).to receive(:expand_path) do |*args|
      msg = 'unstubbed call to File.expand_path(%s)'
      fail msg % args.map(&:inspect).join(',')
    end

    allow(IO).to receive(:read) do |*args|
      msg = 'unstubbed call to IO.read(%s)'
      fail msg % args.map(&:inspect).join(',')
    end
  end

  describe '#initialize' do
    context 'with an unknown option' do
      let(:options) { { foo: :bar } }
      it 'fails' do
        expect { subject }.to raise_error(ArgumentError, 'Unknown option: :foo')
      end
    end

    context 'with a Guard::Plugin watchers option' do
      let(:options) { { watchers: [] } }
      it 'fails' do
        expect { subject }.to_not raise_error
      end
    end

    context 'with a Guard::Plugin group option' do
      let(:options) { { group: [] } }
      it 'fails' do
        expect { subject }.to_not raise_error
      end
    end

    context 'with a Guard::Plugin callbacks option' do
      let(:options) { { callbacks: [] } }
      it 'fails' do
        expect { subject }.to_not raise_error
      end
    end
  end

  describe '#start' do
    context 'with valid config' do
      let(:source) { 'foo' }

      before do
        allow(File).to receive(:expand_path).with('../coffee-script.js', anything).and_return('foo.js')
        allow(IO).to receive(:read).with('foo.js').and_return('foo')

        allow(File).to receive(:expand_path).with('../haml-coffee/hamlcoffee.js', anything).and_return('bar.js')
        allow(IO).to receive(:read).with('bar.js').and_return('bar')

        allow(File).to receive(:expand_path).with('../haml-coffee/hamlcoffee_compiler.js', anything).and_return('baz.js')
        allow(IO).to receive(:read).with('baz.js').and_return('baz')
      end

      it 'compiles' do
        expect(ExecJS).to receive(:compile).with('foo;bar;baz')
        subject.start
      end
    end
  end

  describe '#run_all' do
    context 'with matching files' do
      let(:existing) { %w(foo bar baz) }
      let(:matching) { %w(foo bar) }

      before do
        allow(Dir).to receive(:glob).with(anything).and_return(existing)
        allow(Guard::Compat).to receive(:matching_files).with(subject, existing).and_return(matching)
      end

      it 'compiles' do
        expect(subject).to receive(:process).with(matching)
        subject.run_all
      end
    end
  end

  describe '#run_on_modifications' do
    context 'with modifications' do
      let(:files) { %w(foo bar) }
      it 'compiles' do
        expect(subject).to receive(:process).with(files)
        subject.run_on_modifications(files)
      end
    end
  end

  describe '#run_on_changes' do
    context 'with changes' do
      let(:files) { %w(foo bar) }
      it 'compiles' do
        expect(subject).to receive(:process).with(files)
        subject.run_on_changes(files)
      end
    end
  end
end
