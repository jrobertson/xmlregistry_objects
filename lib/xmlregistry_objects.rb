#!/usr/bin/env ruby

# file: xmlregistry_objects.rb


require 'polyrex'
require 'dws-registry'


class XMLRegistryObjects

  attr_reader :to_h

  def initialize(reg, obj, log: nil)

    @log = log
    log.info 'XMLRegistryObjects/initialize: active' if log
    
    polyrexdoc = if obj.is_a? Polyrex then 
    
      obj
    
    elsif obj.is_a? String then
      
      buffer, type = RXFHelper.read obj

      if type == :url then
        Polyrex.new buffer
      else
        Polyrex.new.import "<?polyrex schema='entries/objectx[name, regkey]/"\
            "methodx[name,subkeyname]' delimiter=' = '?>\n" + obj
      end
    end
        
    log.info 'XMLRegistryObjects/initialize: before @to_h' if log
    
    @to_h = polyrexdoc.records.inject({}) do |rtn, row|

      name, path = row.name, row.regkey[1..-2]
      class_name = name.capitalize
      klass = Object.const_set(class_name,Class.new)

      base_methods = "
        def initialize(reg)
          @reg = reg
        end
        
        def last_modified()
          lm = @reg.get_key('#{path}').attributes[:last_modified]
          Time.parse(lm) if lm
        end
        
        def set(h)          
          
          h.each {|key,value| self.method((key.to_s + '=').to_sym).call value }
          
        end
      "

      s = if row.records.any? then

        row.records.inject(base_methods) do |r, attr|
          
          attr_name, subkey = attr.name, attr.subkeyname[/\w+$/]
          key = path + '/' + subkey

          r << make_def(key, attr_name)
          r << make_setdef(key, attr_name[/\w+/])

        end

      else

        a = reg.xpath("#{path}/*")
        
        a.inject(base_methods) do |r, x| 

          methods_name = subkey = x.name

          type = x.attributes[:type]          
          key = path + '/' + subkey
          
          r << make_setdef(key, method_name=subkey)          

          method_name += '?' if type and type == 'boolean'          
          r << make_def(key, method_name)

        end
      end
      
      log.info 'XMLRegistryObjects/initialize: before class_eval ' + klass.to_s if log
      
      klass.class_eval s
      rtn.merge name.to_sym => klass.new(reg)

    end
    
    log.info 'XMLRegistryObjects/initialize: completed' if log
  end
  
  def define_methods()
    @to_h.each.map {|k,v| "define_method :#{k.to_s}, ->{h[:#{k}]}"}.join("\n")
  end
  
  # to use this method the client is expect to  fetch the 
  # hash object from the registry object e.g. 
  #    xro = XMLRegistryObjects.new(reg,list)
  #    @h = xro.to_h
  
  def define_methods2(obj=nil)
    
    a = @to_h.each.map {|k,v| [k.to_s.to_sym, ->{@h[k.to_sym]} ] }
    
    if obj then
      
      a.each {|name, blk| obj.class.send(:define_method, name, blk) }
      
    else
      
      return a
      
    end
    
  end  

  private

  def make_def(key, method_name)    
<<-EOF
def #{method_name}()
  @reg.get_key('#{key}', auto_detect_type: true)
end

EOF
  end
  
  def make_setdef(key, method_name)    
    "def #{method_name}=(v)   @reg.set_key '#{key}', v  end\n"
  end  

end
