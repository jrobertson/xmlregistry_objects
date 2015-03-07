#!/usr/bin/env ruby

# file: xmlregistry_objects.rb


require 'polyrex'
require 'dws-registry'


class XMLRegistryObjects

  attr_reader :to_h

  def initialize(reg, polyrexdoc)
        
    @to_h = polyrexdoc.records.inject({}) do |rtn, row|

      name, path = row.name, row.regkey[1..-2]
      class_name = name.capitalize
      klass = Object.const_set(class_name,Class.new)

      s = "
        def initialize(reg)
          @reg = reg
        end
      "

      s = if row.records.any? then

        row.records.inject(s) do |r, attr|
          
          attr_name, subkey = attr.name, attr.subkeyname
          
          r << make_def(path, subkey, attr_name)

        end

      else

        names = reg.xpath("#{path}/*/name()")
        
        names.inject(s) do |r, subkey| 
          r << make_def(path, subkey)
        end
      end

      klass.class_eval s
      rtn.merge name.to_sym => klass.new(reg)

    end
  end
  
  def define_methods()
    @to_h.each.map {|k,v| "define_method :#{k.to_s}, ->{h[:#{k}]}"}.join("\n")
  end

  private

  def make_def(path, subkey, method_name=subkey)
"
    def #{method_name}      
      @reg.get_key('#{[path, subkey].join('/')}')
    end
"
  end

end