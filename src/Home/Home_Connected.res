@react.component
let make = () => {
    let state = React.useContext(Context.StateContext.context)

    switch state.user_address {
        | None => <div>{"You are not connected"->React.string}</div>
        | Some(addr) => <div>{React.string("Hello " ++ addr)}</div>
    }
}