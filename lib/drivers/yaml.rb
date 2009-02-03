require 'yaml'
require 'extensions/io'
class Filebase

  class YAML

    def initialize( root )
      @root = root.to_s
    end

    def path( key )
      File.join( @root, key.to_s ) + '.yml'
    end

    def all
      Dir[ path('*') ].map { |file| find( File.basename(file,'.yml' ) ) }.compact
    end

    def find( key )
      obj = ::YAML.load( File.read( path( key ) ) ) rescue nil
      obj['key'] = key if Hash === obj
      obj or nil # convert false to nil
    end

    def save( key, object )
      #Hack to save uploaded files before serialization.
      object.each do |k, v|
        if((v.class == Hash) and (v[:tempfile].class == Tempfile))
          dirpath = File.join instance_variable_get('@root'), 'files'
          ::FileUtils.mkdir_p(filepath) unless File.exists?(dirpath)
          filepath = File.join dirpath, key
          ::FileUtils.mv(v[:tempfile].path, filepath, :force => true)
          object['filepath']  =  filepath
        end

      end

      File.write( path( key ), object.to_yaml ) and object
    end

    def delete( key )
      FileUtils.remove( path( key ) )
    end

  end

end
