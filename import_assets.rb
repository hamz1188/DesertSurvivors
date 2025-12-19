
require 'json'
require 'fileutils'

Dir.chdir('/Users/hameli/DesertSurvivors/DesertSurvivors/Assets.xcassets') do
  Dir.glob('*.png').each do |png_file|
    asset_name = File.basename(png_file, '.png')
    imageset_dir = "#{asset_name}.imageset"
    
    # Create directory
    FileUtils.mkdir_p(imageset_dir)
    
    # Move file
    FileUtils.mv(png_file, File.join(imageset_dir, png_file))
    
    # Create Contents.json
    contents = {
      "images" => [
        {
          "filename" => png_file,
          "idiom" => "universal",
          "scale" => "1x"
        },
        {
          "idiom" => "universal",
          "scale" => "2x"
        },
        {
          "idiom" => "universal",
          "scale" => "3x"
        }
      ],
      "info" => {
        "author" => "xcode",
        "version" => 1
      }
    }
    
    File.write(File.join(imageset_dir, "Contents.json"), JSON.pretty_generate(contents))
    puts "Processed #{asset_name}"
  end
end
