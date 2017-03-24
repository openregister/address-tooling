# Address Tooling

## Matching algorithm R&D

Given lines of an address - code looks for
[town matches](https://github.com/openregister/address-tooling/blob/match/apps/address_tooling/lib/address_tooling/match/town.ex#L5), then
[streets matching from those towns](https://github.com/openregister/address-tooling/blob/match/apps/address_tooling/lib/address_tooling/match/street.ex#L27),
 then
 [scores addresses on those matching streets](https://github.com/openregister/address-tooling/blob/match/apps/address_tooling/lib/address_tooling/match/score.ex#L190).

Address data is stored and indexed in collections:

| Collection | Fields |
| :---       | :---   |
| Town       | town_name, administrative_area |
| Street     | street_name, locality, town_id |
| Address    | (name OR street_number_integer OR address_name_id), street_id, town_id, parent_id, coords |

## To install

Install mongodb and Elixir if not already installed. On a Mac:

```
brew install elixir
brew install mongodb
```

Then load address data:

```
cd apps/address_tooling/
mix address.load
```

To run tests:

```
mix test
```
