# Introducing the XML Registry Objects gem


    require 'xmlregistry_objects'


    s =&lt;&lt;REG
    app/app1
    admin: jrobertson
    pin_no: 1234

    app/app2
    admin: dsmith
    pin_no: 4321

    hkey_network/thinclient
    active: false
    name: niko2

    hkey_apps/email
    new: true
    last_received: 20-Aug-2014 @ 09:10

    hkey_apps/suntimes
    sunrise: 05:45
    sunset: 08:43
    REG

    reg = XMLRegistry.new 
    reg.import s

    # the following nested list maps the registry key with 
    #                                        associated object and attributes
    list = &lt;&lt;EOF
    thinclient = [hkey_network/thinclient]
      active? = Bool active
      name = name
    email = [hkey_apps/email]
      new? = Bool new
      last_received = last_received
    suntimes = [hkey_apps/suntimes]
      sunrise = sunrise
      sunset = sunset
    EOF
     

    h = XMLRegistryObjects.new(reg,list).to_h

    h [:email].last_received  #=&gt; "20-Aug-2014 @ 09:10" 

    thinclient = h[:thinclient]
    thinclient.name     #=&gt; "niko2" 
    thinclient.active?  #=&gt; false 


The above example shows hows objects can easily be contructed to query the XML registry.

## Resources

* [jrobertson/xmlregistry_objects](https://github.com/jrobertson/xmlregistry_objects)

xmlregistry xmlregistry_objects gem
