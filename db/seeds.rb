#
# Concert.create(id: '1', name: 'a', program: 'a', stage: 'a', map: 'a', information: 'a', content: 'a')
#
# Access.create(hall_name: '俺の実家', spot: '埼玉県飯能市のどっか', train: '元加治駅から徒歩15分')
# Access.create(hall_name: 'どこか', spot: 'どこか', train: 'どこか')
# Access.create(hall_name: '東京芸術劇場', spot: '和光市', train: '和光市駅から近場')
#
# Infomation.create(oke_name: '一橋大学管弦楽団', info: 'masuo@masuo.com')
# Infomation.create(oke_name: 'だれか', info: 'dareka@dareka.com')
# Infomation.create(oke_name: 'なにか', info: 'nanika@nanika.com')

require "csv"

CSV.foreach('db/tokyo_hall_station.csv') do |row|
  Access.create(:hall_name => row[0], :station => row[1])
end

puts "seed完了"
