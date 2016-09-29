require 'muck/logging'
require 'muck/utils'
require 'fileutils'

module Muck
  class Backup

    include Muck::Logging
    include Muck::Utils

    def initialize(database)
      @database = database
      @time = Time.now
    end

    def export_path
      @export_path ||= File.join(@database.export_path, "master", @time.strftime("%Y-%m-%d-%H-%M-%S.sql"))
    end

    def run
      logger.info "Backing up #{blue @database.name} from #{blue @database.server.hostname}"
      take_backup
      compress
      store_in_manifest
      tidy_masters
    end

    def take_backup
      logger.info "Connecting to #{blue @database.server.ssh_username}@#{blue @database.server.hostname}:#{blue @database.server.ssh_port}"
      FileUtils.mkdir_p(File.dirname(self.export_path))
      file = File.open(export_path, 'w')
      ssh_session = @database.server.create_ssh_session
      channel = ssh_session.open_channel do |channel|
        logger.debug "Running: #{@database.dump_command}"
        channel.exec(@database.dump_command) do |channel, success|
          raise Error, "Could not execute dump command" unless success
          channel.on_data do |c, data|
            file.write(data)
          end

          channel.on_extended_data do |c, _, data|
            logger.debug red(data.gsub(/[\r\n]/, ''))
          end

          channel.on_request("exit-status") do |_, data|
            exit_code = data.read_long
            if exit_code != 0
              logger.debug "Exit status was #{exit_code}"
              raise Error, "mysqldump returned an error when executing."
            end
          end
        end
      end
      channel.wait
      ssh_session.close
      file.close
      logger.info "Successfully backed up to #{green export_path}"
    end

    def store_in_manifest
      if File.exist?(export_path)
        details = {:timestamp => @time.to_i, :path => export_path, :size => File.size(export_path)}
        @database.manifest[:backups] << details
        @database.save_manifest
      else
        raise Error, "Couldn't store backup in manifest because it doesn't exist at #{export_path}"
      end
    end

    def compress
      if File.exist?(export_path)
        if system("gzip #{export_path}")
          @export_path = @export_path + ".gz"
          logger.info "Compressed #{blue export_path} with gzip"
        else
          logger.warn "Couldn't compress #{export_path} with gzip"
        end
      else
        raise Error, "Couldn't compress backup because it doesn't exist at #{export_path}"
      end
    end

    def tidy_masters
      files = Dir[File.join(@database.export_path, 'master', '*')].sort.reverse.drop(@database.server.masters_to_keep)
      unless files.empty?
        logger.info "Tidying master backup files. Keeping #{@database.server.masters_to_keep} back."
        files.each do |file|
          if system("rm #{file}")
            @database.manifest[:backups].delete_if { |b| b[:path] == file }
            logger.info "-> Removed #{green file}"
          else
            logger.error red("-> Couldn't remove unwanted master file at #{file}")
          end
        end
      end
    ensure
      @database.save_manifest
    end

  end
end
