# iTunes Receipt Mock

[![Build Status](https://travis-ci.org/mbaasy/itunes-receipt-mock-ruby.svg?branch=master)](https://travis-ci.org/mbaasy/itunes-receipt-mock-ruby)
[![Code Climate](https://codeclimate.com/github/mbaasy/itunes-receipt-mock-ruby/badges/gpa.svg)](https://codeclimate.com/github/mbaasy/itunes-receipt-mock-ruby)
[![Test Coverage](https://codeclimate.com/github/mbaasy/itunes-receipt-mock-ruby/badges/coverage.svg)](https://codeclimate.com/github/mbaasy/itunes-receipt-mock-ruby/coverage)
[![Dependency Status](https://gemnasium.com/mbaasy/itunes-receipt-mock-ruby.svg)](https://gemnasium.com/mbaasy/itunes-receipt-mock-ruby)

## Overview

itunes Receipt Mock is useful for mocking [iTunes receipt validation](https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html) responses in projects where iTunes receipt validation is implemented. This project was extracted from [mbaasy.com](https://mbaasy.com/) which offers [iTunes and Google Play receipt validation as a service](https://mbaasy.com/docs/).

## Installation

Via terminal:

```
$ gem install itunes-receipt-mock
```

Or add it to your Gemfile:

```ruby
gem 'itunes-receipt-mock', group: :test
```

## Usage

### Generating a mock iTunes Receipt

```ruby
receipt = ItunesReceiptMock.new(bundle_id: 'com.example')
receipt.as_json
```

#### Options

| Name | Required | Type | Default | Description |
| ---- | -------- | ---- | ------- | ----------- |
| bundle_id | Yes | String | - | The app's bundle identifier |
| status | No | Fixnum | 0 | Status of receipt, anything other than 0 will result in an invalid receipt when calling #as_json |
| request_date| No | Time | Time.now | Time when the receipt was requested from the app |
| adam_id | No | Fixnum | 1 | The app's Adam identifier |
| app_item_id | No | Fixnum | 1 | A string that the App Store uses to uniquely identify the application that created the transaction |
| application_version | No | Fixnum | 1 | The app's version number |
| download_id | No | Fixnum | 1 | The app's download identifier |
| version_external_identifier | No | Fixnum | 1 | An arbitrary number that uniquely identifies a revision of your application |
| original_application_version | No | Fixnum | 1 | The version of the app that was originally purchased |
| original_purchase_date | No | Time | Time.now | The original download date of the app |

### Adding a purchase

```ruby
receipt = ItunesReceiptMock.new(bundle_id: 'com.example')
purchase = receipt.transactions.create(product_id: 'premium')
receipt.as_json
```

#### Options

| Name | Required | Type | Default | Description |
| ---- | -------- | ---- | ------- | ----------- |
| product_id | Yes | String | - | In-app purchase product identifier |
| quantity | No | Fixnum | 1 | The number of items purchased |
| transaction_id | No | Fixnum | Auto-increment | The transaction identifier of the item that was purchased |
| original_transaction_id | No | String | Same as transaction_id | For a transaction that restores a previous transaction, the transaction identifier of the original transaction. Otherwise, identical to the transaction identifier |
| purchase_date | No | Time | Time.now | The date and time that the item was purchased |
| original_purchase_date | No | Time | Same as purchase_date | For a transaction that restores a previous transaction, the date of the original transaction |

### Adding a subscription

```ruby
receipt = ItunesReceiptMock.new(bundle_id: 'com.example')
subscription = receipt.transactions.create(
  product_id: 'premium_1_month',
  expires_date: 1.month.from_now
)
receipt.as_json
```

#### Options (extends adding a purchase)

| Name | Required | Type | Default | Description |
| ---- | -------- | ---- | ------- | ----------- |
| expires_date | Yes | Time | - | The expiration date for the subscription |
| web_order_line_item_id | No | FixNum | Auto-increment | The primary key for identifying subscription purchases |
| is_trial_period | No | Boolean | false | Indicates if the subscription is in trial |

### Renewing a subscription

```ruby
receipt = ItunesReceiptMock.new(bundle_id: 'com.example')
subscription = receipt.transactions.create(
  product_id: 'premium_1_month',
  purchase_date: 1.month.ago,
  expires_date: Time.now
)
subscription.renew(expires_date: 1.month.from_now)
receipt.as_json
```

### Accessing the result

```ruby
receipt = ItunesReceiptMock.new(bundle_id: 'com.example')
receipt.as_json
```

## Contributing

1. Read our [Code of Conduct](/CODE_OF_CONDUCT.md).
1. Fork, clone, change, test and document.
1. Create a PR with a clear description of your changes.

---

Copyright 2015 [mbaasy](https://mbaasy.com/). This project is subject to the [MIT Licence](/LICENCE.txt).
