require 'pushpop'
require 'mixpanel-ruby'
require 'mixpanel_client'

module Pushpop

  class Mixpanel < Step

    PLUGIN_NAME = 'mixpanel'

    Pushpop::Job.register_plugin(PLUGIN_NAME, self)

    attr_accessor :_user
    attr_accessor :_endpoint
    attr_accessor :_query_properties
    attr_accessor :_user_created

    ## Setup Functions

    def run(last_response=nil, step_responses=nil)
      ret = self.configure(last_response, step_responses)

      unless self._user_created || self._user.nil?
        set({})
      end

      if self._endpoint
        Pushpop::Mixpanel.querent.request(self._endpoint, self._query_properties)
      else
        ret
      end
    end

    def configure(last_response=nil, step_responses=nil)
      self.instance_exec(last_response, step_responses, &block)
    end

    def user(id, properties = nil)
      self._user = id
    
      if properties.nil?
        self._user_created = false
      else
        self._user_created = true
        Pushpop::Mixpanel.tracker.people.set(id, properties)
      end
    end

    ### Querying Functions

    def query(endpoint, properties = {})
      self._endpoint = endpoint
      self._query_properties = properties 
    end

    ## Tracking Functions

    def track(name, properties = nil)
      raise 'You have to set the user before tracking mixpanel events' unless self._user

      if properties.nil?
        Pushpop::Mixpanel.tracker.track(self._user, name)
      else
        Pushpop::Mixpanel.tracker.track(self._user, name, properties)
      end
    end

    ## User Functions
    
    def set(properties)
      raise 'You have to set the user before updating properties' unless self._user
      self._user_created = true
      
      Pushpop::Mixpanel.tracker.people.set(self._user, properties)
    end

    def create_alias(new_id, previous_id)
      Pushpop::Mixpanel.tracker.alias(new_id, previous_id)
      self._user = new_id
    end

    def increment(properties)
      raise 'You have to set the user before incrementing' unless self._user
      Pushpop::Mixpanel.tracker.people.increment(self._user, properties)
    end

    def append(properties)
      raise 'You have to set the user before appending proeprties to it' unless self._user
      Pushpop::Mixpanel.tracker.people.append(self._user, properties)
    end

    def charge(amount, properties = nil)
      raise 'You have to set the user before charging them' unless self._user

      if properties.nil?
        Pushpop::Mixpanel.tracker.people.track_charge(self._user, amount)
      else
        Pushpop::Mixpanel.tracker.people.track_charge(self._user, amount, properties)
      end
    end

    def delete(ignore_alias = false)
      raise 'You have to set the user to delete' unless self._user

      if ignore_alias
        Pushpop::Mixpanel.tracker.people.delete_user(self._user, {"$ignore_alias" => true})  
      else
        Pushpop::Mixpanel.tracker.people.delete_user(self._user)
      end
    end
    
    
    class << self
      def tracker
        if @tracker
          @tracker
        else
          if !ENV['MIXPANEL_PROJECT_TOKEN'].nil? && !ENV['MIXPANEL_PROJECT_TOKEN'].empty?
            @tracker = ::Mixpanel::Tracker.new(ENV['MIXPANEL_PROJECT_TOKEN'])
          else
            raise 'You must provide a mixpanel project token'
          end
        end
      end

      def querent
        if @querent
          @querent
        else
          if ENV['MIXPANEL_API_KEY'].nil? || ENV['MIXPANEL_API_KEY'].empty?
            raise 'You must provide a mixpanel api key'
          elsif ENV['MIXPANEL_API_SECRET'].nil? || ENV['MIXPANEL_API_SECRET'].empty?
            raise 'Ypu must provide a mixpanel api secret'
          else
            @querent = ::Mixpanel::Client.new(
              api_key: ENV['MIXPANEL_API_KEY'],
              api_secret: ENV['MIXPANEL_API_SECRET']
            )
          end
        end
      end
    end
  end
end
