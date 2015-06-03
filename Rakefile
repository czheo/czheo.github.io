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

desc "create a draft"
task :draft, :name do |t, args|
    name = args[:name]
    filename = name.downcase.gsub(/\s+/, "-") + ".md"
    path = "_drafts/#{filename}"
    template = %{---
layout: post
title: #{name}
author: czheo
---}
    if File.exist? path
        puts "#{path} already exists"
    else
        File.open(path, "w") do |file|
            file.write(template)
        end
        puts "created #{path}"
    end
end
