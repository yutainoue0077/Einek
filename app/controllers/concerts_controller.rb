class ConcertsController < ApplicationController
  before_action :set_concert, only: [:edit, :update, :destroy]
  before_action :delete_concert, only: [:show]
  #require 'Nokogiri'
  #require 'open-uri'
  #require 'selenium-webdriver'
  require 'rubygems'
  require 'mechanize'
  require 'spreadsheet'
  require 'stringio'

  # GET /concerts
  # GET /concerts.json
  def index
    @concerts = Concert.all
    @accesss = Access.all
    @infomation = Infomation.all
  end


  # 一月分の演奏会を表示
  def show

    scrape_page_month = request.path_info.gsub("/concert/", "")
    #scrape_page = "http://www2s.biglobe.ne.jp/~jim/freude/calendar/2014jan.html".to_s
    scrape_page = "http://www2s.biglobe.ne.jp/~jim/freude/calendar/2014#{scrape_page_month}.html".to_s

    agent = Mechanize.new
    page = agent.get(scrape_page)

    #ほんとはpage.links.countで回す
    30.times do |i|
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

      #doc = Nokogiri::HTML(link_url)
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
      #@infomation = Infomation.new
      if page.search("//tr[3]/td/center/p[1]/a").empty?
        info = page.search("//tr[3]/td/center/a").attribute("href")
      else
        info = page.search("//tr[3]/td/center/p[1]/a").attribute("href")
      end
      #if info.empty?
      #  @concert.information = 'なし'
      #else
        @concert.information = info.to_s
      #end


      # 住所情報を表示
      hall_short_name = item[1].gsub(" ", "　").gsub("大", "　").gsub("小", "　").gsub("シンフォニー", "　").split("　")
      stage_name = hall_short_name[0].gsub("\n場所： ", "")

      @access = Access.new
      access_all = Access.where("hall_name = '#{stage_name}'")
      if access_all.empty?
        @concert.map = "なし"
        #@concert.information = "aaa"
        @access.train = "なし"
      else
        @concert.map = access_all[0].spot
        #@concert.information = access_all[0].spot
        @access.train = access_all[0].train
      end

      #
      @concert.month = scrape_page_month
      #@access.hall_name = "aaa"
      #@access.spot = "aaa"
      #@access.train = "aaa"

      #セーブする
      @concert.save
      #@infomation.save
      #driver.quit

      #タイトルに月の名前をあげたい
      #@access.train = scrape_page_month
    end

    @concerts = Concert.all
  end









  # Excelで出力(ユニークな楽団・ホール情報を取得するための仮処理)
  # （本番環境では使用しない。）
  def new
    # 一応とっとく########
    #@concert = Concert.new
    ######################
    @concerts = Concert.all
    month_name = @concerts[0].month

    Spreadsheet.client_encoding = "UTF-8"
    #いままでは予め用意したスプレッドシート使ってた。
    #book = Spreadsheet.open "/Users/inoueyuuta/yuta/einek_2/Einek/app/assets/excel/concert.xls"
    #一から作ってみよう
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    #sheet.name = 'sheet1'
    #sheet1 = book.worksheet 0

    #フォーマットを作る
    #タイトルはセルを結合して表示したい、何月かも分かるように
    #sheet1[0, 0] = "#{month_name}の挟み込みリスト"






    sheet1[1, 5] = 'その他'

    #演奏会情報を入力していく
    @concerts.each_with_index do |concert, i|
      i = i * 6

      sheet1[i, 0] = '演奏会名'
      sheet1[i, 1] = concert.name
      sheet1[i + 1, 0] = '日程'
      sheet1[i + 1, 1] = concert.program
      sheet1[i + 2, 0] = '会場'
      sheet1[i + 2, 1] = concert.stage
      sheet1[i + 2, 3] = '最寄り駅'
      sheet1[i + 2, 4] = concert.map
      sheet1[i + 3, 0] = '担当者'
      sheet1[i + 3, 1] = '' #ユーザーの自由記入欄
      sheet1[i + 4, 0] = 'その他'
      sheet1[i + 4, 1] = '' #ユーザーの自由記入欄

    end

    data = StringIO.new
    book.write data

    send_data(
      # tmpfile.read,
      data.string,
      #:disposition => 'attachment',
      :type => 'application/excel',
      :filename => "【2014年#{month_name}月】挟み込みリスト" + '.xls'
    )
  end

  # GET /concerts/1/edit
  def edit
  end

  # POST /concerts
  # POST /concerts.json
  def create
    @concert = Concert.new(concert_params)

    respond_to do |format|
      if @concert.save
        format.html { redirect_to @concert, notice: 'Concert was successfully created.' }
        format.json { render :show, status: :created, location: @concert }
      else
        format.html { render :new }
        format.json { render json: @concert.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /concerts/1
  # PATCH/PUT /concerts/1.json
  def update
    respond_to do |format|
      if @concert.update(concert_params)
        format.html { redirect_to @concert, notice: 'Concert was successfully updated.' }
        format.json { render :show, status: :ok, location: @concert }
      else
        format.html { render :edit }
        format.json { render json: @concert.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /concerts/1
  # DELETE /concerts/1.json
  def destroy
    @concert.destroy
    respond_to do |format|
      format.html { redirect_to concerts_url, notice: 'Concert was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_concert
    @concert = Concert.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def concert_params
    params.require(:concert).permit(:name, :program, :stage, :map, :information)
  end

  def delete_concert
    Concert.delete_all
  end

end
