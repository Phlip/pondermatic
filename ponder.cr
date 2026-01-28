
class Corp
  property filename : String
  property body : String

  def initialize(@filename : String, @body : String)
  end

  def self.parseFolder(path : String) : Array(Corp)
    results = [] of Corp

    Dir.glob("#{path}/*.txt").each do |file|
      next unless File.file?(file)
      content = File.read(file)
      results << Corp.new(file, content)
    end

    results.sort_by! { |c| File.basename(c.filename) }
    return results
  end
end
