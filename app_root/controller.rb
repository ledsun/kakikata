class Controller
  def initialize(view)
    # ボタンを押したときの挙動を定義する
    OrbitalRing::Routes.draw do
      click 'button', to: ClickHandler, locals: { view: view }
    end
  end
end
