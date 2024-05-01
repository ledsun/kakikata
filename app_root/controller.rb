class Controller
  def initialize(view)
    # ボタンを押したときの挙動を定義する
    OrbitalRing::Routes.draw do
      click '.confirm_button', to: ClickHandler, params: { view: view }
    end
  end
end
