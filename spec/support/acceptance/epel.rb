# frozen_string_literal: true

# drbd-utils is provided by EPEL on EL
RSpec.configure do |c|
  c.before :suite do
    hosts.each do |host|
      next unless host['platform'].start_with?('el-')

      host.install_package("https://dl.fedoraproject.org/pub/epel/epel-release-latest-#{host['platform'].version}.noarch.rpm")
    end
  end
end
