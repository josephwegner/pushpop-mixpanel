require 'pushpop'
require 'mixpanel-ruby'

module Pushpop

  class Mixpanel < Step

    PLUGIN_NAME = 'mixpanel'

    Pushpop::Job.register_plugin(PLUGIN_NAME, self)

    attr_accessor :_user

    ## Setup Functions

    def run(last_response=nil, step_responses=nil)
      self.configure(last_response, step_responses)
    end

    def configure(last_response=nil, step_responses=nil)
      self.instance_exec(last_response, step_responses, &block)
    end

    def user(id, properties = nil)
      self._user = id

      unless properties.nil?
        Pushpop::Mixpanel.tracker.people.set(id, properties)
      end

      nil
    end

    ## Tracking Functions

    def track(name, properties = nil)
      raise 'You have to set the user before tracking mixpanel events' unless self._user

      if properties.nil?
        Pushpop::Mixpanel.tracker.track(self._user, name)
      else
        Pushpop::Mixpanel.tracker.track(self._user, name, properties)
      end
      nil
    end

    ## User Functions

    def create_alias(new_id, previous_id)
      Pushpop::Mixpanel.tracker.alias(new_id, previous_id)
      self._user = new_id
      nil
    end

    def increment(properties)
      raise 'You have to set the user before incrementing' unless self._user
      Pushpop::Mixpanel.tracker.people.increment(self._user, properties)
      nil
    end

    def append(properties)
      raise 'You have to set the user before appending proeprties to it' unless self._user
      Pushpop::Mixpanel.tracker.people.append(self._user, properties)
      nil
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
    end
  end
end
