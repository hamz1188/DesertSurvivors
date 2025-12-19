
require 'xcodeproj'

project_path = 'DesertSurvivors.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

files_to_fix = {
  'PauseMenuUI.swift' => 'DesertSurvivors/UI',
  'CharacterSelectionScene.swift' => 'DesertSurvivors/Scenes'
}

files_to_fix.each do |filename, group_path|
  puts "Fixing #{filename}..."
  
  # 1. Remove ALL build file references from the target
  target.source_build_phase.files.to_a.each do |bf|
    if bf.file_ref && bf.file_ref.name == filename
      puts "  Removing build file reference..."
      target.source_build_phase.remove_build_file(bf)
    end
  end

  # 2. Find the file reference in the group hierarchy
  group = project.main_group
  group_path.split('/').each { |dir| group = group[dir] }
  file_ref = group.files.find { |f| f.name == filename || f.path == filename }

  # 3. Add it back ONCE
  if file_ref
    puts "  Adding clean build file reference..."
    target.add_file_references([file_ref])
  else
    puts "  Error: Could not find file reference for #{filename} in #{group_path}"
  end
end

project.save
puts "Done."
