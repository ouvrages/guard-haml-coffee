# -*- encoding: utf-8 -*-

require 'guard/compat/plugin'

require 'execjs'
require 'coffee-script'

module Guard
  class HamlCoffee < Plugin
    VALID_GUARD_OPTIONS = %i(watchers group callbacks)
    VALID_OPTIONS = %i(object)

    def initialize(options = {})
      valid_options = VALID_OPTIONS + VALID_GUARD_OPTIONS
      options.keys.each do |key|
        unless valid_options.include?(key)
          fail ArgumentError, "Unknown option: #{key.inspect}"
        end
      end

      @options = {
        notifications: true
      }.merge(options)
      super(@options)
    end

    def start
      Compat::UI.info('Guard::HamlCoffee has started watching your files', {})
      source = File.read(::CoffeeScript::Source.path) + ';'
      source += load_config('../haml-coffee/hamlcoffee.js') + ';'
      source += load_config('../haml-coffee/hamlcoffee_compiler.js')
      @runtime = ExecJS.compile(source)
    end

    # Get the file path to output the html based on the file being
    # built.  The output path is relative to where guard is being run.
    #
    # @param file [String] path to file being built
    # @return [String] path to file where output should be written
    #
    def get_output(file)
      file_dir = File.dirname(file)
      file_name = File.basename(file).split('.')[0..-2].join('.')

      file_name = "#{file_name}.js" if file_name.match("\.js").nil?

      file_dir = file_dir.gsub(Regexp.new("#{@options[:input]}(\/){0,1}"), '') if @options[:input]
      file_dir = File.join(@options[:output], file_dir) if @options[:output]

      if file_dir == ''
        file_name
      else
        File.join(file_dir, file_name)
      end
    end

    def run_all
      all_files = Dir.glob(File.join('**', '*.*'))
      process(Compat.matching_files(self, all_files))
    end

    def run_on_modifications(files)
      process(files)
    end

    def run_on_changes(files)
      process(files)
    end

    private

    def process(paths)
      paths.each do |path|
        basename = File.basename(path, '.js.hamlc')
        output_file = get_output(path)
        FileUtils.mkdir_p File.dirname(output_file)
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

    def load_config(file)
      File.read(File.expand_path(file, __FILE__))
    end
  end
end
