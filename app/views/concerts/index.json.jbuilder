json.array!(@concerts) do |concert|
  json.extract! concert, :id,
                         :name,
                         :program,
                         :stage,
                         :map,
                         :information
  json.url concert_url(concert, format: :json)
end
