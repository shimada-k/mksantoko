#!/usr/bin/ruby

require 'open-uri'
require 'nokogiri'
require 'fileutils'

class Mksantoko

    NUM_PAGE    = 67
    BASE_URL    = "http://www.welluneednt.com/archive/category/%E8%AA%AD%E8%80%85%E2%86%94%E6%9D%91%E4%B8%8A%E6%98%A5%E6%A8%B9"
    DATA_DIR    = "./data"

    def initialize()
        # mdの保存先を確保する
        FileUtils.rm_rf(DATA_DIR)
        FileUtils.mkdir_p(DATA_DIR)
    end

    # URLから日付を取得してディレクトリを掘る
    def makeDateDir(url)
        url.split("/")
        parts = url.split("/")
        dir = parts[4] + "-" + parts[5] + "-" + parts[6]

        path = DATA_DIR + "/" + dir

        unless File.exists?(path) then
            FileUtils.mkdir_p(path)
        end
        return path
    end

    # 文字列をファイルシステム上保存可能な文字列に変換する
    def toValidName(name)
        return name.gsub(/\//, "／")
    end

    # ページを探索して情報を取得する
    def clawlPage()
        for page in 1..NUM_PAGE do
            indexUrl = BASE_URL  + "?page=" + page.to_s
            
            charset = nil
            indexHtml = open(indexUrl) do |f|
                charset = f.charset
                f.read
            end
            
            indexDoc = Nokogiri::HTML.parse(indexHtml, nil, charset)
            
            indexDoc.xpath('//h1[@class="entry-title"]').each do |entryTitle|
                # 個別ページのURLを取得
                letterUrl = entryTitle.xpath('a').attribute("href").value

                path = self.makeDateDir(letterUrl)
            
                # 個別ページに移動
                charset = nil
                letterHtml = open(letterUrl) do |f|
                    charset = f.charset
                    f.read
                end

                letterDoc = Nokogiri::HTML.parse(letterHtml, nil, charset)
            
                entryName = ""
                letterDoc.xpath('//h1[@class="entry-title"]').each do |titleName|
                    entryName = titleName.xpath('a').text
                end

                # 文字列を洗浄する
                entryName = self.toValidName(entryName)
            
                letterText = ""
                replyText = ""
                letterDoc.xpath('//div[@class="entry-content"]').each do |entryContent|
                    letterText = entryContent.xpath('//blockquote')[0].text
                    replyText = entryContent.xpath('//blockquote')[1].text
                end
       
                pathName = path + "/" + entryName + ".md"
                p pathName

                # mdで保存する
                file = open(pathName ,"w")
                file.puts("#### " + entryName + "\n\n" + letterText.strip + "\n\n" + "------------\n\n" + replyText.strip)
                file.close
            end
        end
    end
end

mk = Mksantoko.new()
mk.clawlPage()


