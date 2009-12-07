# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{zombie-chaser}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew Grimm", "Ryan Davis", "Eric Hodel", "Kevin Clark"]
  s.date = %q{2009-12-08}
  s.default_executable = %q{zombie-chaser}
  s.description = %q{A zombie-themed graphic(al) user interface for mutation testing}
  s.email = %q{andrew.j.grimm@gmail.com}
  s.executables = ["zombie-chaser"]
  s.extra_rdoc_files = [
    "README.txt"
  ]
  s.files = [
    "README.txt",
     "Rakefile",
     "bin/zombie-chaser",
     "lib/chaser.rb",
     "lib/human.rb",
     "lib/interface.rb",
     "lib/test_unit_handler.rb",
     "lib/world.rb",
     "lib/zombie_test_chaser.rb",
     "test/fixtures/chased.rb",
     "test/test_chaser.rb",
     "test/test_unit.rb",
     "test/test_zombie.rb",
     "ui/icons/death.png",
     "ui/icons/robot.png",
     "ui/sprites/robot-attacking.png",
     "ui/sprites/robot-dead.png",
     "ui/sprites/robot-dying.png",
     "ui/sprites/robot-idle.png",
     "ui/sprites/robot-moving.png",
     "ui/sprites/robot-turning.png",
     "ui/sprites/tank-attacking.png",
     "ui/sprites/tank-dead.png",
     "ui/sprites/tank-idle.png",
     "ui/sprites/tank-moving.png",
     "ui/sprites/tank-turning.png",
     "ui/sprites/witch-attacking.png",
     "ui/sprites/witch-dead.png",
     "ui/sprites/witch-idle.png",
     "ui/sprites/witch-moving.png",
     "ui/sprites/witch-turning.png",
     "ui/sprites/zombie-attacking.png",
     "ui/sprites/zombie-dead.png",
     "ui/sprites/zombie-dying.png",
     "ui/sprites/zombie-idle.png",
     "ui/sprites/zombie-moving.png",
     "ui/sprites/zombie-turning.png",
     "ui/tiles/grass.png",
     "ui/tiles/shrubbery.png",
     "ui/ui.rb",
     "zombie-chaser.gemspec"
  ]
  s.homepage = %q{http://andrewjgrimm.wordpress.com/2009/11/08/declare-war-on-everything-with-chaser/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Lightweight mutation testing ... with ZOMBIES!!!}
  s.test_files = [
    "test/fixtures/chased.rb",
     "test/test_chaser.rb",
     "test/test_unit.rb",
     "test/test_zombie.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gosu>, [">= 0"])
    else
      s.add_dependency(%q<gosu>, [">= 0"])
    end
  else
    s.add_dependency(%q<gosu>, [">= 0"])
  end
end

