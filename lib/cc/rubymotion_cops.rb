require 'rubocop/cop/rubymotion/dealloc_must_call_super'
require 'rubocop/cop/rubymotion/do_not_call_retaincount'
require 'rubocop/cop/rubymotion/init_must_return_self'
require 'rubocop/cop/rubymotion/variable_method_arguments_need_trailing_nils'

module CC
  module RubymotionCops
    def self.all
      [
        RuboCop::Cop::Rubymotion::DeallocMustCallSuper,
        RuboCop::Cop::Rubymotion::DoNotCallRetaincount,
        RuboCop::Cop::Rubymotion::InitMustReturnSelf,
        RuboCop::Cop::Rubymotion::VariableMethodArgumentsNeedTrailingNils,
       ]
    end
  end
end
