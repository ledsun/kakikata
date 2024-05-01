module ClickHandler
  def self.call(event, params)
    statements = Document.querySelector '.statements'
    phrase = statements[:value].to_s

    params[:view].update phrase
  end
end
