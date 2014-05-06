class RSpecDescribeHandler < YARD::Handlers::Ruby::Base
  handles method_call(:describe)

  def process
    describes = statement.parameters.first.jump(:string_content).source

    # Remove the argument list from describe "#method(a, b, &c)"
    if arguments = describes[/[#.](?:.+)(\([^)]*\))$/, 1]
      describes = describes[0, describes.length - arguments.length]
    end

    context = []
    if (controller_test = describes.match(/(GET|PUT|POST|DELETE) '?(\w+)'?/))
      describes = '#'+controller_test[2]
      context = ["When called with the http #{controller_test[1]} verb"]
    end
    if (routing_test = describes.match(/^routing.*/))
      describes = ''
      context = ["routing_test"]
    end

    unless owner.is_a?(Hash)
      pwner = Hash[describes: describes, context: context]
      parse_block(statement.last.last, owner: pwner)
    else
      describes = owner[:describes] + describes
      pwner = owner.merge(describes: describes)
      pwner[:context] = pwner[:context] + context
      parse_block(statement.last.last, owner: pwner)
    end
  rescue YARD::Handlers::NamespaceMissingError
  end
end

class RSpecContextHandler < YARD::Handlers::Ruby::Base
  handles method_call(:context)

  def process
    if owner.is_a?(Hash)
      context = statement.parameters.first.jump(:string_content).source
      context = owner[:context].dup << context

      parse_block(statement.last.last, owner: owner.merge(context: context))
    end
  rescue YARD::Handlers::NamespaceMissingError
  end
end

class RSpecItHandler < YARD::Handlers::Ruby::Base
  handles method_call(:it)
  handles method_call(:specify)

  def process
    return unless owner.is_a?(Hash)
    return unless owner[:describes]

    node_name = owner[:describes]

    if !owner[:describes][/#\w+/] && statement.parameters.first
      node_name = owner[:describes] + statement.parameters.first.jump(:string_content).source[/#\w+/].to_s
    end
    ensure_loaded!(P(node_name))

    node = YARD::Registry.resolve(nil, node_name, true)
    # require "pry"
    # binding.pry
    # exit if ENV['EXIT']
    spec = if statement.parameters.any?
             statement.parameters.first.jump(:string_content).source
           elsif statement.block && statement.docstring
             statement.docstring
           elsif statement.block
             matcher   = statement.block.jump(:command)
             relation  = matcher.parameters.first
             reference = relation.parameters.first.jump(:ident).source
             options   = if relation.parameters[-2] && relation.parameters[-2].first.type == :assoc
                           begin
                             temp = relation.parameters[-2].collect do |a|
                               a.map{|b| b.source.tr(":","")}.join(" ")
                             end
                             if temp.length > 1
                               temp[0, temp.length - 1].join(" ") + " and " + temp.pop
                             else
                               temp.first
                             end
                           rescue
                             nil
                           end
                         end
             matcher   = matcher.method_name.source.humanize.downcase
             relation  = relation.method_name.source.humanize.downcase
             resolved  = YARD::Registry.resolve(nil, reference.classify)
             reference = resolved ? "<a href='/docs/#{resolved.path}'>#{resolved.name}</a>" : reference.humanize.downcase
             "#{matcher} #{relation} #{reference} #{options}".strip
           else
             "untitled spec"
           end

    unless node
      log.warn "Unknown node #{owner[:describes]} for spec defined in #{statement.file} near line #{statement.line}"
      # statement.file
      # statement.line
      # owner[:describes]
      return
    end

    return process_routing_spec(node) if owner[:context].include?("routing_test")

    if last = statement.last.last
      source = last.source.strip
    else
      source = ""
    end

    specifications = (node[:specifications] ||= {})
    owner[:context].each do |c|
      specifications = (specifications[c] ||= {})
    end

    (specifications["specs"] ||= []) << \
      Hash[ name: spec,
            file: statement.file,
            line: statement.line,
            source: source ]
  end

  def process_routing_spec(parent)
    if last = statement.last.last
      source = last.source.strip
    else
      source = ""
    end

    routing_specs = (parent[:routing_specs] ||= {})
    (owner[:context] - ["routing_test"]).each do |c|
      routing_specs = (routing_specs[c] ||= {})
    end

    description = if statement.parameters && !(statement.parameters.first.jump(:string_content).source[/^routes to #\w+/])
                    statement.parameters.first.jump(:string_content).source + ": "
                  else
                    ""
                  end

    source.split("\n").each do |line|
      if line[/(get|post|put|delete).*\.should(_not)? route_to/]
        (routing_specs["specs"] ||= []) << \
          Hash[ name: description + line,
                file: statement.file,
                line: statement.line,
                source: source ]
      end
    end
  end
end

class RSpecItsHandler < YARD::Handlers::Ruby::Base
  handles method_call(:its)

  def process
    return unless owner.is_a?(Hash)
    return unless owner[:describes]

    node = YARD::Registry.resolve(nil, owner[:describes], true)
    property = statement.parameters.first.join(" ")
    should   = statement.last.last.source[/should(?:_not)? (.+)/, 1]

    spec = if property and should
             spec = "#{property} #{should}"
           else
             "untitled spec"
           end

    unless node
      log.warn "Unknown node #{owner[:describes]} for spec defined in #{statement.file} near line #{statement.line}"
      return
    end

    if last = statement.last.last
      source = last.source.strip
    else
      source = ""
    end

    specifications = (node[:specifications] ||= {})
    owner[:context].each do |c|
      specifications = (specifications[c] ||= {})
    end

    (specifications["specs"] ||= []) << \
      Hash[ name: spec,
            file: statement.file,
            line: statement.line,
            source: source ]
  end
end
