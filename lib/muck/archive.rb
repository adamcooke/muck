require 'muck/logging'
require 'muck/utils'
require 'fileutils'

module Muck
  class Archive

    include Muck::Logging
    include Muck::Utils

    MAPPING = {
      :hourly => 'YYYY-mm-dd-HH',
      :daily => "YYYY-mm-dd",
      :monthly => 'YYYY-mm',
      :yearly => 'YYYY'
    }

    def initialize(database, name, maximum)
      @database = database
      @name = name
      @maximum = maximum
    end

    def export_path
      File.join(@database.export_path, @name.to_s)
    end

    def run
      if last_backup = @database.manifest[:backups].last
        create_archive(last_backup)
        tidy
      else
        log.info "There is no backup to archive"
      end
    end

    def create_archive(backup)
      logger.info "Archiving #{blue @name} backup for #{blue @database.name} on #{blue @database.server.hostname}"
      logger.info "Using backup from #{blue backup[:path]}"
      filename = filename_for(backup[:path])
      archive_path = File.join(export_path, filename)
      FileUtils.mkdir_p(File.dirname(archive_path))
      if system("ln -f #{backup[:path]} #{archive_path}")
        logger.info "Successfully stored archive at #{green archive_path}"
      else
        logger.error red("Couldn't store archive at #{archive_path}")
      end
    end

    def tidy
      files = Dir[File.join(export_path, '*')].sort.reverse.drop(@maximum)
      files.each do |file|
        if system("rm #{file}")
          logger.info "Tidied #{green file}"
        else
          logger.error red("Couldn't remove un-retained file at #{file}")
        end
      end
    end

    private

    def filename_for(path)
      name, extensions = path.split('/').last.split('.', 2)
      size = MAPPING[@name.to_sym].size
      name[0,size] + ".#{extensions}"
    end

  end
end
