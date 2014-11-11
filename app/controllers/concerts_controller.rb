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
    #page_month = request.path_info.gsub("/concert/", "")
    if params[:page].blank?
      @access = Access.find(1)
      show_month = @access.spot
      show_year = @access.train
    else
      page_month = params[:page][:area].to_i

      case page_month
        #2014
        #when '2014/jan' then
      when 1 then
        show_month = 1
        show_year = 2014
      when '2014/feb' then
        show_month = 2
        show_year = 2014
      when '2014/mar' then
        show_month = 3
        show_year = 2014
      when '2014/apr' then
        show_month = 4
        show_year = 2014
      when '2014/may' then
        show_month = 5
        show_year = 2014
      when '2014/jun' then
        show_month = 6
        show_year = 2014
      when '2014/jul' then
        show_month = 7
        show_year = 2014
      when '2014/aug' then
        show_month = 8
        show_year = 2014
      when '2014/sep' then
        show_month = 9
        show_year = 2014
      when '2014/oct' then
        show_month = 10
        show_year = 2014
      when '2014/nov' then
        show_month = 11
        show_year = 2014
      when '2014/dec' then
        show_month = 12
        show_year = 2014
        #2015
      when '2015/jan' then
        show_month = 1
        show_year = 2015
      when '2015/feb' then
        show_month = 2
        show_year = 2015
      when '2015/mar' then
        show_month = 3
        show_year = 2015
      when '2015/apr' then
        show_month = 4
        show_year = 2015
      when '2015/may' then
        show_month = 5
        show_year = 2015
      when '2015/jun' then
        show_month = 6
        show_year = 2015
      when '2015/jul' then
        show_month = 7
        show_year = 2015
      when '2015/aug' then
        show_month = 8
        show_year = 2015
      when '2015/sep' then
        show_month = 9
        show_year = 2015
      when '2015/oct' then
        show_month = 10
        show_year = 2015
      when '2015/nov' then
        show_month = 11
        show_year = 2015
      when '2015/dec' then
        show_month = 12
        show_year = 2015
      end
    end

    # 日が複数選択されてたら、配列に入れたいなぁ
    day_list = "ooo"
    if params[:show_page_day].nil?
    else
      params[:show_page_day].each do |x|
        day_list = day_list + params[:show_page_day][:day]
        #  day_list = day_list + x.to_s
      end
    end


    #でばっぐ
    # show_month = 1
    # show_year = 2014

    # 日があったら日検索つける
    if params[:show_page_day].nil?
      day_count = 0
    else
      day_count = params[:show_page_day][:day].to_i
    end

    if day_count == 0
      @concerts = Concert.where(month: show_month, year: show_year)
    else
      show_day = params[:show_page_day][:day]
      @concerts = Concert.where(month: show_month, year: show_year, day: show_day)
    end

    #viewに全日のボタンを渡す
    @concerts_day_all = Concert.where(month: show_month, year: show_year)

    #日付検索をしても、月の値を保持
    #    if @access.nil?
    #    #else
    #      show_month = @access.spot
    #      show_year = @access.train
    #    end
    #このページが何月か保持しておく（newでurlが変わらないのでlink_toで値が渡せないため）
    #Access.destroy_all

    # find(1)が存在しないとエラーになる問題も解決したい
    @access = Access.find(1)


    # if @access.blank?
    #  @access = Access.new
    # else
    # @access = Access.find(1)
    # end
    #@access = Access.new(id: 1)
    #@access = Access.update_all( "spot = #{show_month}", "train = #{show_year}" )
    # show_month = 1
    # show_year = 2014
    @access.spot = show_month
    @access.train = show_year
    #ユニークな日情報を渡したい
    # uniq_day = []
    # @concerts.each do |concert|
    #   uniq_day.push(concert.day)
    # end
    # uniq_day.uniq
    # @access.hall_name = uniq_day
    @access.save!
    @access = Access.find(1)
  end


  def new

    #表示する月を選ぶ
    @access = Access.find(1)
    xxx = @access.spot
    @concerts = Concert.where(month: xxx)
    month_name = xxx

    #excelファイルを作成
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    #演奏会情報を入力していく
    @concerts.each_with_index do |concert, i|
      i = i * 8
      sheet1[i, 0] = '演奏会名'
      sheet1[i, 1] = concert.name
      sheet1[i + 1, 0] = '日程'
      sheet1[i + 1, 1] = concert.program
      sheet1[i + 2, 0] = '会場'
      sheet1[i + 2, 1] = concert.stage
      sheet1[i + 3, 0] = '最寄り駅'
      sheet1[i + 3, 1] = ''
      sheet1[i + 4, 0] = '楽団HP'
      sheet1[i + 4, 1] = concert.information
      sheet1[i + 5, 0] = '担当者'
      sheet1[i + 5, 1] = '' #ユーザーの自由記入欄
      sheet1[i + 6, 0] = '備考'
      sheet1[i + 6, 1] = '' #ユーザーの自由記入欄
    end

    data = StringIO.new
    book.write data

    send_data(
    data.string,
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
