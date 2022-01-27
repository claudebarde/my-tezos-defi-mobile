type context = {
    current_page: Config.current_page,
    user_address: option<string>,
    user_balance: result<float, string>,
    mutable counter: int
}

let context_initial_value = {
    current_page: Home_page,
    user_address: None,
    user_balance: Error("init"),
    counter: 1
}

type action =
    | Update_user_address(option<string>)
    | Update_current_page(Config.current_page)

let update_context_reducer = (state, action) => {
    switch action {
        | Update_user_address(addr) => { ...state, user_address: addr }
        | Update_current_page(page) => { ...state, current_page: page }
    }
}

//STATE CONTEXT Component
module StateContext = {
  let context = React.createContext(context_initial_value)

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}

//Dispatch Context Component
module DispatchContext = {
  let context = React.createContext((_action: action) => ())

  module Provider = {
    let provider = React.Context.provider(context)

    @react.component
    let make = (~value, ~children) => {
      React.createElement(provider, {"value": value, "children": children})
    }
  }
}