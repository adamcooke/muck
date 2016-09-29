require 'muck/database'
require 'net/ssh'

module Muck
  class Server

    DEFAULT_RENTENTION = {:hourly => 24, :daily => 7, :monthly => 12, :yearly => 8}
    DEFAULT_SSH_PROPERTIES = {:username => "root", :port => 22, :key => "/opt/muck/ssh-key"}
    DEFAULT_DATABASE_PROPERTIES = {:hostname => '127.0.0.1', :username => 'root', :name => 'example', :password => nil}

    def initialize(config, server_hash = {})
      @config = config
      @server_hash = server_hash
    end

    def hostname
      @server_hash[:hostname]
    end

    def frequency
      @server_hash[:frequency] || @config.defaults[:frequency] || 60
    end

    def export_path
      if path = (@server_hash.dig(:storage, :path) || @config.defaults.dig(:storage, :path))
        path.gsub(":hostname", self.hostname)
      else
        "/opt/muck/data/#{self.hostname}/:database"
      end
    end

    def masters_to_keep
      @server_hash.dig(:storage, :keep) || @config.defaults.dig(:storage, :keep) || 50
    end

    def ssh_port
      ssh_properties[:port]
    end

    def ssh_username
      ssh_properties[:username]
    end

    def ssh_properties
      DEFAULT_SSH_PROPERTIES.merge(@config.defaults[:ssh] || {}).merge(@server_hash[:ssh] || {})
    end

    def retention
      DEFAULT_RENTENTION.merge(@config.defaults[:retention] || {}).merge(@server_hash[:retention] || {})
    end

    def databases
      defaults =  DEFAULT_DATABASE_PROPERTIES.merge(@config.defaults[:databases]&.first || {})
      if @server_hash[:databases].is_a?(Array)
        @server_hash[:databases].map do |database|
          Database.new(self, defaults.merge(database))
        end
      else
        []
      end
    end

    def create_ssh_session
      Net::SSH.start(self.hostname, self.ssh_username, :port => self.ssh_port, :keys => ssh_properties[:key] ? [ssh_properties[:key]] : nil)
    end

  end
end
