def init
  super
  sections.place(:specs).before(:children)
end

def render_specs specs
  content = File.read(File.join(File.dirname(__FILE__), 'html', 'spec.erb'))
  t = ERB.new(content)
  t.result(binding)
end

def render_contexts contexts
  content = File.read(File.join(File.dirname(__FILE__), 'html', 'contexts.erb'))
  t = ERB.new(content)
  t.result(binding)
end
