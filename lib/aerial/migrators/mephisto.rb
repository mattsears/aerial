module Aerial
  module Mephisto
    ARTICLES = "SELECT id, user_id, title, permalink, body, published_at FROM contents
                WHERE  type = 'Article' ORDER BY published_at DESC"
    TAGS     = "SELECT tags.name FROM tags
                INNER join taggings on tags.id = taggings.tag_id where taggable_id = "
    USERS    = "SELECT login from users where users.id = "

    def self.import(dbname, user, pass, host = 'localhost')
      db = Sequel.mysql(dbname, :user => user, :password => pass, :host => host, :encoding => 'utf8')
      FileUtils.mkdir_p File.join(Aerial.root, Aerial.config.articles.dir)
      db[ARTICLES].each do |post|
        date = post[:published_at].to_time
        slug = post[:permalink]
        path = File.join(Aerial.root, Aerial.config.articles.dir, "#{date.strftime("%Y-%m-%d")}-#{slug}")
        tags = db[TAGS + post[:id].to_s].map(:name).join(',')
        user = db[USERS + post[:user_id].to_s].map(:login).join(',')
        body = McBean.fragment(post[:body].gsub("\r\n", "\n").gsub(/<[^>]*$/, "")).to_markdown.strip
        FileUtils.mkdir_p(path)
        File.open("#{path}/#{slug}.article", "w") do |f|
          f.puts "Title        : #{post[:title]}"
          f.puts "Tags         : #{tags}"
          f.puts "Publish Date : #{date.strftime("%Y-%m-%d %H:%M:%S")}"
          f.puts "Author       : #{user}"
          f.puts ""
          f.puts body
        end
      end
    end

  end
end
