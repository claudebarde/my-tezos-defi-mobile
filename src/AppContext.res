type token_type = FA12 | FA2 | None

type token_data = {
    name: option<string>,
    exchange_rate: option<float>,
    address: option<string>,
    type_: token_type,
    decimals: option<int>
}

type context = {
    current_page: Config.current_page,
    user_address: option<string>,
    user_balance: result<float, string>,
    tokens: array<token_data>,
    xtz_exchange_rate: option<float>
}

let context_initial_value = {
    current_page: Home_page,
    user_address: None,
    user_balance: Error("init"),
    tokens: [],
    xtz_exchange_rate: None
}

type action =
    | Update_current_page(Config.current_page)
    | Update_user_address(option<string>)
    | Update_user_balance(result<float, string>)
    | Update_tokens(array<token_data>)
    | Update_xtz_exchange_rate(option<float>)

let update_context_reducer = (state, action) => {
    switch action {
        | Update_current_page(page) => { ...state, current_page: page }
        | Update_user_address(addr) => { ...state, user_address: addr }
        | Update_user_balance(blnc) => { ...state, user_balance: blnc}
        | Update_tokens(tokens) =>
            if tokens->Js.Array2.length > 0 {
                { ...state, tokens }
            } else {
                state
            }
        | Update_xtz_exchange_rate(rate) => { ...state, xtz_exchange_rate: rate}
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