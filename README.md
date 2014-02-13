puppet-mms
==========

A puppet module for installing and configuring Mongodb's [MMS](https://mms.mongodb.com) agent.


Quick Start
-----------

### Basic installation with defaults

```puppet
class { 'mms':
  api_key => 'a3fe2877b0abb753e6deaec516c2a2a9'
}
```

License
-------

This module is released under the [MIT](http://opensource.org/licenses/MIT) License.

Support
-------

Please log tickets and issues at our [Projects site](https://github.com/tystr/puppet-mms/issues).

Running the tests
-----------------

To run the rspec-puppet tests:

`rake spec`