#json.extract! @concert,
#                        :id,
#                        :name,
#                        :program,
#                        :stage,
#                        :map,
#                        :information,
#                        :created_at,
#                        :updated_at


#json.extract! @access,
#                        :hall_name,
#                        :spot,
#                        :train

#json.extract! @infomation,
#                        :oke_name,
#                        :info


json.array!(@concerts) do |concert|
  json.extract! concert, :id,
                         :name,
                         :program,
                         :stage,
                         :map,
                         :information
  json.url concert_url(concert, format: :json)
end
