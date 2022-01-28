open Dom.Storage2
open AppContext

type t = {
  userAddress: string
}

@val external window: 'a = "window"
@val external require: string => string = "require"
@val external localStorage: Dom.Storage2.t = "localStorage"

require("../../../src/App.scss")->ignore

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(update_context_reducer, context_initial_value)

  let _ = RescriptReactRouter.watchUrl(url => {    
    let new_page = Router.route_to(url.path)
    dispatch(Update_current_page(new_page))
  })

  React.useEffect0(() => {
    // sets the app to the home page on load
    let _ = RescriptReactRouter.push("/")
    // finds if user is connected
    let _ = switch localStorage->getItem(Config.ls_prefix ++ Config.ls_user_address) {
      | None => dispatch(Update_user_address(None))
      | Some(addr) => dispatch(Update_user_address(Some(addr)))
    }

    let requestFullscreen = %raw("document.body.requestFullscreen")
    let _ = requestFullscreen()

    None
  })

  <div className="container">
    <StateContext.Provider value={state} >
      <DispatchContext.Provider value={dispatch}>
        <Header />
        <Router />
        <TokensBanner />
        <Footer />
      </DispatchContext.Provider>
    </StateContext.Provider>
  </div>
}
