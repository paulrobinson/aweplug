module Aweplug
  module Helpers
    module SearchiskoSocial

      def add_social_links contributor 
        unless contributor['accounts'].nil?
          contributor['social'] = contributor['accounts'].inject({}) do |res, account|
            case account['domain']
            when 'jboss.org'
              # No-op
            when 'google.com'
              account['url'] = account['link']
              account['service'] = 'google-plus'
              account['icon'] = 'fa-google-plus'
              res[account['service']] = account
            else
              default account do |a|
                res[a['service']] = a
              end
            end
            res
          end
        end
        contributor
      end

      def normalize normalization, existing, searchisko, name = nil
        res = nil
        if !existing.nil?
          searchisko.normalize(normalization, existing) do |normalized|
            unless normalized['sys_contributor'].nil?
              res = add_social_links(normalized['contributor_profile'])
            end
          end
        elsif !name.nil?
          searchisko.normalize('contributor_profile_by_jbossdeveloper_quickstart_author', name) do |normalized|
            unless normalized['sys_contributor'].nil?
              res = add_social_links(normalized['contributor_profile'])
            end
          end
        end
        res || OpenStruct.new({ :sys_title => name || existing })
      end

      private

      def default a
        # Use 'link' if available, otherwise try to construct it
        if a['link']
          a['url'] = a['link']
        else
          a['url'] = "http://#{a['domain']}/#{a['username']}"
        end
        a['service'] = a['domain'].chomp('.com')
        a['icon'] = "fa-#{a['service']}"
        yield a if block_given?
      end

    end
  end
end
