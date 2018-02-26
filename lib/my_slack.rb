module MySlack
  SUCCESS = "#2ECC40".freeze
  ERROR = "#FF4136".freeze
  WARNING = "#FFA500".freeze
  HELP = <<-EOH
*help:* Prints this message
*status:* Print the current support staff status (aliases: available)
*away:* Mark yourself as away
*here:* Mark yourself as available, you can optionally provide a product that you are working on (aliases: back)
  EOH
end
