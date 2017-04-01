module Capistrano
  module Systemd
    def env_variables
      ::SSHKit.config.default_env.map { |k, v| "#{k.upcase}=\"#{v}\"" }.join(' ')
    end

    def pid_full_path(pid_path)
      if pid_path.start_with?('/')
        pid_path
      else
        "#{shared_path}/#{pid_path}"
      end
    end

  end
end

load File.expand_path('../tasks/systemd.rake', __FILE__)
