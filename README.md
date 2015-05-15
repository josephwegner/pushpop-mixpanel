# pushpop-mixpanel

Mixpanel plugin for [Pushpop](https://github.com/pushpop-project/pushpop).

- [Installation](#installation)
- [Usage](#usage)
  - [Global Functions](#global-functions)
  - [Tracking Functions](#tracking-functions)
  - [Analysis Functions](#analysis-functions)
- [Contributing](#contributing)

## Installation

Add `pushpop-mixpanel` to your Gemfile:

```ruby
gem 'pushpop-mixpanel'
```

or install it as a gem

```bash
$ gem install pushpop-mixpanel
```

## Usage

The mixpanel plugin gives you a simple interface for tracking information to Mixpanel. You can very simply do all sorts of things with Mixpanel, including creating/deleting users, updating their properties, tracking events, or deleting users altogether.

Here's a quick preview of what a mixpanel job might do

``` ruby

job 'track support users in mixpanel' do
	
	step 'receive users' do
		# Pretend that this step checks for new support emails,
		# and looks up some information based on that email
	end

	mixpanel do |response|
		# Set the user you want to interact with
		user response.email

		# Update the user with some basic information
		set({
			name: response.name,
			age: response.age
		})

		# Increment the support request count
		# Values that aren't currently set will be treated as 0, and then incremented
		increment({support_requests: 1})

		# Track a charge of $10 (your support fee)
		charge(10, {type: 'support charge'})
	end
end
```

In order to track things with `pushpop-mixpanel` you will need to drop your project token in the `MIXPANEL_PROJECT_TOKEN` environment variable.

### Global Functions

**user(id, [properties])**

This sets the user context for the rest of the step. All functions run after this will be run with the user `id` specified here. If this user does not already exist in Mixpanel, it will be created.

You can also pass in a hash of `properties` that will be set on the user. If the user already exists, the values in `properties` **will overwrite** existing properties.

### Tracking Functions

**track(name, [properties])**

This will track an event for the currently set user. You can optionally pass in a hash of metadata for this event.

### User Functions

**set(properties)**

Accepts a hash of properties that should be set for the current user. Any properties that already exist on that user will be overwritten by the new values in the hash.

**create_alias(new_id, previous_id)**

Creates a user id alias inside of Mixpanel. Any events/updates made with either `new_id` or `previous_id` going forward will now affect the same user inside of Mixpanel.

_This will also update the current user context to be `new_id`._

**increment(properties)**

This will increment/decrement numeric properties based on the values provided in the hash. For example:

``` ruby
track({
	support_tickets: 1, # Increase ticket count by 1
	available_balance: -10 # Decrease balance by 10
})
```

Incrementing properties that don't currently exist on the user will preset the property to 0, and then do the increment. So incrementing a new property by `10` will set that property to `10`.

**append(properties)**

This will push a value on to the end of a list property. For instance, say your user currently has a property, `{devices: ['android']}`. Then you ran:

``` ruby
append({
	devices: 'Mac'
})
```

Their `devices` property would now be `['android', 'Mac']`.

**charge(amount, [properties])**

This will add a charge associated with the current user. `amount` should be a dollar value. You can optionally pass in a hash of `properties` that describe the charge.

**delete([ignore_alias])**

This deletes the current user from Mixpanel. **This is a destructive action, and cannot be undone**.

To delete a user and ignore alias, pass `true` in to this function.

### Analysis Functions

Todo

## Contributing

Code and documentation issues and pull requests are definitely welcome!