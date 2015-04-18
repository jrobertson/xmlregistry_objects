Gem::Specification.new do |s|
  s.name = 'xmlregistry_objects'
  s.version = '0.6.6'
  s.summary = 'Query the registry using objects built dynamically from a string which maps each object to a registry key.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/xmlregistry_objects.rb']
  s.add_runtime_dependency('dws-registry', '~> 0.3', '>=0.3.1') 
  s.add_runtime_dependency('polyrex', '~> 1.0', '>=1.0.6')
  s.signing_key = '../privatekeys/xmlregistry_objects.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/xmlregistry_objects'
end
