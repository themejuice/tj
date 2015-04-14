# # encoding: UTF-8
#
# module ThemeJuice
#   class Service::List < ::ThemeJuice::Service
#
#     def initialize(opts = {})
#       super
#     end
#
#     #
#     # List all development sites
#     #
#     # @return {Void}
#     #
#     def list
#       sites = get_sites
#
#       if sites.empty?
#         @interact.log "Nothing to list."
#       else
#         @interact.list "Your sites :", :green, sites
#       end
#     end
#
#     #
#     # Get an array of development sites
#     #
#     # @return {Array}
#     #
#     def get_sites
#       sites = []
#
#       Dir.glob(File.expand_path("#{@env.vvv_path}/www/*")).each do |f|
#         sites << File.basename(f).gsub(/(tj-)/, "") if File.directory?(f) && f.include?("tj-")
#       end
#
#       sites
#     end
#   end
# end
