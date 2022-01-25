@react.component
let make = (~user_address: option<string>=?, ~set_user_address) => {
    switch user_address {
        | None => <Home_No_user set_user_address />
        | Some(address) => <Home_Connected user_address={address} />
    }
}