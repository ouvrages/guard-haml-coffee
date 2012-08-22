# -*- encoding: utf-8 -*-
require 'guard'
require 'guard/guard'
require 'guard/watcher'
require 'haml_coffee_assets'

module Guard
  class HamlCoffee < Guard
    
    def initialize(watchers=[], options={})
      super
    end

    def start
      ::Guard::UI.info("Guard::HamlCoffee has started watching your files",{})
    end

    def run_all
      run_on_changes(Watcher.match_files(self, Dir.glob(File.join('**', '*.*'))))
    end

    def run_on_changes(paths)
      paths.each do |path|
        basename = File.basename(path, '.js.hamlc')
        output_file = File.join(File.dirname(path), basename + ".js")
        output = HamlCoffeeAssets::Compiler.compile(basename, File.read(path))
        File.open(output_file, "w") { |f| f.write output }
        ::Guard::UI.info "# compiled haml coffee in '#{path}' to js in '#{output_file}'"
      end
    rescue StandardError => error
      ::Guard::UI.error "Guard Haml Coffee Error: " + error.message
      throw :task_has_failed
    end
  end
end
