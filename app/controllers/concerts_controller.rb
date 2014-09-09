class ConcertsController < ApplicationController
  before_action :set_concert, only: [:edit, :update, :destroy]
  before_action :delete_concert, only: [:show]
  #require 'Nokogiri'
  #require 'open-uri'
  #require 'selenium-webdriver'
  require 'rubygems'
  require 'mechanize'

  # GET /concerts
  # GET /concerts.json
  def index
    @concerts = Concert.all
    @accesss = Access.all
    @infomation = Infomation.all
  end


  # GET /concerts/1
  # GET /concerts/1.json
  def show

    scrape_page_so = request.path_info.gsub("/concert/", "")
    scrape_page = scrape_page_so.to_s.gsub("jan", "http://www2s.biglobe.ne.jp/~jim/freude/calendar/2014jan.html")

    #演奏会リンクは[16]から、16+1=17を総リンク数から引いた回数ループ
    agent = Mechanize.new
    page = agent.get('http://www2s.biglobe.ne.jp/~jim/freude/calendar/2014dec.html')
    concert_links_count = page.links.count - 17

    #ほんとはconcert_links_countで回す
    concert_links_count.times do |i|
      @concert = Concert.new
      page = agent.get('http://www2s.biglobe.ne.jp/~jim/freude/calendar/2014dec.html')
      link = page.links[i + 16]
      link_url   = link.href.gsub("..", "http://www2s.biglobe.ne.jp/~jim/freude")

      page = agent.get(link_url)
      doc = Nokogiri::HTML(link_url)
      item = Array.new(10)

      # 演奏会タイトルの取得
      main_title = ""
      main_title = page.search('//tr[1]/td/b/font').text.gsub("　", "")
      sub_title = page.search('//tr[1]/td/p/b/font').text.gsub("　", "")
      full_title = "#{main_title}【#{sub_title}】"
      if full_title.nil?
        @concert.name = "なし"
      else
        @concert.name = full_title
      end

      # 日時・場所・を取得
      page.search('//tr[3]/td/blockquote/p').each_with_index do |node, i|
        item[i] = node.text
      end
      item_0 = item[0]
      if item_0.nil?
        @concert.program = "なし"
      else
        @concert.program = item[0]
      end

      #場所情報をホール名のみに変更
      hall_short_name = item[1].split("　")
      stage_name = hall_short_name[0].gsub("\n場所： ", "")
      stage_hull_name = item[1].to_s.gsub("\n場所： ", "")
      if stage_hull_name.empty?
        @concert.stage = 'なし'
      else
        @concert.stage = stage_hull_name
      end

      # 演奏曲目を連結表示
      content_all = ""
      page.search('//dd/b').each_with_index do |node, i|
        content_all = content_all + node.text + "\n"
      end
      if content_all.nil?
        @concert.content = "なし"
      else
        @concert.content = content_all
      end

      # お問い合わせ先を表示
      @infomation = Infomation.new
      info_all = Infomation.where("oke_name = '#{main_title}'")
      if info_all.empty?
        @concert.information = "なし"
      else
        @concert.information = info_all[0].info
      end


      # 住所情報を表示
      @access = Access.new
      access_all = Access.where("hall_name = '#{stage_name}'")
      if access_all.empty?
        @concert.map = "#{scrape_page}"
        #@concert.information = "aaa"
        @access.train = "なし"
      else
        @concert.map = access_all[0].spot
        #@concert.information = access_all[0].spot
        @access.train = access_all[0].train
      end

      # デバック用
      @infomation.info = "なし"
      #@access.hall_name = "aaa"
      #@access.spot = "aaa"
      #@access.train = "aaa"

      #セーブする
      @concert.save
      #driver.quit
    end

    @concerts = Concert.all
  end









  # GET /concerts/new
  def new
    @concert = Concert.new
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
