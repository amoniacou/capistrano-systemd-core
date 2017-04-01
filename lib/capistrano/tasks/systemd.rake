require 'capistrano/systemd/service'

namespace :load do
  task :defaults do
    set :systemd_roles, -> { :app }
    set :systemd_services, -> { {} }
    set :_systemd_service_objects, -> { {} }
  end
end

namespace :deploy do
  before :starting, 'systemd:add_default_hooks'
end

namespace :systemd do
  desc 'Setup systemd directories'
  task :setup do
    on roles fetch(:systemd_roles) do
      if test "[ -d #{::Capistrano::Systemd::Service::SYSTEMD_DIR_PATH} ]"
        info "Systemd User folder already exist"
      else
        execute :mkdir, '-p', ::Capistrano::Systemd::Service::SYSTEMD_DIR_PATH
      end
    end
  end

  def generate_namespace_for_service(service, parent_task)
    my_namespace = "systemd:service:#{service.name}"
    %w(setup enable disable start stop restart).each do |action|
      parent_task.application.define_task Rake::Task, "#{my_namespace}:#{action}" do
        on roles fetch(:systemd_roles) do |server|
          service.__send__(action.to_sym, server, self)
        end
      end
    end
  end

  desc 'Default hook on load'
  task :hook do |task|
    task.fetch(:systemd_services).each do |key, value|
      name = key.to_s.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
      service = ::Capistrano::Systemd::Service.new(name, value, task)
      generate_namespace_for_service(service, task)
    end
  end

  task :add_default_hooks do
    after 'deploy:check', 'systemd:services:check'
    after 'deploy:updated', 'systemd:services:stop'
    after 'deploy:reverted', 'systemd:services:stop'
    after 'deploy:published', 'systemd:services:start'
  end

  namespace :services do
    task :check do
      task.fetch(:systemd_services).each do |key, value|
        name = key.to_s.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["systemd:service:#{name}:setup"].invoke
      end
      on roles fetch(:systemd_roles) do |server|
        execute :systemctl, "--user", "daemon-reload"
      end
    end
    task :stop do
      task.fetch(:systemd_services).each do |key, value|
        name = key.to_s.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["systemd:service:#{name}:stop"].invoke
      end
    end
    task :start do
      task.fetch(:systemd_services).each do |key, value|
        name = key.to_s.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["systemd:service:#{name}:start"].invoke
      end
    end

  end
end


namespace :load do
  task :defaults do
    set :systemd_roles, fetch(:systemd_roles, [:app, :db])
  end
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'systemd:hook'
end
