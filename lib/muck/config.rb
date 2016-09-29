require 'muck/error'
require 'muck/config_dsl/root_dsl'

module Muck
  class Config

    def initialize(directory)
      @directory = directory
      @defaults = {}
      @servers = []
      parse
    end

    attr_reader :defaults
    attr_reader :servers

    def run(options = {})
      servers.each do |server|
        server.databases.each do |database|
          if database.backup_now? || options[:force]
            database.backup
            database.archive_all
          end
        end
      end
    end

    private

    def parse
      unless File.directory?(@directory)
        raise Muck::Error, "#{@directory} is not a directory"
      end

      root_dsl = ConfigDSL::RootDSL.new(self)
      files = Dir[File.join(@directory, "**", "*.rb")]
      files.each do |file|
        root_dsl.instance_eval(File.read(file), file)
      end
    end

  end
end
