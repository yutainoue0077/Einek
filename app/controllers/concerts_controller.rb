class ConcertsController < ApplicationController
  before_action :set_concert, only: [:edit, :update, :destroy]
  require 'rubygems'
  require 'mechanize'
  require 'spreadsheet'
  require 'stringio'

  # GET /concerts
  # GET /concerts.json
  def index
    @concerts = Concert.all
    #ラジオボタンテスト
    #@concert = Concert.find(1)
    #@concert.name = [:page][:area]
  end

  # 一月分の演奏会を表示。
  def show
    #表示する年月を選ぶ
    page_month = request.path_info.gsub("/concert/", "").split("/")
    show_year  = page_month[0]
    show_month = page_month[1]

    @concerts = Concert.where(month: show_month).where(year: show_year)
  end


  def new
    #表示する月を選ぶ
    @concerts = Concert.where(year: params[:year], month: params[:month])
    month_name = params[:month]
    year_name = params[:year]

    #excelファイルを作成
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet



    #演奏会情報を入力していく
    @concerts.each_with_index do |concert, i|

      #配列で保存していた名前を連結する
      name_join = ""
      concert.name.each do |name|
        name_join = name_join + name
      end

      program_join = ""
      concert.program.each do |program|
        program_join = program_join + program
      end

      content_join = ""
      concert.content.each do |content|
        content_join = content_join + content
      end

      i = i * 8
      sheet1[i, 0] = '演奏会名'
      sheet1[i, 1] = name_join
      sheet1[i + 1, 0] = '日程'
      sheet1[i + 1, 1] = program_join
      sheet1[i + 2, 0] = '会場'
      sheet1[i + 2, 1] = concert.stage
      sheet1[i + 3, 0] = '最寄り駅'
      sheet1[i + 3, 1] = concert.station
      sheet1[i + 4, 0] = '楽団HP'
      sheet1[i + 4, 1] = concert.information
      sheet1[i + 5, 0] = '曲目'
      sheet1[i + 5, 1] = content_join
      sheet1[i + 6, 0] = '備考'
      sheet1[i + 6, 1] = '' #ユーザーの自由記入欄
    end

    data = StringIO.new
    book.write data

    send_data(
    data.string,
    :type => 'application/excel',
    :filename => "【#{year_name}年#{month_name}月】挟み込みリスト" + '.xls'
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
