require './fakeit'

desc "Generate blog files"
namespace :generate do
  task :data do
    puts make_data_file
  end

  task :json do
    puts make_json_file
  end

  task :tamped do
    puts make_tamped_json
  end

  task :pages do
    puts make_page
  end

end



desc 'Generate and publish blog to gh-pages'
task :publish do

  system "git push origin gh-pages --force"
end
