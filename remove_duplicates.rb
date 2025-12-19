
require 'xcodeproj'

project_path = 'DesertSurvivors.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Just remove the explicit references from the build phase.
# If they are in a synced group, Xcode will include them automatically (or has them duplicated).
# If the warning says "duplicate", it means there are two instructions to compile the same file.
# One might be from the sync group, one from an explicit add.
# Removing the explicit one should fix it.

files_to_remove = [
  'PauseMenuUI.swift',
  'CharacterSelectionScene.swift'
]

files_to_remove.each do |filename|
  puts "Checking #{filename}..."
  
  # Remove ALL explicit build file references
  removed_count = 0
  target.source_build_phase.files.to_a.each do |bf|
    # Check if the file name matches
    if bf.file_ref && (bf.file_ref.name == filename || bf.file_ref.path.end_with?(filename))
      puts "  Removing explicit build reference..."
      target.source_build_phase.remove_build_file(bf)
      removed_count += 1
    end
  end
  puts "  Removed #{removed_count} references."
end

project.save
puts "Saved project."
