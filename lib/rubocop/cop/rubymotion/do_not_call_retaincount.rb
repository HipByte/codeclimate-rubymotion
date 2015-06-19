module RuboCop
  module Cop
    module Rubymotion

      class DoNotCallRetaincount < Cop

        MESSAGE = "Do not use retainCount"
        
        def on_send(node)
          if (node.children.last == :retainCount) || 
             (node.children[1] == :send && node.children.last.children == [:retainCount])
            add_offense(node, :expression, MESSAGE)
          end
        end
      end
      
    end
  end
end
