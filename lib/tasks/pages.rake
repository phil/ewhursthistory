namespace :pages do
  desc "Calls #save on all pages"
   task :save => :environment do
     Page.all.each &:save
   end
end
