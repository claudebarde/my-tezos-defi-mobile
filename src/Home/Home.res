@react.component
let make = () => {
    let state = React.useContext(AppContext.StateContext.context)

    switch state.user_address {
        | None => <Home_No_user />
        | Some(_) => <Home_Connected />
    }
}