# Rails Kickoff

Based on the great work done by [Andy Leverenz](https://github.com/justalever/kickoff_tailwind), customized to my personal needs and preferences.

### Creating a new app

```bash
$ rails new sample_app -d <postgresql, mysql, sqlite> -m template.rb
```

### Once installed what do I get?

- Webpack support + Tailwind CSS and StimulusJS configured in the `app/javascript` directory.
- Optional Foreman support thanks to a `Profile`. Once you scaffold the template, run `foreman start` to initialize and head to `locahost:5000` to get `rails server`, `sidekiq` and `webpack-dev-server` running all in one terminal instance. Note: Webpack will still compile down with just `rails server` if you don't want to use Foreman. Foreman needs to be installed as a global gem on your system for this to work. i.e. `gem install foreman`
- Git initialization out of the box

#### Booting your local server with redis

To utilize foreman with Sidekiq noted above you'll need to install redis. The gem comes within a new rails application but it is commented out. Uncomment that line and run `bundle install`. It also might be handy to install redis on your machine (assuming you're on a mac) run `brew install redis` to install it. Then in a new terminal instance you can run `redis-server`.

After that is running, open a new terminal instance and finally run `foreman start`. Head to `locahost:5000` to see your app. You'll have hot reloading on `js` and `css` and `scss/sass` files by default. Feel free to configure to look for more to compile reload as your app scales.
