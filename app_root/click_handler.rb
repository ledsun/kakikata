module ClickHandler
  def self.call(event, locals)
    statements = Document.querySelector '.statements'
    phrase = statements[:value].to_s

    locals[:view].update phrase
  end
end
