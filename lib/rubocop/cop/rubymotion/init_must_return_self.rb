module RuboCop
  module Cop
    module Rubymotion

      class InitMustReturnSelf < Cop
        include OnMethodDef

        MESSAGE = "When overriding the #init method, self must be returned."

        def on_method_def(_node, _method_name, _args, body)
          return unless _method_name == :init
          return unless body
          return if body.self_type?

          if body.each_node.none?{|x| x.type == :self }
            add_init_must_return_self_offense(_node)
            return
          end

          last_expr_in_body = body.children.last
          return if last_expr_in_body.self_type?
          return if last_expr_in_body.return_type? && last_expr_in_body.children.last.self_type?

          add_init_must_return_self_offense(_node) 
        end

        private 

        def add_init_must_return_self_offense(node)
          add_offense(node, :expression, MESSAGE)
        end
      end
      
    end
  end
end
