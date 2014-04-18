require './fakeit'

desc "Generate blog files"
namespace :generate do
  task :data, :num do |t, args|
    args.with_defaults(num: 3500)
    puts make_data_file(args.num.to_i)
  end

  task :json do
    puts make_json_file
  end

  task :tamped do
    puts make_tamped_json
  end

  task :pages do
    puts make_basic_page
    puts make_list_page
    puts make_datatables_page
    puts make_tamper_page
  end
end


# bakes everything (besides data)
task :bake do
  Rake::Task["generate:json"].invoke
  Rake::Task["generate:tamped"].invoke
  Rake::Task["generate:pages"].invoke
end

desc 'Generate and publish blog to gh-pages'
task :publish do
  system "git push origin master:gh-pages"
end
