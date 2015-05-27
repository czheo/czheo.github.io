desc "start jekyll server"
task :server do
    sh "jekyll server -w --drafts"
end

desc "publish a draft"
task :publish, :draft do |t, args|
    draft = args[:draft]
    if draft
        draft_name = File.basename(draft)
        draft_path = File.join("_drafts", draft_name)
        if File.exist? draft_path
            # mv _drafts/ to _posts/
            date_string = Time.now.strftime "%Y-%m-%d"
            post_file = "#{date_string}-#{draft_name}"
            post_path = File.join("_posts", post_file)
            sh "mv #{draft_path} #{post_path}"
        else
            puts "#{draft_path} not found"
        end
    else
        sh "rake -T"
    end
end
