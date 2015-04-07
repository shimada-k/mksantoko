# URLにアクセスするためのライブラリの読み込み
require 'open-uri'
# Nokogiriライブラリの読み込み
require 'nokogiri'

NUM_PAGE= 53

for page in 1..NUM_PAGE do
    indexUrl = 'http://www.welluneednt.com/archive/category/%E8%AA%AD%E8%80%85%E2%86%94%E6%9D%91%E4%B8%8A%E6%98%A5%E6%A8%B9?page=' + page.to_s
    
    charset = nil
    indexHtml = open(indexUrl) do |f|
        charset = f.charset
        f.read
    end
    
    indexDoc = Nokogiri::HTML.parse(indexHtml, nil, charset)
    
    indexDoc.xpath('//h1[@class="entry-title"]').each do |entryTitle|
        #title
        letterUrl = entryTitle.xpath('a').attribute("href").value
    
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
    
        letterText = ""
        replyText = ""
        # replySign = ""
        letterDoc.xpath('//div[@class="entry-content"]').each do |entryContent|
            letterText = entryContent.xpath('//blockquote')[0].text
            replyText = entryContent.xpath('//blockquote')[1].text
            # 3番目のp要素は村上さんの署名だと信じる
            #replySign = entryContent.xpath('//blockquote')[2].text
        end
    
        # mdで保存する
        file = open(entryName + ".md" ,"w")
        file.puts("#### " + entryName + "\n\n" + letterText.strip + "\n\n" + "------------\n\n" + replyText.strip)
        file.close
    
    end
end

