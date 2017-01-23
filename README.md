### Setting up the local environment

Create the test and development databases:

```bash
$ rake db:create
```

Run all migrations:

```bash
$ rake db:migrate
```

### Running the application
#### Using the GDS development VM

In the development VM, go to:

```bash
cd /var/govuk/development
```

Then run:

 ```bash
 bowl content-performance-manager
 ```

The application can be accessed from:

http://content-performance-manager.dev.gov.uk

#### From the local machine

The application can be started with:

```bash
$ ./startup.sh
```

In the browser navigate to: http://localhost:3206

### Running the tests
 ```bash
 $ bundle exec rake
 ```

### Importing data

* [On the local environment](doc/importing_data#Local_environment)
* [On GOV.UK environments](doc/importing_data#jenkins)

### Deploying the application
* [Heroku](doc/deploying.md#heroku)
* [Integration](doc/deploying#integration)

### App development

* [GOVUK-LINT-RUBY](doc/govuk-lint.md)
* [Set up Google Analytics credentials in development](doc/google_analytics_setup.md)
