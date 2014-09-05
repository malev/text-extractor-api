require 'tmpdir'
require 'docsplit'


class TextExtractor
  def initialize(tempfile)
    @tempfile = tempfile
  end

  def call
    @call ||= Dir.mktmpdir do |temp_dir|
      Docsplit.extract_text(@tempfile, output: temp_dir)
      File.open(File.join(temp_dir, temp_txt_path)).read
    end
  end

  def temp_txt_path
    File.basename(@tempfile, '.*') + '.txt'
  end
end
