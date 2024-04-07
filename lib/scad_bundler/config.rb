require 'os'
require 'yaml'

module ScadBundler
  CONFIG_PATH = File.join(Dir.home, '.scad_bundler')

  class Config
    attr_accessor :openscad_library_path

    def self.default_openscad_library_path()
      # https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries#Library_locations
      if OS.windows?
        # My Documents\OpenSCAD\libraries
        return File.join(Dir.home, 'My Documents', 'OpenSCAD', 'libraries')
      elsif OS.linux?
        # ~/.local/share/OpenSCAD/libraries
        return File.join(Dir.home, '.local', 'share', 'OpenSCAD', 'libraries')
      elsif OS.mac?
        # ~/Documents/OpenSCAD/libraries
        return File.join(Dir.home, 'Documents', 'OpenSCAD', 'libraries')
      else
        return nil
      end
    end

    def initialize(openscad_library_path: Config.default_openscad_library_path)
      @openscad_library_path = openscad_library_path
    end

    def to_dict
      {
        'openscad_library_path' => @openscad_library_path
      }
    end

    def self.from_dict(dict)
      Config.new(
        openscad_library_path: dict['openscad_library_path']
      )
    end

    def self.load(path = CONFIG_PATH, create_if_missing: false)
      if File.exist?(path)
        return Config.from_dict(YAML.load_file(path))
      end
      if create_if_missing
        config = Config.new()
        config.save(path)
        return config
      end
      raise FileNotFoundError.new("No config file at #{path}")
    end

    def save(path = CONFIG_PATH)
      File.open(path, 'w') { |file| file.write(YAML.dump(self.to_dict)) }
    end
  end
end
