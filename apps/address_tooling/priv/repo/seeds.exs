# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AddressTooling.Repo.insert!(%AddressTooling.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias AddressTooling.Address.LoadData

LoadData.load_towns("../../data/town-administrative-area-count.tsv")
LoadData.load_address_names("../../data/address-names.tsv")
LoadData.load_streets("../../../addressbase-data/cache/street/",
  "../../data/town-administrative-area-count.tsv")
LoadData.index_streets()
LoadData.load_addresses("../../../addressbase-data/cache/address/")
LoadData.index_addresses()
