# ActsAsMentionable

ActsAsMentionable is an ActiveRecord gem, which is called to help you build your own mentioning system on top of your Ruby On Rails project. With its help you can mention ActiveRecord objects from ActiveRecord objects, such as users from within the comment's text. For instance, when John Doe mentioned Richard Roe in a comment, then Richard Roe usually will receive the notification about being mentioned and mention will be stored in database.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'acts_as_mentionable'
```

And then execute:
```shell
$ bundle
```

Or install it yourself as:
```shell
$ gem install acts_as_mentionable
```

#### Post Installation

Install migrations
```shell
rake acts_as_mentionable_engine:install:migrations
```

Review the generated migrations then migrate:
```shell
rake db:migrate
```

## Usage

Let's continue with mentioning users from the comment. In a such case comment is a mentioner, because it can mention users, and user is a mentionable, as user can be mentioned.

### Mentioner model

```ruby
# == Schema Information
#
#  id          :integer          not null, primary key
#  body        :text(65535)
#  parsed_body :text(65535)
#

class Comment < ActiveRecord::Base
  # ...
  acts_as_mentioner :body
  # ...
  def retrieve_mentions_callback
    mentionables = ActsAsMentionable::MentionerParser.new(self).parse!
    replace_mentionables(mentionables, save: true)
  end
end
```

Mentioner (`Comment`) model is expected to have two fields:
1. The field, which contains, let's say, plain version of the comment - in the example above it's `body`. This field, by default, is rewritten by the parser and contains all the mentions as the plain text, e.g. `Hello, @john!`.
2. The field, which contains comment with the mentions. It's named as the `parsed_*`, where `*` is meant to be the field, which contains plain version of the comment. In the example above it's named `parsed_body`. Mentions are recognized by the following template - `{#|RECORD_ID|RECORD_MODEL_NAME}`, where `RECORD_ID` is the ID of record being mentioned, for instance, user ID, and, `RECORD_MODEL_NAME` is the name of the model being mentioned, for instance, for `User` model it is `user`. According to this, `parsed_body` field may have the following value - `Hello, {#|42|user}!`.

So, as you may have already noticed, the argument provided to the `#acts_as_mentioner` method is the name of the field, which is a plain version of the comment - `body`, and the name of the field, which contains mentions is generated automatically - `parsed_body`.

### Mentionable model

```ruby
# == Schema Information
#
#  id       :integer          not null, primary key
#  username :string(255)
#

class User < ActiveRecord::Base
  # ...
  acts_as_mentionable :username
  # ...
end
```
The argument `username` provided to `#acts_as_mentionable` method, is a field on user's model, which is used as a replacement for mention template in order to build a plain version of the comment. For example, we have the following code:
```ruby
user = User.create! id: 42, username: 'john'
comment = Comment.create! parsed_body: 'Hello, {#|42|user}!'
puts comment.body
# => Hello, @john!
```
As you can see, it this case `{#|42|user}` in `parsed_body` is replaced by `@` + `username` field of the user in comment's `body`.

### Retrieving mentions

Mentioner's `parsed_*` field is not parsed by default. You have to invoke `ActsAsMentionable::MentionerParser#parse!` method in order to parse it and retrieve mentionables (users in our case).

```ruby
mentionables = ActsAsMentionable::MentionerParser.new(comment).parse!
```

The line above parses comment's `parsed_body` field and does the following:
1. Generates and saves the plain version of the comment - `body` field.
2. Returns mentionables - in our case only users are expected, but it's possible to mix different types of mentionables.

We can mix together several types of mentionables. Let's check the following code:

```ruby
comment = Comment.create! \
  parsed_body: 'Hello, {#|42|user}! Can you please join the {#|123|community}?'

mentionables = ActsAsMentionable::MentionerParser.new(comment).parse!

comment.body
# => Hello, @john! Can you please join the @developers?

mentionables
# => [#<User:...>, #<Community:...>]
```

In this case `User` with ID `42` and `Community` with ID `123` are mentioned, but only if `Community` model has `acts_as_mentionable` defined on it. Otherwise, `{#|123|community}` will be left as is:
```ruby
comment.body
# => Hello, @john! Can you please join the {#|123|community}?

mentionables
# => [#<User:...>]
```

Just in case, `ActsAsMentionable::MentionerParser` class does not fit your needs, you can either extend or define your own class, which parses `parsed_body` field, writes `body` and returns mentioned records. Here you can see implementation details of the existing one [mentioner_parser.rb](https://github.com/Fuseit/acts_as_mentionable/blob/master/lib/acts_as_mentionable/mentioner_parser.rb).

### Saving mentions

In order to save mentioned records you can use of the following methods defined on mentioner:

Mention records, `save` option is set to `false` by default:
```ruby
comment.mention mentionables, save: false
```

Unmention records, `save` option is set to `false` by default:
```ruby
comment.unmention mentionables, save: false
```

Replace mentioned records, `save` option is set to `false` by default:
```ruby
comment.replace_mentionables mentionables, save: false
```

Save changes to mentions:
```ruby
comment.save_mentions
```

### Callbacks

When there are changes to mentions and mentions being saved a callback with mentioner record and mention changes can be invoked. In order to define a callback, add the Rails initializer like the following:

```ruby
# config/initializers/acts_as_mentionable.rb

ActsAsMentionable.setup do |configuration|
  configuration.mentions_updated_callback = lambda do |mentioner, changes|
    p mentioner
    # => #<Comment:...>

    p changes
    # =>
    # {
    #   changed: true,
    #   added: [#<User:...>, #<Community:...>],
    #   removed: [#<User:...>],
    #   previous: [#<User:...>],
    #   current: [#<User:...>, #<Community:...>]
    # }
  end
end
```

Where, `mentioner` in our case is a comment record, which mentioned users, and changes is a hash of changes, which has the following keys:
* `:changed` - detects if changed is being made to mentions
* `:added` - defines, which mentions were added
* `:removed` - defines, which mentions were removed
* `:previous` - defines, which mentions were before
* `:current` - defines, which mentions are currently saved

### Mentioner methods

* `#mentioner?` - is always set to `true` for mentioner records (e.g. comment), otherwise is set to `false`
* `#mentionables` - returns mentioned records
* `#mention *mentionables, save: false` - mention records
* `#unmention *mentionables, save: false` - unmention records
* `#replace_mentionables *mentionables, save: false` - replace mentioned records
* `#save_mentions` - save changes to mentions
* `#retrieve_mentions_callback` - is a callback method, which should retrieve and save mentions. It does nothing by default, so you have to redefine it.
* `#need_retrieve_mentions?` - returns `true` if `#retrieve_mentions_callback` should be invoked. By default it's an alias to mentioner's `parsed_*_changed?` attribute, e.g. `parsed_body_changed?`. You can redefine this method if you want to have custom logic for invoking `#retrieve_mentions_callback`.

### Mentionable methods

* `#mentionable?` - is always set to `true` for mentionable records (e.g. user), otherwise is set to `false`
* `#mentionables` - returns mentioner records, e. g. an array of comments, where user is mentioned

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Fuseit/acts_as_mentionable.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
