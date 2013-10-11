#! /usr/bin/env ruby
require 'yaml'

$LOAD_PATH.unshift(File.expand_path('../lib/', File.dirname(__FILE__)))
require 'libudns'

url = ARGV[0] || "http://lax.github.com"
dns = YAML.load_file(File.expand_path('../etc/dns.yml', File.dirname(__FILE__)))

puts url
puts

if url =~ /^http[s]*:\/\/([^\/]+).*/
	domain = $1

	dns.each do |isp, dns_list|
		dns_list.each do |dns_name, dns_ip|

			hosts = UDNS.get_cname_list(domain, [dns_ip])

			puts "#{isp}/#{dns_name}: #{hosts.join("\t")}\n\n"
			puts "host\t\tsize\tcode\t\dns\tconnect\tpre\tstart\ttotal\n\n"

			hosts.last.each do |host|
				tmpurl = url.sub(/http[s]*:\/\/(#{domain})/, "http://#{host}") 
				4.times do
					print "#{host}\t"
					puts `curl -b "vip=1" --compressed -e http://www.renren.com -o /dev/null -s -w"%{size_download}\t%{http_code}\t%{time_namelookup}\t%{time_connect}\t%{time_pretransfer}\t%{time_starttransfer}\t%{time_total}\n" -H "Host: #{domain}" "#{tmpurl}"`
					sleep 0.5
				end
				puts
			end
		end
	end
end

