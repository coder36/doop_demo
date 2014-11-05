module ChildbenHelper

  def doop_textfield name, answer, res, options = {}

    s = render "textfield", :answer => answer, :name => name, :res => res, :label => options[:label]

  end
end
