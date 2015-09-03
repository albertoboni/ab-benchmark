require 'pp'
require 'csv'


csv_folder_path = File.expand_path '../csv', File.dirname(__FILE__)

Dir.new(csv_folder_path).each do |folder|
  next if %w(.. .).include? folder.to_s

  source_path = File.join(csv_folder_path, folder.to_s)
  next if File.file? source_path

  file_name = "#{folder.to_s}.csv"
  next if File.exist? "#{csv_folder_path}/#{file_name}"



  # get all the files with full paths
  files = Dir.new(source_path).entries.delete_if { |entry| %w(.. .).include? entry }

  data = [].each
  file_paths = files.map { |file| File.join(source_path, file) }



  # create the first column
  compiled_data = []

  CSV.read(file_paths[0]).each { |line| compiled_data << [line[0]] }

  data = file_paths.map do |file_path|
    CSV.read(file_path).map.with_index do |line, i|
      i == 0 ? file_path.split('/').last.gsub(/(\.csv|\.(NO)?CACHE)/, '') : line[1]
    end
  end

  # consolidate first column with data
  csv_string = CSV.generate do |csv|
    data.first.each_index do |line|
      csv << ( compiled_data[line] + data.map { |entry| entry[line] } )
    end
  end


  # save file
  File.open(File.join(csv_folder_path, file_name), 'w') { |file| file.write(csv_string) }

end

