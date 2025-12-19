require 'fileutils'
require 'json'

project_path = "/Users/hameli/DesertSurvivors/DesertSurvivors/Assets.xcassets"
icon_set_path = File.join(project_path, "AppIcon.appiconset")
source_icon = File.join(project_path, "app_icon.png")

# Create directory
FileUtils.mkdir_p(icon_set_path)

# Copy icon to destination
dest_icon = File.join(icon_set_path, "icon_1024.png")
FileUtils.cp(source_icon, dest_icon)

# Create Contents.json
contents = {
  "images" => [
    {
      "size" => "1024x1024",
      "idiom" => "ios-marketing",
      "filename" => "icon_1024.png",
      "scale" => "1x"
    },
    {
      "size" => "1024x1024",
      "idiom" => "universal",
      "platform" => "ios",
      "filename" => "icon_1024.png"
    }
  ],
  "info" => {
    "version" => 1,
    "author" => "xcode"
  }
}

File.write(File.join(icon_set_path, "Contents.json"), JSON.pretty_generate(contents))

puts "AppIcon configured successfully."
