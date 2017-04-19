SolidState
==========

Minuscule but solid state machine for Ruby classes. The only dependency is that your model responds to a getter and setter for `state`.

## Installation

In your Gemfile:

    gem 'solidstate'

## Usage

``` ruby

  # simplest example, using just an accessor
  class Post
    include SolidState

    attr_accessor :state
    states :draft, :published
  end

  # in its simplest form you just declare the possible states.
  # if it's a simple class you just get boolean methods for checking
  # whether the current status is X or Y.

  p = Post.new
  p.state      # => nil 
  p.state = 'draft'
  p.draft?     # true
  p.published? # => false
  p.state = 'published'
  p.published? # => true
  
  # you also have access to the list of possible states at Class.states, 
  # in case you need to enumerate them.
  # for instance, to populate a select field's options, you'd do something like:

  options = Post.states.map { |st| "<option value="#{st}">#{st}</option>" }.join("\n")

  # now, if the model class responds to validates_inclusion_of, it will
  # mark the record invalid if an unknown state is set.

  # let's assume this is actually an ActiveRecord class, and the
  # table contains a column named 'state'.

  class Post < ActiveRecord::Base
    include SolidState

    states :draft, :published
  end

  p = Post.new
  p.state = 'published'
  p.valid?  # => true
  p.state = 'deleted'
  p.valid?  # => false

  # you also get scopes for free if the class responds_to the `scope` method
  
  Post.published.first # => #<Post ...>
  Post.draft.count # => 1

  # ok, now let's gets get fancier. we're going to declare transitions
  # which will govern the possible directions in which an object's state
  # can move to.

  class Subscriber < ActiveRecord::Base
    include SolidState

    states :inactive, :active, :unsubscribed, :disabled do
      transitions from: :inactive, to: :active
      transitions from: :active, to: [:unsubscribed, :disabled]
      transitions from: :unsubscribed, to: :active
    end
  end

  s = Subscriber.new
  s.state # => 'inactive'

  # since we declared transitions, we can now call #{state}! which
  # checks whether the instance can transition to that state and
  # if so, sets the new state and optionally saves the record.

  s.active! # => true
  s.state   # => 'active'
  s.inactive! # => raises InvalidTransitionError

  # this also works outside transition methods, of course.

  s.reload  # => true
  s.active? # => true

  s.state = 'inactive'
  s.valid? # => false

  # the last trick this library does is that it optionally lets you
  # declare callback methods that are called whenever a transition
  # method succeeds. just define a method called #once_[state] in
  # your model.

  class Subscriber
    def once_unsubscribed
      puts "Sorry to see you go!"
    end
  end

  # ...
  s.unsubscribed! # => prints "Sorry to see you go!"
```

That's about it. For examples check the `examples` directory in this repo.

# Contributions

You're more than welcome. Send a pull request, including tests, and make sure you don't break anything. That's it.

# Author

Tomás Pollak

# Copyright

(c) Fork Limited. MIT license.
