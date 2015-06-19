module RuboCop
  module Cop
    module Rubymotion

      class VariableMethodArgumentsNeedTrailingNils < Cop
        MESSAGE = "Trailing nil ommitted for variable argument method."

        def on_send(node)
          if candidate_methods.include?(node.children[1])
            # TODO implement algorithm
          end
        end

      private

        def candidate_methods
          [:arrayWithObjects, :initWithTitle]
        end

      end
    end
  end
end
