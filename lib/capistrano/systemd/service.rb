module Capistrano
  module Systemd
    class ServerConfig
      attr_accessor :environments, :description, :user, :env_file, :command, 
                    :reload_signal, :stop_signal, :pid_file, :timeout,
                    :memory_max, :cpu_quota, :io_weight, :cmd, :slice

      def initialize(name, server, cmd, path)
        @environments = ::SSHKit.config.default_env.dup
        @environments[:rails_env] = 'production'
        @description = "Run #{name} service"
        @dir = path.to_s
        @user = server.user
        if cmd.is_a?(::Hash)
          cmd.each do |k,v|
            __send__("#{k}=", v)
          end
        else
          @cmd = cmd
        end
        @command = "#{SSHKit.config.command_map[:bundle]} exec #{@cmd}"
        if @command =~ /\A\~/
          @command.sub!("~", "/home/#{@user}")
        end
        if @dir.to_s =~ /\A\~/
          @dir.sub!("~", "/home/#{@user}")
        end
        @reload_signal = 'HUP'
        @timeout = 30
        @stop_signal = 'TERM'
      end

      def stream(template)
        code = template.result(binding)
        StringIO.new(code)
      end

    end
    class Service

      SYSTEMD_DIR_PATH=".config/systemd/user"

      attr_accessor :name, :description, :environments, :user

      def initialize(name, cmd, rake_task)
        @name = name
        @cmd = cmd
        @rake_task = rake_task
        @app_name = @rake_task.fetch(:application).gsub(/\-/, '_')
      end

      def setup(server, backend)
        template_path = ::File.expand_path('../../templates/systemd.service.erb', __FILE__)
        if !template_path.nil? && File.exist?(template_path)
          upload_unit_file(template_path, server, backend)
        else
          backend.error "Something went wrong"
        end
      end

      def service_file_path
        @service_file_path ||= ::File.join(SYSTEMD_DIR_PATH, "#{@name}_#{@app_name}.service")
      end

      def service_name
        @service_name ||= ::File.basename(service_file_path)
      end

      def upload_unit_file(template_path, server, backend)
        template = ERB.new(File.read(template_path))
        config = ::Capistrano::Systemd::ServerConfig.new(@name, server, @cmd, @rake_task.current_path)
        if (slice = @rake_task.fetch(:systemd_slice))
          config.slice = slice
        end
        stream   = config.stream(template)
        backend.within '~/' do
          backend.upload! stream, service_file_path, {verbose: true}
        end
      end

      def enable(server, backend)
        backend.execute :systemctl, "--user", :enable, service_name
      end

      def disable(server, backend)
        backend.execute :systemctl, "--user", :disable, service_name
      end

      def start(server, backend)
        backend.execute :systemctl, "--user", :start, service_name
      end

      def stop(server, backend)
        backend.execute :systemctl, "--user", :stop, service_name
      end

      def restart(server, backend)
        backend.execute :systemctl, "--user", :restart, service_name
      end

      def kill(signal)
      end
    end
  end
end

