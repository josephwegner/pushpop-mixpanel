require 'spec_helper'

ENV['MIXPANEL_PROJECT_TOKEN'] = '0987654321'
ENV['MIXPANEL_API_KEY'] = '0987654321'
ENV['MIXPANEL_API_SECRET'] = '0987654321'

describe Pushpop::Mixpanel do
  describe 'track' do
    it 'tracks events' do
      step = Pushpop::Mixpanel.new do
        user '12345'
        track 'An Event'
      end

      expect(Pushpop::Mixpanel.tracker).to receive(:track).with('12345', 'An Event')
      step.run
    end

    it 'tracks events with properties' do
      step = Pushpop::Mixpanel.new do
        user '12345'
        track 'An Event', {browser: 'Chrome'}
      end

      expect(Pushpop::Mixpanel.tracker).to receive(:track).with('12345', 'An Event', {
        browser: 'Chrome'
      })
      step.run
    end

    it 'raises an error if the user is not set' do
      step = Pushpop::Mixpanel.new do
        track 'An Event'
      end

      expect{step.run}.to raise_error
    end
  end

  describe 'query' do
    it 'performs queries to an endpoint' do
      step = Pushpop::Mixpanel.new do
        query 'a/thing'
      end 

      expect(Pushpop::Mixpanel.querent).to receive(:request).with('a/thing', {})
      step.run
      expect(step._endpoint).to eq('a/thing')
    end

    it 'performs queries with properties' do
      step = Pushpop::Mixpanel.new do
        query 'a/thing', age: 23
      end

      expect(Pushpop::Mixpanel.querent).to receive(:request).with('a/thing', {age: 23})
      step.run
      expect(step._endpoint).to eq('a/thing')
    end
  end

  describe 'user' do
    it 'sets the user to do work with' do
      step = Pushpop::Mixpanel.new do
        user '12345'
      end

      step.run
      expect(step._user).to eq('12345')
    end

    it 'creates the user with blank properties if no other set is called' do
      step = Pushpop::Mixpanel.new do
        user '12345'
      end

      expect(Pushpop::Mixpanel.tracker.people).to receive(:set).with('12345', {})
      step.run
    end

    it 'updates the user if properties are passed' do
      step = Pushpop::Mixpanel.new do
        user '12345', {name: 'Bob'}
      end

      expect(Pushpop::Mixpanel.tracker.people).to receive(:set).with('12345', {name: 'Bob'})
      step.run
    end

    it 'updates a user' do
      step = Pushpop::Mixpanel.new do
        user '12345'
        set({coolness: 1})
      end

      expect(Pushpop::Mixpanel.tracker.people).to receive(:set).with('12345', {coolness: 1})
      step.run
    end

    describe 'alias' do
      it 'should create aliases' do
        step = Pushpop::Mixpanel.new do
          create_alias '12345', '54321' 
        end

          expect(Pushpop::Mixpanel.tracker).to receive(:alias).with('12345', '54321')
          step.run
      end

      it 'set the user to the new alias' do
        step = Pushpop::Mixpanel.new do
          create_alias '12345', '54321' 
        end

          step.run
          expect(step._user).to eq('12345')
      end
    end

    it 'increments a user property' do
      step = Pushpop::Mixpanel.new do
        user '12345'
        increment({coolness: 1})
      end

      expect(Pushpop::Mixpanel.tracker.people).to receive(:increment).with('12345', {coolness: 1})
      step.run
    end

    it 'appends a user property' do
      step = Pushpop::Mixpanel.new do
        user '12345'
        append({hair_color: 'red'})
      end

      expect(Pushpop::Mixpanel.tracker.people).to receive(:append).with('12345', {hair_color: 'red'})
      step.run
    end

    describe 'charge' do
      it 'adds a charge to a user' do
        step = Pushpop::Mixpanel.new do
          user '12345'
          charge 100
        end

        expect(Pushpop::Mixpanel.tracker.people).to receive(:track_charge).with('12345', 100)
        step.run
      end

      it 'passes properties if they are provided' do
        step = Pushpop::Mixpanel.new do
          user '12345'
          charge 100, {item: 'Hot Dog'}
        end

        expect(Pushpop::Mixpanel.tracker.people).to receive(:track_charge).with('12345', 100, {
          item: 'Hot Dog'
        })

        step.run
      end
    end

    describe 'delete' do
      it 'deletes a user' do
        step = Pushpop::Mixpanel.new do
          user '12345'
          delete
        end

        expect(Pushpop::Mixpanel.tracker.people).to receive(:delete_user).with('12345')
        step.run
      end

      it 'ignores aliases when deleting' do
        step = Pushpop::Mixpanel.new do
          user '12345'
          delete true
        end

        expect(Pushpop::Mixpanel.tracker.people).to receive(:delete_user).with('12345', {'$ignore_alias' => true})
        step.run
      end
    end

    describe 'errors' do
      it "can't increment withour a user" do
        step = Pushpop::Mixpanel.new do
          increment '54321'
        end

        expect{step.run}.to raise_error
      end
      
      it "can't append withour a user" do
        step = Pushpop::Mixpanel.new do
          append '12345'
        end

        expect{step.run}.to raise_error
      end
      
      it "can't charge withour a user" do
        step = Pushpop::Mixpanel.new do
          charge '100'
        end

        expect{step.run}.to raise_error
      end
    end
  end
end
