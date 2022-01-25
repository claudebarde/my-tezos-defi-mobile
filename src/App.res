open Dom.Storage2

type t = {
  userAddress: string
}

@val external window: 'a = "window"
@val external require: string => string = "require"
@val external localStorage: Dom.Storage2.t = "localStorage"

require("../../../src/App.scss")->ignore

@react.component
let make = () => {
  let (user_address, set_user_address) = React.useState(_ => None)
  let (current_page, set_current_page) = React.useState(_ => Config.Home_page)

  let _ = RescriptReactRouter.watchUrl(url => {    
    switch url.path {
      | list{"tokens"} => set_current_page(_ => Config.Tokens_page)
      | list{"farms"} => set_current_page(_ => Config.Farms_page)
      | list{"settings"} => set_current_page(_ => Config.Settings_page)
      | list{} => set_current_page(_ => Config.Home_page)
      | _ => set_current_page(_ => Config.Not_found_page)
    }
  })

  let _ = React.useEffect0(() => {
    // finds if user is connected
    let _ = switch localStorage->getItem(Config.ls_prefix ++ Config.ls_user_address) {
      | None => set_user_address(_ => None)
      | Some(addr) => set_user_address(_ => Some(addr))
    }
    None
  })

  <div className="container">
    <Header ?user_address />
    <Router ?user_address current_page set_user_address />
    <Footer ?user_address />
  </div>
}
