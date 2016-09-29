require 'muck/archive'
require 'muck/backup'
require 'yaml'

module Muck
  class Database

    def initialize(server, properties)
      @server = server
      @properties = properties
    end

    def name
      @properties[:name]
    end

    def hostname
      @properties[:hostname]
    end

    def username
      @properties[:username]
    end

    def password
      @properties[:password]
    end

    def server
      @server
    end

    def export_path
      @export_path ||= server.export_path.gsub(':database', self.name)
    end

    def archive_all
      @server.retention.each do |name, maximum|
        Muck::Archive.new(self, name, maximum).run
      end
    end

    def backup
      Muck::Backup.new(self).run
    end

    def manifest_path
      File.join(export_path, 'manifest.yml')
    end

    def manifest
      @manifest ||= File.exist?(manifest_path) ? YAML.load_file(manifest_path) : {:backups => []}
    end

    def save_manifest
      File.open(manifest_path, 'w') { |f| f.write(manifest.to_yaml) }
    end

    def dump_command
      password_opt = password ? "-p#{password}" : ""
      "mysqldump --flush-logs -q --single-transaction -h #{hostname} -u #{username} #{password_opt} #{name}"
    end

    def last_backup_at
      if last_backup = manifest[:backups].last
        Time.at(last_backup[:timestamp])
      else
        nil
      end
    end

    def backup_now?
      last_backup_at.nil? || last_backup_at <= Time.now - (@server.frequency * 60)
    end

  end
end
