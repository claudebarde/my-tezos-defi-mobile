@react.component
let make = (~user_address: option<string>=?, ~current_page: Config.current_page, ~set_user_address) => {
    switch current_page {
      | Tokens_page => <Tokens />
      | Farms_page => <Farms />
      | Settings_page => <Settings ?user_address set_user_address />
      | Home_page => <Home ?user_address set_user_address />
      | _ => <PageNotFound />
    }
}