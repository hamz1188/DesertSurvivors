
require 'xcodeproj'

project_path = 'DesertSurvivors.xcodeproj'
project = Xcodeproj::Project.open(project_path)

files_to_check = [
  'PauseMenuUI.swift',
  'CharacterSelectionScene.swift'
]

targets = project.targets.select { |t| t.name == 'DesertSurvivors' }

targets.each do |target|
  files_to_check.each do |filename|
    # Find all build file references for this file
    build_files = target.source_build_phase.files.select { |bf| bf.file_ref.name == filename || bf.file_ref.path.end_with?(filename) }
    
    if build_files.count > 1
      puts "Found #{build_files.count} references for #{filename}. Removing duplicates..."
      
      # Keep the first one, remove the rest
      build_files[1..-1].each do |bf|
        target.source_build_phase.remove_build_file(bf)
        puts "  Removed duplicate build reference."
      end
    else
      puts "#{filename}: No duplicates found (count: #{build_files.count})"
    end
  end
end

project.save
puts "Project file clean complete."
