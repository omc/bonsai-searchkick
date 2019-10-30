# bonsai-searchkick gem

This gem offers a shim to set up [Searchkick](https://github.com/ankane/searchkick) to work with a Bonsai Elasticsearch cluster. The bonsai-searchkick gem automatically sets up the Searchkick client correctly so users don't need to worry about configuring it in their code or writing an initializer.

## Details

The Searchkick gem looks for an environment variable called `ELASTICSEARCH_URL` which is populated with a URL for an Elasticsearch cluster. If this variable is not found, it assumes the cluster is located at `http://localhost:9200`.

On platforms like [Heroku](https://elements.heroku.com/addons/bonsai) or [Manifold.co](https://www.manifold.co/services/bonsai-elasticsearch), adding Bonsai to an application creates an environment variable called `BONSAI_URL`, populated with this URL. Searchkick users on these platforms therefore need to take the extra step of creating the `ELASTICSEARCH_URL` and populating it with the contents of the `BONSAI_URL`.

This gem removes this extra step by supplying an initializer that checks for the presence of a `BONSAI_URL` variable and using it to populate the `ELASTICSEARCH_URL` variable. It also adds some logic around port specification, which was affected by [this change](https://github.com/elastic/elasticsearch-ruby/issues/669) to the elasticsearch-ruby gem, which Searchkick relies on.

## Usage

Add the following to your Gemfile outside of any block:

```ruby
gem 'bonsai-searchkick'
```

When the gem has been added to your Gemfile, run:

```
$ bundle install
```

This will bring in all the necessary dependencies, namely the Searchkick gem.

### Hosting on Heroku or Manifold

If you are running your application in Heroku or Manifold, the `BONSAI_URL` will be automatically created when you add Bonsai to your app. The gem will find it and set up the client automatically with no further work needed.

If you are using Heroku/Manifold, but have a direct account with Bonsai, then you will need to set the `BONSAI_URL` manually through the UI. You can get the URL from Bonsai, in your cluster dashboard, in the "Credentials" tab.

### Hosting somewhere else

If you're hosting your app somewhere else, you will need to create and populate the environment variable manually:

```
export BONSAI_URL="https://user1234:pass5678@cluster-slug-123.aws-region-X.bonsai.io:443"
```

### Developing Locally

If you are developing and have a Elasticsearch cluster running locally (`localhost:9200`), then you do not need to set either the `BONSAI_URL` or `ELASTICSEARCH_URL`. If your local cluster has some non-default url, like `http://127.0.0.1:9250`, then you will need to put this into the `ELASTICSEARCH_URL` variable:

```
export ELASTICSEARCH="https://user1234:pass5678@cluster-slug-123.aws-region-X.bonsai.io:443"
```

**It's a best practice to use the BONSAI_URL to connect to Bonsai clusters, and ELASTICSEARCH_URL to connect to local or non-Bonsai clusters.** And if you aren't using Bonsai for anything, then what do you need this gem for??

## Running

When the Rails application starts up, an initializer will be loaded that looks for the `BONSAI_URL` variable. If it is found, and is valid, a Searchkick client will be initialized and correctly configured to use a Bonsai cluster.

See the [official documentation](https://github.com/ankane/searchkick) for information on all the things Searchkick can do. We have [additional documentation](https://docs.bonsai.io/article/99-searchkick) on getting up and running with Searchkick on Bonsai.io.

## Support

Having trouble with the gem? Find a problem or a bug? Just want to say thanks? Shoot us an [email](mailto:support@bonsai.io)!
