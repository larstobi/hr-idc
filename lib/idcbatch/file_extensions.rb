class File
    def self.readfile(filename)
        data = ''
        File.readlines(filename).each do |line|
            data << line
        end
        data
    end
end
