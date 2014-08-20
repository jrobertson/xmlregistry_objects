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


      row[3].each do |attr|

        attr_name, x = attr[1][:captures]

        subkey, type = x.split(/\s/).reverse

        s = "

        def initialize(reg)

          @reg = reg

        end

        def #{attr_name}      

          text = @reg.get_key('#{[path, attr_name].join('/')}/text()')
          #{'text == %q(true) ? true : false' if type == 'Bool'}
        end
        "

        klass.class_eval s

      end

      rtn.merge name.to_sym => klass.new(reg)

    end

  end

end
