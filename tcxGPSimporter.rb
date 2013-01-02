# read single .tcx file 
def readTcxFile(filepath)
  currentRun = Hash.new
  File.open(filepath) do |f|
    f.each_line() do |line|
  
      if (/<TotalTimeSeconds>/ =~ line)
        numbers = line.scan(/\d+/)
        currentRun[:duration] = numbers.first
      end
  
      if (/<DistanceMeters>/ =~ line && !currentRun.has_key?(:distance))
        numbers = line.scan(/\d+/)
        currentRun[:distance] = numbers.first
      end
    
      if (/<Id>/ =~ line)
        # remove <Id> and </Id> tags, trailing .000Z and white spaces from id string
        currentRun[:id] =  line.to_s.gsub!(/<\/?Id>/,'').gsub(/.000Z/,'').strip!
        numbers = line.scan(/\d+/)
        currentRun[:year] = numbers[0]
        currentRun[:month] = numbers[1]
        currentRun[:day] = numbers[2]
      end
    end
  end
  # convert time stamp to weekday: 1,2,3... = monday, tuesday, wednesday...
  currentRun[:weekday] = (Time.new(currentRun[:year],currentRun[:month],currentRun[:day]).wday+6).modulo(7)+1
  return currentRun
end

# import multiple tcx files from folder path into run stream collection
def importTcxFolder(folderpath)
  runs = []
    Dir.foreach(folderpath) do |filename|
      if( /.tcx/ =~ filename)
        currentRun = readTcxFile(File.join(folderpath,filename))
        runs.push(currentRun)
      end
    end
  return runs  
end

# print run data collection 
def printRunStream(stream)
  stream.each do |currentRun|
    puts "Weekday: #{currentRun[:weekday]}  Duration: #{currentRun[:duration]}s Distance: #{currentRun[:distance]}m"
  end
end

# export run data collection to ASCII file 
def exportRunStream(stream,filepath)
  savestring = "";
  stream.each do |currentRun|
    savestring = savestring + "#{currentRun[:weekday]} #{currentRun[:duration]} #{currentRun[:distance]} \n"
  end
File.open(filepath, 'w') {|f| f.write(savestring)}
end

# import and export 2012 runs
if __FILE__ == $0
  runs = importTcxFolder('/Users/tobi/Dropbox/MyRuns/2012')
  printRunStream(runs)
  exportRunStream(runs,'/Users/tobi/Desktop/myRuns.dat')
end