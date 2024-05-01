class Controller
  def initialize(view)
    # ボタンを押したときの挙動を定義する
    OrbitalRing::Routes.draw do
      click 'button', to: "Handler.click", locals: { view: view }
    end
  end
end

module Handler
  def self.click(event, locals)
    statements = Document.querySelector '.statements'
    phrase = statements[:value].to_s

    locals[:view].update phrase
  end
end
