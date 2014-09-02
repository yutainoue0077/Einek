class ConcertsController < ApplicationController
  before_action :set_concert, only: [:show, :edit, :update, :destroy]
  require "Nokogiri"
  require "open-uri"
  # GET /concerts
  # GET /concerts.json
  def index
    @concerts = Concert.all
  end

  # GET /concerts/1
  # GET /concerts/1.json
  def show
    url = "http://www2s.biglobe.ne.jp/~jim/freude/201410/masuo1410.html"
    doc = Nokogiri.HTML(open(url))
    item = Array.new(10)

    # 演奏会タイトルの取得
    main_title = doc.xpath('//tr/td/b').text.gsub("　", "")
    sub_title = doc.xpath('//tr/td/p/b').text.gsub("　", "")
    full_title = "#{main_title}【#{sub_title}】"
    @concert.name = full_title

    # 日時・場所・を取得
    doc.xpath('//blockquote/p').each_with_index do |node, i|
      item[i] = node.text
    end
    @concert.program = item[0]
    @concert.stage = item[1]

    # 演奏曲目を連結表示
    content = ""
    doc.xpath('//dd/b').each_with_index do |node, i|
      content = content + node.text + "\n"
    end
    @concert.map = content
    # @concert.information = item[1]
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
