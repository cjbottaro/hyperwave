require "net/ssh"
require "yaml"

require "hyperwave/version"
require "hyperwave/dsl"
require "hyperwave/host"

module Hyperwave

  def self.each_host(hosts, &block)
    hosts.each{ |host| Hyperwave::Host.new(host).call(&block) }
  end

end

#
#     Net::SSH.start("159.65.249.115", "root") do |ssh|
#       # open a new channel and configure a minimal set of callbacks, then run
#       # the event loop until the channel finishes (closes)
#       stdout = ""
#       stderr = ""
#       exit_code = nil
#       exit_signal = nil
#
#       channel = ssh.open_channel do |ch|
#         ch.exec("sh -c '#{cmd}'") do |ch, success|
#           unless success
#             abort "FAILED: couldn't execute command (ssh.channel.exec)"
#           end
#
#           ch.on_data do |ch,data|
#             stdout += data
#           end
#
#           ch.on_extended_data do |ch,type,data|
#             stderr += data
#           end
#
#           ch.on_request("exit-status") do |ch,data|
#             exit_code = data.read_long
#           end
#
#           ch.on_request("exit-signal") do |ch, data|
#             exit_signal = data.read_long
#           end
#         end
#       end
#
#       channel.wait
#
#       puts "stdout: #{stdout}"
#       puts "stderr: #{stderr}"
#       puts "exit_code: #{exit_code}"
#       puts "exit_signal: #{exit_signal}"
#     end
#   end
# end
