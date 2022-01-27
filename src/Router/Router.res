open Context

let route_to = (url_path: list<string>) => {
  switch url_path {
    | list{"tokens"} => Config.Tokens_page
    | list{"farms"} => Config.Farms_page
    | list{"settings"} => Config.Settings_page
    | list{} => Config.Home_page
    | _ => Config.Not_found_page
  }
}

@react.component
let make = () => {
  let state = React.useContext(StateContext.context)

  switch state.current_page {
    | Tokens_page => <Tokens />
    | Farms_page => <Farms />
    | Settings_page => <Settings />
    | Home_page => <Home />
    | _ => <PageNotFound />
  }
}