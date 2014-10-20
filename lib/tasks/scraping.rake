namespace :scraping do
  # descの記述は必須
  desc "2013をスクレイピング"

  # :environment は モデルにアクセスするのに必須
  task :scrap => :environment do

    #最初にDBを初期化
    Concert.delete_all

    #2014,2015をスクレイピング
    year = 3

    2.times do
    year = year + 1
      #一年間（12ヶ月）全てをスクレイピングしたい
      12.times do |x|
        month_now = x + 1
        #ｘを英語の月名に変換
        case month_now
        when 1 then
          month_name = 'jan'
        when 2 then
          month_name = 'feb'
        when 3 then
          month_name = 'mar'
        when 4 then
          month_name = 'apr'
        when 5 then
          month_name = 'may'
        when 6 then
          month_name = 'jun'
        when 7 then
          month_name = 'jul'
        when 8 then
          month_name = 'aug'
        when 9 then
          month_name = 'sep'
        when 10 then
          month_name = 'oct'
        when 11 then
          month_name = 'nov'
        when 12 then
          month_name = 'dec'
        end

        scrape_page = "http://www2s.biglobe.ne.jp/~jim/freude/calendar/201#{year}#{month_name}.html".to_s

        agent = Mechanize.new
        page = agent.get(scrape_page)

        #ほんとはpage.links.countで回す
        page.links.count.times do |i|
          @concert = Concert.new
          page = agent.get(scrape_page)
          link = page.links[i]
          link_url   = link.href #.gsub("..", "http://www2s.biglobe.ne.jp/~jim/freude")

          begin
            page = agent.get(link_url)
            #エラーをレスキュー(あとでしっかりチェックしよ)
            rescue Mechanize::ResponseCodeError => ex
            case ex.response_code
            when "404"
              warn "#{ex.page.uri} is not found. skipping..."
              next
            when /\A5\d\d\Z/
              warn "server error on #{ex.page.uri}"
              break
            else
              warn "UNEXPECTED STATUS: #{ex.response_code} #{ex.page.uri}"
              break
            end
          end

          item = Array.new(10)

          #演奏会情報でなければnext,演奏会情報ページにしか無いリンク場所を参照している。
          if page.search('//tr[6]/td/center/a[2]').empty?
            next
          end

          # 演奏会タイトルの取得
          main_title = ""
          main_title = page.search('//tr[1]/td/b/font').text.gsub("　", "").gsub("'", "’")
          sub_title = page.search('//tr[1]/td/p/b/font').text.gsub("　", "").gsub("'", "’")
          full_title = main_title #"#{main_title}【#{sub_title}】"
          if full_title.nil?
            @concert.name = "なし"
          else
            @concert.name = full_title
          end

          # 日時・場所・を取得
          page.search('//tr[3]/td/blockquote/p').each_with_index do |node, i|
            item[i] = node.text
          end

          program = item[0]
          if program.nil?
            @concert.program = "なし"
          else
            @concert.program = program
          end

          #場所情報をホール名のみに変更して取得
          item[1] = "読み込みエラー" if item[1].nil?

          stage_hull_name = item[1].to_s.gsub("\n場所： ", "")
          if stage_hull_name.empty?
            @concert.stage = 'なし'
          else
            @concert.stage = stage_hull_name
          end

          # 演奏曲目を連結表示
          content_all = ""
          page.search('//dd/b').each_with_index do |node, i|
            content_all = content_all + node.text.gsub("'", "’") + "\n"
          end
          if content_all.nil?
            @concert.content = "なし"
          else
            @concert.content = content_all
          end

          # お問い合わせ先を表示
          if page.search("//tr[3]/td/center/p[1]/a").blank?
            if page.search("//tr[3]/td/center/a").blank?
              info = ''
            else
              info = page.search("//tr[3]/td/center/a").attribute("href")
            end
          else
            info = page.search("//tr[3]/td/center/p[1]/a").attribute("href")
          end

          @concert.information = info.to_s

          # 住所情報を表示
          hall_short_name = item[1].gsub(" ", "　").gsub("大", "　").gsub("小", "　").gsub("シンフォニー", "　").split("　")
          stage_name = hall_short_name[0].gsub("\n場所： ", "")

          @access = Access.new
          access_all = Access.where("hall_name = '#{stage_name}'")
          if access_all.empty?
            @concert.map = "未登録"
            @access.train = "未登録"
          else
            @concert.map = access_all[0].spot
            @access.train = access_all[0].train
          end

          #何月の演奏会か判断するためのカラム
          @concert.month = month_now

          #セーブする
          @concert.save

        end
      end
    end
  end
end
