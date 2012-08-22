# -*- encoding: utf-8 -*-
require 'guard'
require 'guard/guard'
require 'guard/watcher'
require 'execjs'
require 'coffee-script'

module Guard
  class HamlCoffee < Guard
    
    def initialize(watchers=[], options={})
      super
    end

    def start
      ::Guard::UI.info("Guard::HamlCoffee has started watching your files",{})
      source = File.read(::CoffeeScript::Source.path) + ";"
      source += File.read(File.expand_path('../haml-coffee/hamlcoffee.js', __FILE__)) + ";"
      source += File.read(File.expand_path('../haml-coffee/hamlcoffee_compiler.js', __FILE__))
      @runtime = ExecJS.compile(source)
    end

    def run_all
      run_on_changes(Watcher.match_files(self, Dir.glob(File.join('**', '*.*'))))
    end

    def run_on_changes(paths)
      paths.each do |path|
        basename = File.basename(path, '.js.hamlc')
        output_file = File.join(File.dirname(path), basename + ".js")
        options = [
          basename,
          File.read(path),
          jst = true,
          namespace = nil,
          format = nil,
          uglify = false,
          basename,
          escapeHtml = nil,
          escapeAttributes = nil,
          cleanValue = nil,
          customHtmlEscape = nil,
          customCleanValue = nil,
          customPreserve = nil,
          customFindAndPreserve = nil,
          customSurround = nil,
          customSucceed = nil,
          customPrecede = nil,
          preserveTags = nil,
          selfCloseTags = nil,
          context = false,
          extendScope = nil,
        ]
        output = @runtime.call('HamlCoffeeCompiler.compile', *options)
        File.open(output_file, "w") { |f| f.write output }
        ::Guard::UI.info "# compiled haml coffee in '#{path}' to js in '#{output_file}'"
      end
    rescue StandardError => error
      ::Guard::UI.error "Guard Haml Coffee Error: " + error.message
      throw :task_has_failed
    end
  end
end
