require 'awspec'

module SelfHeal

'''this function takes a previously captured EC2 instance name and chacks it against the current
inventory. If the resource is found or can be pattern matched to a matching one with a dynamic element updated
the function returns the resource name, otherwise its false'''

  def dynamic_resource(item)
    unless ec2(item).exists?
      resource = Aws::EC2::Resource.new(region: 'eu-west-2')
      capture_group = item.match(/([a-z]+-)([a-z|0-9]+)(\..+)/)

      if capture_group
        network_item = capture_group[1]
        environment = capture_group[3]

        resource.instances.each do | i |
          i.tags.each do | tag |
            if tag.key == 'Name'
              name = tag.value
              regex = /\b#{Regexp.quote(network_item)}[0-9|a-z]+#{Regexp.quote(environment)}\b/
              if name.match(regex)  #unless
                return name
              end
            end
          end
        end
      end
    end
    item
  end
  module_function :dynamic_resource
end

