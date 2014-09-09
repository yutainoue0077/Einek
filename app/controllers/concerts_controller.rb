class ConcertsController < ApplicationController
  before_action :set_concert, only: [:show, :edit, :update, :destroy]
  require 'Nokogiri'
  require 'open-uri'
  require 'selenium-webdriver'
  require 'rubygems'
  require 'mechanize'

  # GET /concerts
  # GET /concerts.json
  def index
    @concerts = Concert.all
    @accesss = Access.all
  end


  # GET /concerts/1
  # GET /concerts/1.json
  def show
    1.times do |i|
@concert = Concert.new
agent = Mechanize.new
page = agent.get('http://www2s.biglobe.ne.jp/~jim/freude/calendar/2014nov.html')
link = page.links[25]
@concert.program = link.href.gsub("..", "http://www2s.biglobe.ne.jp/~jim/freude")


      driver = Selenium::WebDriver.for :safari
      driver.navigate.to "http://www2s.biglobe.ne.jp/~jim/freude/calendar/2014oct.html"
      driver.find_element(:xpath,  "/html/body/center/table/tbody/tr/td[2]/table/tbody/tr[1]/td/table[2]/tbody/tr[5]/td[2]/a[#{i + 1}]").click
      #driver.find_element(:xpath, /html/body/center/table/tbody/tr/td[2]/table/tbody/tr[1]/td/table[2]/tbody/tr[2]/td[2]/a[1]').click


      html = driver.page_source
      doc = Nokogiri.HTML(html)
      item = Array.new(10)

      # 演奏会タイトルの取得
      main_title = doc.xpath('/html/body/center/table/tbody/tr[1]/td/b/font').text.gsub("　", "")
      sub_title = doc.xpath('/html/body/center/table/tbody/tr[1]/td/p/b/font').text.gsub("　", "")
      full_title = "#{main_title}【#{sub_title}】"
      if full_title.nil?
        @concert.name = "なし"
      else
        @concert.name = full_title
      end

      # 日時・場所・を取得
      doc.xpath('/html/body/center/table/tbody/tr[3]/td/blockquote/p').each_with_index do |node, i|
        item[i] = node.text
      end
      item_0 = item[0]

      #sss = driver.find_elements(:class, //table[contains(@class, 'lin5')])

      #if item_0.nil?
      #  @concert.program = "なし"
      #else
      #  @concert.program = item[0]
      #end

      #場所情報をホール名のみに変更
      #hall_short_name = item[1].split("　")
      #stage_name = hall_short_name[0].gsub("\n場所： ", "")
      #@concert.stage = stage_name

      # 演奏曲目を連結表示
      content_all = ""
      doc.xpath('//dd/b').each_with_index do |node, i|
        content_all = content_all + node.text + "\n"
      end
      if content_all.nil?
        @concert.content = "なし"
      else
        @concert.content = content_all
      end

      @concert.save
      # お問い合わせ先を表示
      @infomation = Infomation.new
      #info_all = Infomation.where("oke_name = '#{main_title}'")
      #@infomation.info = info_all[0].info


      # 住所情報を表示
      @access = Access.new
      #access_all = Access.where("hall_name = '#{stage_name}'")
      #@access.hall_name = access_all[0].hall_name
      #@access.spot = access_all[0].spot
      #@access.train = access_all[0].train

      # デバック用
      @infomation.info = "aaa"
      @access.hall_name = "aaa"
      @access.spot = "aaa"
      @access.train = "aaa"

      driver.quit
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
end
