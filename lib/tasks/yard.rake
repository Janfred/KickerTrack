YARD::Rake::YardocTask.new do |t|
 t.files   = ['lib/**/*.rb', 'app/**/*.rb']   # optional
 #t.options = ['--any', '--extra', '--opts'] # optional
 t.options = ['--private']
 t.stats_options = ['--list-undoc']         # optional
end
