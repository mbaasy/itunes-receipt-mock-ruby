# ITunes Receipt Ruby Mock

[![Build Status](https://travis-ci.org/mbaasy/itunes-receipt-ruby-mock.svg?branch=master)](https://travis-ci.org/mbaasy/itunes-receipt-ruby-mock)

## Installation

Via terminal:

```
$ gem install itunes-receipt-ruby-mock
```

Or add it to your Gemfile:

```ruby
gem 'itunes-receipt-ruby-mock', group: :test
```

## Basic usage

```ruby
require 'itunes_receipt_mock'

receipt = ItunesReceiptMock.new(bundle_id: 'com.example')
receipt.add_product(product_id: 'premium')
receipt.add_subscription(product_id: 'premium_1_month', expires_date: 1.month.from_now)
result = receipt.result.as_json
```
#### Result:

```json
{
  "status": 0,
  "environment": "Production",
  "receipt":{
    "receipt_type": "Production",
    "adam_id": 0,
    "app_item_id": 0,
    "bundle_id": "com.example",
    "application_version": "1",
    "download_id": 0,
    "version_external_identifier": 0,
    "original_application_version": 0,
    "in_app":[{
      "quantity": 1,
      "product_id": "premium_1_month",
      "transaction_id": "7956476522",
      "original_transaction_id": "7956476522",
      "purchase_date": "2015-08-11 10:09:41 Etc/GMT",
      "purchase_date_ms":1439287781054,
      "purchase_date_pst": "2015-08-11 02:09:41 America/Los_Angeles",
      "original_purchase_date": "2015-08-11 10:09:41 Etc/GMT",
      "original_purchase_date_ms":1439287781054,
      "original_purchase_date_pst": "2015-08-11 02:09:41 America/Los_Angeles"
    }],
    "request_date": "2015-08-11 10:11:34 Etc/GMT",
    "request_date_ms":1439287894257,
    "request_date_pst": "2015-08-11 02:11:34 America/Los_Angeles",
    "original_purchase_date": "2015-08-11 10:09:41 Etc/GMT",
    "original_purchase_date_ms":1439287781051,
    "original_purchase_date_pst": "2015-08-11 02:09:41 America/Los_Angeles"
  },
  "latest_receipt_info": [],
  "latest_receipt": ""
}
```
