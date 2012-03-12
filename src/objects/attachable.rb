module SpaceGame; class PhysicsObject
#handles attached joints, constraints and such
module Attachable
  def initialize(opts={})
    super opts
    @attachments = []
  end

  def destroy()
    @attachments.each { |s|
      s[0].remove_from_space(@parent.space)
      s[1].remove_attached(self, false)
    } unless @attachments.empty?
    @attachments = []
    super
  end

  def add_attachment(spring, owner)
    @attachments << [spring, owner]
  end

  def remove_attached(object, remove_from_space = true)
    @attachments.delete_if { |a|
      if a[1] == object
        if remove_from_space 
          a[0].remove_from_space(@parent.space)
          a[1].remove_attached(self, false)
        end  
        true
      else false end }
  end
  
  def remove_last_attachment()
    remove_attached(@attachments.last[1]) unless @attachments.empty?
  end

  def has_attached?(obj = nil)
    obj.nil?                 ?
      !@attachments.empty?   :
      @attachments.find{|a| a[1] == obj}
  end
end

end; end
