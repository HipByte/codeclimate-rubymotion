module RuboCop
  module Cop
    module Rubymotion

      class DeallocMustCallSuper < Cop
        include OnMethodDef

        MESSAGE = "When overriding the #dealloc method, super must be called."

        def on_method_def(_node, _method_name, _args, body)
          return unless _method_name == :dealloc
          return unless body
          return if body.each_node.any?{|n| n.zsuper_type?}
          add_offense(_node, :expression, MESSAGE)
        end
      end
      
    end
  end
end
