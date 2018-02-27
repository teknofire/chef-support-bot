module MySlack
  class Products
    COMMANDS = %w{ list add remove help }
    class << self
      def handle(text)
        keyword, data = _parse_text(text)
        if COMMANDS.include?(keyword)
          send(keyword, data)
        else
          help('Unknown command, here is what you can do with products')
        end
      end

      def _parse_text(text)
        text.downcase!
        words = text.split(' ')
        [words.shift, words.join(' ')]
      end

      def list(options = nil)
        products = Product.order(name: :asc).pluck(:name).join("\n")

        message = MySlack::Message.new(text: 'Here is the list of products')
        message.push_attachment({
          text: products
        })

        message
      end

      def remove(name)
        product = Product.where(name: name).first
        message = MySlack::Message.new()

        if product.nil?
          message.text = "Unable to find a product named: #{name}"
        elsif product.destroy
          message.text = "Removed product *#{name}*"
        else
          message.text = "Unable to delete the product *#{name}*"
          message.push_attachment({
            text: product.errors.full_messages.join("\n"),
            color: MySlack::ERROR
          })
        end

        message
      end

      def add(name)
        product = Product.new(name: name)
        message = MySlack::Message.new()

        if product.save
          message.text = "New product *#{name}* added"
        else
          message.text = "Unable to add product *#{name}*"
          message.push_attachment({
            text: product.errors.full_messages.join("\n"),
            color: MySlack::ERROR
          })
        end

        message
      end

      def help(msg = "")
        msg = 'Here is what I can do with products' if msg.blank?

        message = MySlack::Message.new(text: msg)
        message.push_attachment({
          fields: [{
            title: 'list',
            value: 'List configured products',
          },{
            title: 'add [name]',
            value: 'Add a new product, authorization required',
          },{
            title: 'remove [name]',
            value: 'Remove a product, authorization required',
          }, {
            title: 'help',
            value: 'Print this message'
          }]
        })

        message
      end
    end
  end
end
