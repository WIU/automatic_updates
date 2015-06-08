#
# Copyright 2015, Rackspace
#

require 'poise'

class Chef
  class Provider
    # Provider definition for automatic_updates
    class AutomaticUpdatesCentOS < Chef::Provider::LWRPBase
      def action_enable
        converge_by('install yum-cron and configure service') do
          package 'yum-cron' do
            action :install
          end

          # template any relevant files (gets around checking for versions)
          %w(/etc/sysconfig/yum-cron /etc/yum/yum-cron.conf).each do |settings_file|
            template settings_file do
              owner 'root'
              group 'root'
              mode '0644'
              cookbook 'automatic_updates'
              variables(
                automatic_updates_enabled: 'yes',
                download_only: 'no'
              )
              only_if { ::File.exist?(settings_file) }
              notifies :restart, 'service[yum-cron]', :delayed
            end
          end

          service 'yum-cron' do
            supports restart: true, reload: true, status: true
            action [:enable, :start]
          end
        end
      end

      def action_disable
        converge_by('disable yum-cron service') do
          # template any relevant files (gets around checking for versions)
          %w(/etc/sysconfig/yum-cron /etc/yum/yum-cron.conf).each do |settings_file|
            template settings_file do
              owner 'root'
              group 'root'
              mode '0644'
              cookbook 'automatic_updates'
              variables(
                automatic_updates_enabled: 'no',
                download_only: 'yes'
              )
              only_if { ::File.exist?(settings_file) }
              notifies :stop, 'service[yum-cron]', :delayed
            end
          end

          service 'yum-cron' do
            supports restart: true, reload: true, status: true
            action [:disable, :stop]
          end
        end
      end
    end
  end
end
