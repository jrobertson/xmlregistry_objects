#!/usr/bin/env ruby

# file: xmlregistry_objects.rb


require 'lineparser'
require 'xml-registry'


class XMLRegistryObjects


  attr_reader :to_h


  def initialize(reg, list)

    patterns = [
      [:root, /(\w+)\s+=\s+\[([^\]]+)\]/, :object],  
        [:object, /([\w\?]+)\s+=\s+(.*)/, :attribute]
    ]

    lp = LineParser.new patterns
    r = lp.parse list

    @to_h = r.inject({}) do |rtn, row|

      name, path = row[1][:captures]
      class_name = name.capitalize
      klass = Object.const_set(class_name,Class.new)

      s = "
        def initialize(reg)
          @reg = reg
        end
      "

      s = if row[3].any? then

        row[3].inject(s) do |r, attr|

          attr_name, x = attr[1][:captures]
          subkey, type = x.split(/\s/).reverse

          r << make_def(path, subkey, attr_name, type)

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

  private

  def make_def(path, subkey, method_name=subkey, type=nil)
"
    def #{method_name}      
      text = @reg.get_key('#{[path, subkey].join('/')}/text()')
      #{'text == %q(true) ? true : false' if type == 'Bool'}
    end
"
  end

end